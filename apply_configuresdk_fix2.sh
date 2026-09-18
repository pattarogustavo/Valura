#!/bin/bash
set -e
echo "Aplicando correcao: adiar configureSDK() + protege-lo com try/catch..."

cat > "app/_layout.tsx" << 'FILEEOF'
import React, { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider, useAuth } from '../src/context/AuthContext';
import { PrivacyProvider } from '../src/context/PrivacyContext';
import { theme } from '../src/theme';
import { configureSDK } from '../src/services/subscription.service';

// ─── AUTH GATE ────────────────────────────────────────────────────────────────
function RootNavigator() {
  const { user, loading, initialized } = useAuth();
  const router   = useRouter();
  const segments = useSegments();

  // IMPORTANT: configureSDK() used to run at module load time (before this
  // component ever mounted, before the native bridge/app delegate had
  // necessarily finished setting up). That matched a crash pattern we've
  // hit before with other native modules — calling into native code too
  // early crashes the whole app with no JS-catchable error. Now it only
  // runs once the app has actually mounted, and configureSDK() itself is
  // wrapped in try/catch so a RevenueCat issue (bad key, missing
  // capability, etc.) degrades gracefully instead of crashing.
  useEffect(() => {
    configureSDK();
  }, []);

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
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <AuthProvider>
          <PrivacyProvider>
            <RootNavigator />
          </PrivacyProvider>
        </AuthProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
FILEEOF

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

  // Never let a RevenueCat SDK issue (bad key, missing In-App Purchase
  // capability, etc.) crash the whole app — subscriptions degrade
  // gracefully instead. This also protects against calling native code
  // before it's fully ready if configureSDK() is ever invoked earlier
  // than expected in the app lifecycle.
  try {
    Purchases.configure({ apiKey });
    if (__DEV__) Purchases.setLogLevel(LOG_LEVEL.DEBUG);
    configured = true;
  } catch (e) {
    if (__DEV__) console.warn('[SubscriptionService] configureSDK failed:', e);
  }
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

npx tsc --noEmit

echo ""
echo "=== VERIFICACAO ==="
if grep -A1 "^configureSDK();" app/_layout.tsx 2>/dev/null || grep -B2 "^configureSDK();" app/_layout.tsx 2>/dev/null; then
  echo "ERRO: configureSDK() ainda esta solta no topo do arquivo!"
  exit 1
fi
if grep -q "useEffect(() => {" app/_layout.tsx && grep -q "configureSDK();" app/_layout.tsx; then
  echo "OK: configureSDK() esta dentro de um useEffect"
else
  echo "AVISO: nao consegui confirmar automaticamente, revise app/_layout.tsx manualmente"
fi

echo "Fazendo commit..."
git add -A
git commit -m "Fix: defer RevenueCat configureSDK() until after app mount, wrap in try/catch"
git push

echo ""
echo "Pronto! Para confirmar que funcionou, roda:"
echo "  grep -n configureSDK app/_layout.tsx"
echo "A linha 'configureSDK();' deve aparecer DENTRO de um bloco useEffect,"
echo "nao mais sozinha logo apos os imports."
echo ""
echo "Depois: eas build --platform ios --profile production --auto-submit"
