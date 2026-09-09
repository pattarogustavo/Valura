#!/bin/bash
set -e
echo "Combinando: privacidade/tema/meses/projecoes + arrastar-pra-apagar + RevenueCat..."
mkdir -p src/components src/services "app/(app)/(tabs)"

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
    "react-native-gesture-handler": "~2.24.0",
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

mkdir -p "$(dirname "app/_layout.tsx")"
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

mkdir -p "$(dirname "src/components/SwipeableRow.tsx")"
cat > "src/components/SwipeableRow.tsx" << 'FILEEOF'
import React, { useRef } from 'react';
import { StyleSheet, Animated, TouchableOpacity } from 'react-native';
import { Swipeable } from 'react-native-gesture-handler';
import { theme } from '../theme';

interface SwipeableRowProps {
  children: React.ReactNode;
  onDelete: () => void;
}

/** Wraps a row with a "swipe left to reveal a red delete button" gesture. */
export function SwipeableRow({ children, onDelete }: SwipeableRowProps) {
  const swipeableRef = useRef<Swipeable>(null);

  const renderRightActions = (
    _progress: Animated.AnimatedInterpolation<number>,
    dragX: Animated.AnimatedInterpolation<number>
  ) => {
    const scale = dragX.interpolate({
      inputRange: [-80, 0],
      outputRange: [1, 0.5],
      extrapolate: 'clamp',
    });

    return (
      <TouchableOpacity
        style={s.deleteAction}
        onPress={() => {
          swipeableRef.current?.close();
          onDelete();
        }}
      >
        <Animated.Text style={[s.deleteText, { transform: [{ scale }] }]}>
          Apagar
        </Animated.Text>
      </TouchableOpacity>
    );
  };

  return (
    <Swipeable
      ref={swipeableRef}
      renderRightActions={renderRightActions}
      overshootRight={false}
      rightThreshold={40}
    >
      {children}
    </Swipeable>
  );
}

const s = StyleSheet.create({
  deleteAction: {
    backgroundColor: theme.danger,
    justifyContent: 'center',
    alignItems: 'center',
    width: 80,
    borderRadius: 12,
    marginBottom: 8,
  },
  deleteText: {
    color: theme.white,
    fontSize: 13,
    fontWeight: '700',
  },
});
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

mkdir -p "$(dirname "app/(app)/(tabs)/index.tsx")"
cat > "app/(app)/(tabs)/index.tsx" << 'FILEEOF'
/**
 * app/(app)/(tabs)/index.tsx  →  Summary / Dashboard tab
 */

import React, { useMemo, useState, useCallback } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect, useRouter } from 'expo-router';
import { useAuth }         from '../../../src/context/AuthContext';
import { usePrivacy }      from '../../../src/context/PrivacyContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget }       from '../../../src/hooks/useBudget';
import { useCategories }   from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';
import { BellIcon, SettingsIcon, EyeIcon, EyeOffIcon } from '../../../src/components/Icons';
import { CategoryIcon } from '../../../src/components/CategoryIcon';
import { SwipeableRow } from '../../../src/components/SwipeableRow';

const now = new Date();

export default function SummaryScreen() {
  const { user } = useAuth();
  const { hidden, toggle, formatAmount } = usePrivacy();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  const [viewYear, setViewYear] = useState(now.getFullYear());
  const [viewMonth, setViewMonth] = useState(now.getMonth());
  const isCurrentMonth = viewYear === now.getFullYear() && viewMonth === now.getMonth();

  const userId = user?.id ?? '';
  const monthYear = `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}`;

  const { transactions, loading: txLoading, refresh: refreshTx, deleteTransaction } = useTransactions({ userId, year: viewYear, month: viewMonth });
  const { budget, loading: budLoading, refresh: refreshBudget } = useBudget(userId, monthYear);
  const { categories, loading: catLoading, refresh: refreshCategories } = useCategories(userId);

  useFocusEffect(
    useCallback(() => {
      if (!userId) return;
      refreshTx();
      refreshBudget();
      refreshCategories();
    }, [userId, refreshTx, refreshBudget, refreshCategories])
  );

  const loading = txLoading || budLoading || catLoading;

  const { totalIncome, totalExpense, remaining, savingsRate } = useMemo(() => {
    const totalIncome = transactions.filter(t => t.type === 'income').reduce((s, t) => s + t.amount, 0);
    const totalExpense = transactions.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0);
    const remaining = totalIncome - totalExpense;
    const savingsRate = totalIncome > 0 ? Math.max(0, Math.round((remaining / totalIncome) * 100)) : 0;
    return { totalIncome, totalExpense, remaining, savingsRate };
  }, [transactions]);

  const totalBudget = Object.values(budget).reduce((s, v) => s + v, 0);

  const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
  const thirdKpi = isCurrentMonth
    ? {
        label: 'Limite/dia',
        value: formatAmount(Math.max(0, remaining) / Math.max(1, daysInMonth - now.getDate()), 0),
      }
    : {
        label: 'Média/dia',
        value: formatAmount(totalExpense / daysInMonth, 0),
      };

  if (!user || loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.gold} />
      </View>
    );
  }

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 100 }}>
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <View style={s.headerTop}>
          <Text style={s.greeting}>Bom dia, {user.profile?.display_name ?? 'Ana'}</Text>
          <View style={{ flexDirection: 'row', gap: 8 }}>
            <TouchableOpacity style={s.bellBtn} onPress={toggle}>
              {hidden
                ? <EyeOffIcon size={16} color={theme.gold} />
                : <EyeIcon size={16} color={theme.gold} />}
            </TouchableOpacity>
            <View style={s.bellBtn}>
              <BellIcon size={16} color={theme.gold} />
            </View>
            <TouchableOpacity style={s.bellBtn} onPress={() => router.push('/(app)/configuracoes')}>
              <SettingsIcon size={16} color={theme.gold} />
            </TouchableOpacity>
          </View>
        </View>

        <View style={s.monthRow}>
          <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} />
        </View>

        <Text style={s.balLabel}>SALDO DISPONÍVEL</Text>
        <Text style={s.balance}>{formatAmount(remaining)}</Text>

        <View style={s.barBg}>
          <View style={[s.barFill, {
            width: `${Math.min(100, Math.round((totalExpense / (totalBudget || 1)) * 100))}%`,
          }]} />
        </View>

        <View style={s.barRow}>
          <Text style={s.barText}>Gasto: {formatAmount(totalExpense, 0)}</Text>
          <Text style={s.barText}>Orçamento: {formatAmount(totalBudget, 0)}</Text>
        </View>
      </View>

      {/* ── KPIs ── */}
      <View style={s.kpiRow}>
        {[
          { l: 'Receitas', v: formatAmount(totalIncome, 0), c: theme.income },
          { l: 'Despesas', v: formatAmount(totalExpense, 0), c: theme.expense },
          { l: thirdKpi.label, v: thirdKpi.value, c: '#7DD3FC' },
        ].map(k => (
          <View key={k.l} style={s.kpiCard}>
            <Text style={s.kpiLabel}>{k.l}</Text>
            <Text style={[s.kpiValue, { color: k.c }]}>{k.v}</Text>
          </View>
        ))}
      </View>

      {/* ── Recent transactions ── */}
      <Text style={s.sectionTitle}>
        {isCurrentMonth ? 'Últimas transações' : `Transações de ${MONTHS_FULL[viewMonth]}`}
      </Text>
      {transactions.length === 0 && (
        <View style={s.emptyBox}>
          <Text style={s.emptyText}>Nenhuma transação neste mês.</Text>
        </View>
      )}
      {transactions.slice(0, 8).map(tx => {
        const cat = categories.find(c => c.slug === tx.cat_id) ?? categories[categories.length - 1];
        return (
          <SwipeableRow key={tx.id} onDelete={() => deleteTransaction(tx.id)}>
            <TouchableOpacity
              style={s.txRow}
              activeOpacity={0.7}
              onPress={() => router.push({
                pathname: '/(app)/adicionar',
                params: { transaction: JSON.stringify(tx) },
              })}
            >
              <View style={[s.txIcon, { backgroundColor: cat?.bg ?? '#233150' }]}>
                <CategoryIcon slug={cat?.slug ?? 'other'} size={18} color={cat?.color ?? theme.textSec} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={s.txDesc}>{tx.description}</Text>
                <Text style={s.txMeta}>{cat?.label} · {tx.date.slice(8)}/{tx.date.slice(5, 7)}</Text>
              </View>
              <Text style={[s.txAmount, { color: tx.type === 'income' ? theme.income : theme.expense }]}>
                {tx.type === 'income' ? '+' : '-'}{formatAmount(tx.amount)}
              </Text>
            </TouchableOpacity>
          </SwipeableRow>
        );
      })}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { paddingTop: 20, paddingBottom: 22 },
  headerTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18, paddingHorizontal: 20 },
  greeting: { fontSize: 17, fontWeight: '700', color: theme.gold, letterSpacing: -0.2 },
  bellBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center' },
  monthRow: { marginBottom: 22 },
  balLabel: { fontSize: 11, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.8, marginBottom: 6, paddingHorizontal: 20 },
  balance: { fontSize: 32, fontWeight: '700', color: theme.white, letterSpacing: -0.5, marginBottom: 16, paddingHorizontal: 20 },
  barBg: { height: 5, backgroundColor: 'rgba(255,255,255,.1)', borderRadius: 3, marginBottom: 8, marginHorizontal: 20 },
  barFill: { height: 5, borderRadius: 3, backgroundColor: theme.gold },
  barRow: { flexDirection: 'row', justifyContent: 'space-between', paddingHorizontal: 20 },
  barText: { fontSize: 11, color: theme.textSec },
  kpiRow: { flexDirection: 'row', gap: 8, padding: 14, paddingHorizontal: 20 },
  kpiCard: { flex: 1, backgroundColor: theme.surface, borderRadius: 14, padding: 12, alignItems: 'center', borderWidth: 1, borderColor: theme.border },
  kpiLabel: { fontSize: 9, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 },
  kpiValue: { fontSize: 15, fontWeight: '800', letterSpacing: -0.4 },
  sectionTitle: { fontSize: 15, fontWeight: '700', color: theme.white, marginHorizontal: 16, marginTop: 8, marginBottom: 12, letterSpacing: -0.2 },
  emptyBox: { marginHorizontal: 16, padding: 24, backgroundColor: theme.surface, borderRadius: 14, borderWidth: 1, borderColor: theme.border, alignItems: 'center' },
  emptyText: { color: theme.textSec, fontSize: 13 },
  txRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginHorizontal: 16, marginBottom: 8, padding: 12, borderRadius: 12, backgroundColor: theme.surface, borderWidth: 1, borderColor: theme.border },
  txIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  txDesc: { fontSize: 14, fontWeight: '600', color: theme.white, letterSpacing: -0.1 },
  txMeta: { fontSize: 11, color: theme.textSec, marginTop: 2 },
  txAmount: { fontSize: 15, fontWeight: '800', letterSpacing: -0.3 },
});
FILEEOF

npm install
npx tsc --noEmit

echo "Verificando autolinking dos modulos nativos..."
npx expo-modules-autolinking react-native-config --json --platform ios 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
deps = data.get('dependencies', {})
missing = [p for p in ['react-native-purchases', 'react-native-gesture-handler'] if p not in deps]
if missing:
    print('FALTOU:', missing)
    sys.exit(1)
print('OK: ambos os modulos serao linkados')
"

echo "Tudo OK. Fazendo commit..."
git add -A
git commit -m "Combine gesture-handler swipe-to-delete + RevenueCat SDK with privacy toggle, theme, month selector and projections updates"
git push

echo ""
echo "Pronto! Agora e so gerar o build de producao para o TestFlight:"
echo "  eas build --platform ios --profile production --auto-submit"
echo ""
echo "(ou sem --auto-submit se preferir revisar antes de enviar pro TestFlight manualmente)"
