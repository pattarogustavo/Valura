#!/bin/bash
set -e
echo "Instalando o SDK do RevenueCat (react-native-purchases)..."

mkdir -p "$(dirname "package.json")"
cat > "package.json" << 'FILEEOF'
{
  "name": "valura",
  "version": "1.0.0",
  "main": "expo-router/entry",
  "engines": {
    "node": ">=22.0.0"
  },
  "scripts": {
    "start": "expo start",
    "ios": "expo run:ios",
    "android": "expo run:android"
  },
  "dependencies": {
    "@react-native-async-storage/async-storage": "~2.1.0",
    "@supabase/supabase-js": "2.45.0",
    "browserify-zlib": "^0.2.0",
    "crypto-browserify": "^3.12.0",
    "events": "^3.3.0",
    "expo": "~53.0.0",
    "expo-apple-authentication": "~7.2.4",
    "expo-asset": "~11.1.7",
    "expo-auth-session": "~6.2.1",
    "expo-constants": "~17.1.8",
    "expo-dev-client": "~5.2.4",
    "expo-image-picker": "~16.1.4",
    "expo-linking": "~7.1.7",
    "expo-router": "~5.1.11",
    "expo-status-bar": "~2.2.3",
    "expo-web-browser": "~14.2.0",
    "https-browserify": "^1.0.0",
    "os-browserify": "^0.3.0",
    "path-browserify": "^1.0.1",
    "react": "19.0.0",
    "react-native": "0.79.6",
    "react-native-safe-area-context": "5.4.0",
    "react-native-purchases": "^10.8.1",
    "react-native-screens": "~4.11.1",
    "react-native-url-polyfill": "^2.0.0",
    "stream-browserify": "^3.0.0",
    "stream-http": "^3.2.0",
    "url": "^0.11.0",
    "util": "^0.12.5"
  },
  "devDependencies": {
    "@babel/core": "^7.25.0",
    "@expo/config-plugins": "~10.1.1",
    "@types/react": "~19.0.10",
    "typescript": "~5.8.3"
  }
}
FILEEOF

mkdir -p "$(dirname "src/services/subscription.service.ts")"
cat > "src/services/subscription.service.ts" << 'FILEEOF'
import { Platform } from 'react-native';
import Purchases, { LOG_LEVEL } from 'react-native-purchases';
import * as SubscriptionRepo from '../repositories/subscription.repository';
import type { Subscription, SubscriptionStatus } from '../types';

/**
 * SubscriptionService — the ONLY place in the app that should know about
 * RevenueCat or subscription/entitlement logic. UI code should call these
 * functions instead of touching `Purchases` or `subscription.status`
 * directly.
 *
 * Two data paths, on purpose:
 *  - STATUS (hasPremiumAccess, isTrialing, ...) is read from Supabase's
 *    `subscriptions` table, kept current by the RevenueCat webhook. This
 *    is the single source of truth shown across every device.
 *  - ACTIONS (startPurchase, restorePurchases, identifyUser) talk to the
 *    RevenueCat SDK directly, since those are inherently on-device/App
 *    Store operations. A successful purchase still flows back through
 *    the webhook to update Supabase, same as any other event.
 */

const ACTIVE_STATUSES: SubscriptionStatus[] = ['trialing', 'active', 'cancelled', 'billing_issue', 'grace_period'];
// Note: 'cancelled' still grants access — the user turned off auto-renew
// but already paid through `expires_at`. The expiry check below is what
// actually cuts off access once the paid period truly ends.

const REVENUECAT_ENTITLEMENT_ID = 'premium';

let configured = false;

// ─── SDK LIFECYCLE ──────────────────────────────────────────────────────────

/** Call once, as early as possible (root layout mount). No-ops safely if
 *  no API key is set yet (e.g. RevenueCat not configured in this build). */
export function configureSDK(): void {
  if (configured) return;

  const apiKey = Platform.select({
    ios:     process.env.EXPO_PUBLIC_REVENUECAT_IOS_KEY,
    android: process.env.EXPO_PUBLIC_REVENUECAT_ANDROID_KEY,
    default: undefined,
  });

  if (!apiKey) {
    if (__DEV__) {
      console.warn('[SubscriptionService] No RevenueCat API key set — purchases are disabled in this build.');
    }
    return;
  }

  Purchases.configure({ apiKey });
  if (__DEV__) Purchases.setLogLevel(LOG_LEVEL.DEBUG);
  configured = true;
}

/**
 * Associates the Supabase user with a RevenueCat customer. Using the
 * Supabase user id as RevenueCat's App User ID keeps the two systems in
 * lockstep (the webhook receives this same id as `event.app_user_id`).
 */
export async function identifyUser(userId: string): Promise<void> {
  if (!configured) return;
  try {
    await Purchases.logIn(userId);
  } catch (e) {
    if (__DEV__) console.warn('[SubscriptionService] identifyUser failed:', e);
  }
}

/** Clears the RevenueCat identity on sign-out. */
export async function resetIdentity(): Promise<void> {
  if (!configured) return;
  try {
    await Purchases.logOut();
  } catch (e) {
    if (__DEV__) console.warn('[SubscriptionService] resetIdentity failed:', e);
  }
}

// ─── STATUS (read from Supabase) ───────────────────────────────────────────

export async function getSubscription(userId: string): Promise<Subscription | null> {
  const result = await SubscriptionRepo.getSubscription(userId);
  return result.ok ? result.data : null;
}

export function hasPremiumAccess(subscription: Subscription | null): boolean {
  if (!subscription) return false;
  if (!ACTIVE_STATUSES.includes(subscription.status)) return false;
  if (subscription.expires_at && new Date(subscription.expires_at).getTime() < Date.now()) {
    return false; // status hasn't caught up with expiry yet — fail closed
  }
  return true;
}

export function hasEntitlement(subscription: Subscription | null, entitlement: string): boolean {
  return hasPremiumAccess(subscription) && subscription?.entitlement === entitlement;
}

export function isTrialing(subscription: Subscription | null): boolean {
  return subscription?.status === 'trialing';
}

export function isExpired(subscription: Subscription | null): boolean {
  if (!subscription) return false;
  return subscription.status === 'expired'
    || (!!subscription.expires_at && new Date(subscription.expires_at).getTime() < Date.now());
}

export function willRenew(subscription: Subscription | null): boolean {
  return subscription?.will_renew ?? false;
}

// ─── PURCHASE ACTIONS (talk to RevenueCat directly) ────────────────────────

export async function startPurchase(productId?: string): Promise<{ ok: boolean; error?: string }> {
  if (!configured) {
    return { ok: false, error: 'Compras ainda não estão disponíveis nesta versão do app.' };
  }
  try {
    const offerings = await Purchases.getOfferings();
    const available = offerings.current?.availablePackages ?? [];
    const pkg = productId
      ? available.find(p => p.product.identifier === productId)
      : available[0];

    if (!pkg) {
      return { ok: false, error: 'Nenhum plano disponível no momento. Tente novamente mais tarde.' };
    }

    await Purchases.purchasePackage(pkg);
    // The webhook will update Supabase shortly after; useSubscription's
    // realtime subscription picks up the change automatically.
    return { ok: true };
  } catch (e: any) {
    if (e?.userCancelled) return { ok: false, error: 'Compra cancelada.' };
    return { ok: false, error: e?.message ?? 'Não foi possível concluir a compra.' };
  }
}

export async function restorePurchases(): Promise<{ ok: boolean; error?: string }> {
  if (!configured) {
    return { ok: false, error: 'Compras ainda não estão disponíveis nesta versão do app.' };
  }
  try {
    const customerInfo = await Purchases.restorePurchases();
    const hasEntitlement = !!customerInfo.entitlements.active[REVENUECAT_ENTITLEMENT_ID];
    if (!hasEntitlement) {
      return { ok: false, error: 'Nenhuma compra anterior encontrada para esta conta.' };
    }
    return { ok: true };
  } catch (e: any) {
    return { ok: false, error: e?.message ?? 'Não foi possível restaurar as compras.' };
  }
}
FILEEOF

mkdir -p "$(dirname "app/_layout.tsx")"
cat > "app/_layout.tsx" << 'FILEEOF'
import React, { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider, useAuth } from '../src/context/AuthContext';
import { theme } from '../src/theme';
import { configureSDK } from '../src/services/subscription.service';

configureSDK();

// ─── AUTH GATE ────────────────────────────────────────────────────────────────
function RootNavigator() {
  const { user, loading, initialized } = useAuth();
  const router   = useRouter();
  const segments = useSegments();

  useEffect(() => {
    if (!initialized) return;
    const inAuthGroup = segments[0] === '(auth)';
    if (!user && !inAuthGroup) {
      router.replace('/(auth)/login');
    } else if (user && inAuthGroup) {
      router.replace('/(app)');
    }
  }, [user, initialized, segments]);

  if (!initialized || loading) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg }}>
        <ActivityIndicator color={theme.gold} size="large" />
      </View>
    );
  }

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(auth)" />
      <Stack.Screen name="(app)" />
    </Stack>
  );
}

// ─── ROOT LAYOUT ──────────────────────────────────────────────────────────────
export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <AuthProvider>
        <RootNavigator />
      </AuthProvider>
    </SafeAreaProvider>
  );
}
FILEEOF

npm install
npx tsc --noEmit

echo "Verificando autolinking (o mesmo comando que o Podfile usa de verdade)..."
npx expo-modules-autolinking react-native-config --json --platform ios 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
deps = data.get('dependencies', {})
if 'react-native-purchases' in deps:
    print('OK: react-native-purchases sera linkado no build')
else:
    print('AVISO: nao apareceu no autolinking, revisar antes de buildar')
    sys.exit(1)
"

echo "Tudo OK. Fazendo commit..."
git add -A
git commit -m "Install RevenueCat SDK (react-native-purchases) and wire up SubscriptionService"
git push

echo ""
echo "Agora e so gerar o build:"
echo "  eas build --platform ios --profile development"
