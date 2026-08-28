#!/bin/bash
set -e
echo "Revertendo temporariamente gesture-handler e RevenueCat (voltando ao que o binario instalado suporta)..."

# 1. Remove as duas dependencias nativas do package.json, sem tocar no resto
python3 << 'PYEOF'
import json

with open('package.json') as f:
    pkg = json.load(f)

removed = []
for dep in ['react-native-gesture-handler', 'react-native-purchases']:
    if dep in pkg.get('dependencies', {}):
        del pkg['dependencies'][dep]
        removed.append(dep)

with open('package.json', 'w') as f:
    json.dump(pkg, f, indent=2)
    f.write('\n')

print('Removido do package.json:', removed if removed else '(nada precisou ser removido)')
PYEOF

cat > app/_layout.tsx << 'INNEREOF'
import React, { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider, useAuth } from '../src/context/AuthContext';
import { theme } from '../src/theme';

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
INNEREOF

cat > src/services/subscription.service.ts << 'INNEREOF'
import * as SubscriptionRepo from '../repositories/subscription.repository';
import type { Subscription, SubscriptionStatus } from '../types';

/**
 * SubscriptionService — the ONLY place in the app that should know about
 * subscription/entitlement logic. UI code should call these functions
 * instead of reading `subscription.status` directly, so that when the
 * RevenueCat native SDK is wired in later, only this file needs to change.
 *
 * TEMPORARY STATE: reverted to stub purchase actions because the currently
 * installed dev-client binary doesn't have react-native-purchases compiled
 * in yet (no build credit available). Status reads still work normally —
 * they come from Supabase, not from the SDK. Re-apply the RevenueCat SDK
 * version (apply_final_batch.sh) before the next real build.
 */

const ACTIVE_STATUSES: SubscriptionStatus[] = ['trialing', 'active', 'cancelled', 'billing_issue', 'grace_period'];
// Note: 'cancelled' still grants access — the user turned off auto-renew
// but already paid through `expires_at`. The expiry check below is what
// actually cuts off access once the paid period truly ends.

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

export function configureSDK(): void {
  if (__DEV__) console.info('[SubscriptionService] configureSDK stub — RevenueCat SDK not built into this binary yet.');
}

export async function identifyUser(userId: string): Promise<void> {
  if (__DEV__) console.info('[SubscriptionService] identifyUser stub:', userId);
}

export async function resetIdentity(): Promise<void> {
  if (__DEV__) console.info('[SubscriptionService] resetIdentity stub');
}

export async function startPurchase(productId?: string): Promise<{ ok: boolean; error?: string }> {
  return { ok: false, error: 'Compras ainda não estão disponíveis nesta versão do app.' };
}

export async function restorePurchases(): Promise<{ ok: boolean; error?: string }> {
  return { ok: false, error: 'Compras ainda não estão disponíveis nesta versão do app.' };
}
INNEREOF

echo "Removendo node_modules e reinstalando limpo..."
rm -rf node_modules
npm install

npx tsc --noEmit

echo "Confirmando ausencia de imports nativos novos..."
if grep -rlE "from 'react-native-gesture-handler'|from 'react-native-purchases'|from \"react-native-gesture-handler\"|from \"react-native-purchases\"" app/ src/ 2>/dev/null; then
  echo "AVISO: ainda ha import nativo, revisar"
else
  echo "OK: seguro para o binario ja instalado"
fi

git add -A
git commit -m "Temporarily revert gesture-handler/RevenueCat SDK (no build credit yet) - JS-only testing"
git push

echo ""
echo "Pronto! Agora roda:"
echo "  npx expo start --dev-client --tunnel --clear"
