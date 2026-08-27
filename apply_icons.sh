#!/bin/bash
set -e
echo "Trocando emojis por icones de linha..."
mkdir -p src/components

mkdir -p "$(dirname "src/components/Icons.tsx")"
cat > "src/components/Icons.tsx" << 'FILEEOF'
import React from 'react';
import { View } from 'react-native';

interface IconProps {
  size?: number;
  color?: string;
  strokeWidth?: number;
}

/** Draws a straight line between two points using the same center-rotation
 *  technique as LineChart, which works reliably across RN versions. */
function Segment({
  x1, y1, x2, y2, color, thickness,
}: { x1: number; y1: number; x2: number; y2: number; color: string; thickness: number }) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const dist = Math.sqrt(dx * dx + dy * dy);
  const angle = Math.atan2(dy, dx) * (180 / Math.PI);
  const midX = (x1 + x2) / 2;
  const midY = (y1 + y2) / 2;
  return (
    <View
      style={{
        position: 'absolute',
        left: midX - dist / 2,
        top: midY - thickness / 2,
        width: dist,
        height: thickness,
        backgroundColor: color,
        borderRadius: thickness / 2,
        transform: [{ rotate: `${angle}deg` }],
      }}
    />
  );
}

export function BellIcon({ size = 20, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{ width: size, height: size, alignItems: 'center' }}>
      <View
        style={{
          width: size * 0.62,
          height: size * 0.5,
          borderWidth: strokeWidth,
          borderColor: color,
          borderBottomWidth: 0,
          borderTopLeftRadius: size * 0.31,
          borderTopRightRadius: size * 0.31,
        }}
      />
      <View style={{ width: size * 0.8, height: strokeWidth, backgroundColor: color, borderRadius: 1 }} />
      <View
        style={{
          width: size * 0.16,
          height: size * 0.16,
          borderRadius: size * 0.08,
          backgroundColor: color,
          marginTop: size * 0.06,
        }}
      />
    </View>
  );
}

export function CalendarIcon({ size = 20, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{ width: size, height: size }}>
      <View
        style={{
          width: size,
          height: size * 0.85,
          marginTop: size * 0.15,
          borderWidth: strokeWidth,
          borderColor: color,
          borderRadius: 3,
        }}
      >
        <View style={{ height: size * 0.22, borderBottomWidth: strokeWidth, borderColor: color }} />
      </View>
      <View style={{ position: 'absolute', top: 0, left: size * 0.22, width: strokeWidth, height: size * 0.28, backgroundColor: color }} />
      <View style={{ position: 'absolute', top: 0, right: size * 0.22, width: strokeWidth, height: size * 0.28, backgroundColor: color }} />
    </View>
  );
}

export function HomeIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <Segment x1={w * 0.08} y1={h * 0.5} x2={w * 0.5} y2={h * 0.08} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.5} y1={h * 0.08} x2={w * 0.92} y2={h * 0.5} color={color} thickness={strokeWidth} />
      <View
        style={{
          position: 'absolute', left: w * 0.2, top: h * 0.42, width: w * 0.6, height: h * 0.5,
          borderWidth: strokeWidth, borderColor: color, borderTopWidth: 0,
        }}
      />
    </View>
  );
}

export function BarChartIcon({ size = 22, color = '#FFFFFF' }: IconProps) {
  return (
    <View style={{ width: size, height: size, flexDirection: 'row', alignItems: 'flex-end', gap: size * 0.12 }}>
      <View style={{ width: size * 0.2, height: size * 0.45, backgroundColor: color, borderRadius: 1 }} />
      <View style={{ width: size * 0.2, height: size * 0.7, backgroundColor: color, borderRadius: 1 }} />
      <View style={{ width: size * 0.2, height: size * 0.95, backgroundColor: color, borderRadius: 1 }} />
    </View>
  );
}

export function TargetIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View
      style={{
        width: size, height: size, borderRadius: size / 2,
        borderWidth: strokeWidth, borderColor: color,
        alignItems: 'center', justifyContent: 'center',
      }}
    >
      <View
        style={{
          width: size * 0.6, height: size * 0.6, borderRadius: size * 0.3,
          borderWidth: strokeWidth, borderColor: color,
          alignItems: 'center', justifyContent: 'center',
        }}
      >
        <View style={{ width: size * 0.24, height: size * 0.24, borderRadius: size * 0.12, backgroundColor: color }} />
      </View>
    </View>
  );
}

export function TrendingUpIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size;
  const p1 = { x: w * 0.06, y: h * 0.78 };
  const p2 = { x: w * 0.4, y: h * 0.46 };
  const p3 = { x: w * 0.62, y: h * 0.62 };
  const p4 = { x: w * 0.95, y: h * 0.18 };
  return (
    <View style={{ width: w, height: h }}>
      <Segment x1={p1.x} y1={p1.y} x2={p2.x} y2={p2.y} color={color} thickness={strokeWidth} />
      <Segment x1={p2.x} y1={p2.y} x2={p3.x} y2={p3.y} color={color} thickness={strokeWidth} />
      <Segment x1={p3.x} y1={p3.y} x2={p4.x} y2={p4.y} color={color} thickness={strokeWidth} />
      {/* arrow head at the top-right end */}
      <Segment x1={p4.x} y1={p4.y} x2={p4.x - w * 0.22} y2={p4.y} color={color} thickness={strokeWidth} />
      <Segment x1={p4.x} y1={p4.y} x2={p4.x} y2={p4.y + h * 0.22} color={color} thickness={strokeWidth} />
    </View>
  );
}

export function PlusIcon({ size = 24, color = '#FFFFFF', strokeWidth = 2.2 }: IconProps) {
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ position: 'absolute', width: size * 0.7, height: strokeWidth, backgroundColor: color, borderRadius: 2 }} />
      <View style={{ position: 'absolute', width: strokeWidth, height: size * 0.7, backgroundColor: color, borderRadius: 2 }} />
    </View>
  );
}
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/_layout.tsx")"
cat > "app/(app)/(tabs)/_layout.tsx" << 'FILEEOF'
import React from 'react';
import { Tabs, useRouter } from 'expo-router';
import { View, TouchableOpacity, Platform, StyleSheet } from 'react-native';
import { theme } from '../../../src/theme';
import { HomeIcon, BarChartIcon, TargetIcon, TrendingUpIcon, PlusIcon } from '../../../src/components/Icons';

export default function TabsLayout() {
  const router = useRouter();

  return (
    <View style={{ flex: 1 }}>
      <Tabs
        screenOptions={{
          headerShown: false,
          tabBarActiveTintColor: theme.gold,
          tabBarInactiveTintColor: theme.textTer,
          tabBarStyle: {
            backgroundColor: theme.surface,
            borderTopColor: theme.border,
            borderTopWidth: 1,
            height: Platform.OS === 'ios' ? 88 : 64,
            paddingTop: 8,
          },
          tabBarLabelStyle: { fontSize: 11, fontWeight: '600' },
        }}
      >
        <Tabs.Screen
          name="index"
          options={{
            title: 'Resumo',
            tabBarIcon: ({ color }) => <HomeIcon size={22} color={color} />,
          }}
        />
        <Tabs.Screen
          name="analise"
          options={{
            title: 'Análise',
            tabBarIcon: ({ color }) => <BarChartIcon size={22} color={color} />,
          }}
        />
        <Tabs.Screen
          name="orcamento"
          options={{
            title: 'Orçamento',
            tabBarIcon: ({ color }) => <TargetIcon size={22} color={color} />,
          }}
        />
        <Tabs.Screen
          name="projecoes"
          options={{
            title: 'Projeções',
            tabBarIcon: ({ color }) => <TrendingUpIcon size={22} color={color} />,
          }}
        />
      </Tabs>

      {/* Floating action button — opens the "add transaction" modal */}
      <TouchableOpacity
        style={styles.fab}
        activeOpacity={0.85}
        onPress={() => router.push('/(app)/adicionar')}
      >
        <PlusIcon size={24} color={theme.bg} strokeWidth={2.4} />
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  fab: {
    position: 'absolute',
    right: 20,
    bottom: Platform.OS === 'ios' ? 104 : 80,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: theme.gold,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 8,
    elevation: 6,
  },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/index.tsx")"
cat > "app/(app)/(tabs)/index.tsx" << 'FILEEOF'
/**
 * app/(app)/(tabs)/index.tsx  →  Summary / Dashboard tab
 */

import React, { useMemo, useState, useCallback } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { useAuth }         from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget }       from '../../../src/hooks/useBudget';
import { useCategories }   from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';
import { BellIcon, CalendarIcon } from '../../../src/components/Icons';

const now = new Date();

export default function SummaryScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();

  const [viewYear, setViewYear] = useState(now.getFullYear());
  const [viewMonth, setViewMonth] = useState(now.getMonth());
  const isCurrentMonth = viewYear === now.getFullYear() && viewMonth === now.getMonth();

  const userId = user?.id ?? '';
  const monthYear = `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}`;

  const { transactions, loading: txLoading, refresh: refreshTx } = useTransactions({ userId, year: viewYear, month: viewMonth });
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
        value: fCHF(Math.max(0, remaining) / Math.max(1, daysInMonth - now.getDate()), 0),
      }
    : {
        label: 'Média/dia',
        value: fCHF(totalExpense / daysInMonth, 0),
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
          <View style={s.bellBtn}>
            <BellIcon size={16} color={theme.gold} />
          </View>
        </View>

        <View style={s.monthRow}>
          <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} />
          <TouchableOpacity
            style={s.calendarBtn}
            onPress={() => { setViewYear(now.getFullYear()); setViewMonth(now.getMonth()); }}
          >
            <CalendarIcon size={16} color={theme.gold} />
          </TouchableOpacity>
        </View>

        <Text style={s.balLabel}>SALDO DISPONÍVEL</Text>
        <Text style={s.balance}>{fCHF(remaining)}</Text>

        <View style={s.barBg}>
          <View style={[s.barFill, {
            width: `${Math.min(100, Math.round((totalExpense / (totalBudget || 1)) * 100))}%`,
          }]} />
        </View>

        <View style={s.barRow}>
          <Text style={s.barText}>Gasto: {fCHF(totalExpense, 0)}</Text>
          <Text style={s.barText}>Orçamento: {fCHF(totalBudget, 0)}</Text>
        </View>
      </View>

      {/* ── KPIs ── */}
      <View style={s.kpiRow}>
        {[
          { l: 'Receitas', v: fCHF(totalIncome, 0), c: theme.income },
          { l: 'Despesas', v: fCHF(totalExpense, 0), c: theme.expense },
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
          <View key={tx.id} style={s.txRow}>
            <View style={[s.txIcon, { backgroundColor: cat?.bg ?? '#233150' }]}>
              <Text style={{ fontSize: 18 }}>{cat?.icon ?? '📦'}</Text>
            </View>
            <View style={{ flex: 1 }}>
              <Text style={s.txDesc}>{tx.description}</Text>
              <Text style={s.txMeta}>{cat?.label} · {tx.date.slice(8)}/{tx.date.slice(5, 7)}</Text>
            </View>
            <Text style={[s.txAmount, { color: tx.type === 'income' ? theme.income : theme.expense }]}>
              {tx.type === 'income' ? '+' : '-'}{fCHF(tx.amount)}
            </Text>
          </View>
        );
      })}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { padding: 20, paddingBottom: 22 },
  headerTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18 },
  greeting: { fontSize: 17, fontWeight: '700', color: theme.gold, letterSpacing: -0.2 },
  bellBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center' },
  bellIcon: { fontSize: 15 },
  monthRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 22 },
  calendarBtn: { width: 36, height: 36, borderRadius: 10, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: theme.border },
  calendarIcon: { fontSize: 15 },
  balLabel: { fontSize: 11, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.8, marginBottom: 6 },
  balance: { fontSize: 32, fontWeight: '700', color: theme.white, letterSpacing: -0.5, marginBottom: 16 },
  barBg: { height: 5, backgroundColor: 'rgba(255,255,255,.1)', borderRadius: 3, marginBottom: 8 },
  barFill: { height: 5, borderRadius: 3, backgroundColor: theme.gold },
  barRow: { flexDirection: 'row', justifyContent: 'space-between' },
  barText: { fontSize: 11, color: theme.textSec },
  kpiRow: { flexDirection: 'row', gap: 8, padding: 14 },
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

mkdir -p "$(dirname "app/(app)/(tabs)/analise.tsx")"
cat > "app/(app)/(tabs)/analise.tsx" << 'FILEEOF'
import React, { useMemo, useState, useCallback } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { useAuth } from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget, useCategories } from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';
import { CalendarIcon } from '../../../src/components/Icons';

const now = new Date();

export default function AnaliseScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();
  const userId = user?.id ?? '';

  const [viewYear, setViewYear] = useState(now.getFullYear());
  const [viewMonth, setViewMonth] = useState(now.getMonth());
  const monthYear = `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}`;

  const { transactions, loading: txLoading, refresh: refreshTx } = useTransactions({ userId, year: viewYear, month: viewMonth });
  const { categories, loading: catLoading, refresh: refreshCategories } = useCategories(userId);
  const { budget, loading: budLoading, refresh: refreshBudget } = useBudget(userId, monthYear);

  useFocusEffect(
    useCallback(() => {
      if (!userId) return;
      refreshTx();
      refreshCategories();
      refreshBudget();
    }, [userId, refreshTx, refreshCategories, refreshBudget])
  );

  const loading = txLoading || catLoading || budLoading;

  const { byCategory, totalExpense, totalIncome } = useMemo(() => {
    const expenseTxs = transactions.filter(t => t.type === 'expense');
    const totalExpense = expenseTxs.reduce((s, t) => s + t.amount, 0);
    const totalIncome = transactions
      .filter(t => t.type === 'income')
      .reduce((s, t) => s + t.amount, 0);

    const grouped = new Map<string, number>();
    for (const t of expenseTxs) {
      grouped.set(t.cat_id, (grouped.get(t.cat_id) ?? 0) + t.amount);
    }

    const byCategory = Array.from(grouped.entries())
      .map(([catId, amount]) => {
        const cat = categories.find(c => c.slug === catId);
        const goal = budget[catId] ?? 0;
        const budgetPct = goal > 0 ? Math.round((amount / goal) * 100) : null;
        return {
          catId,
          amount,
          label: cat?.label ?? catId,
          icon: cat?.icon ?? '📦',
          color: cat?.color ?? theme.gold,
          pct: totalExpense > 0 ? Math.round((amount / totalExpense) * 100) : 0,
          goal,
          budgetPct,
        };
      })
      .sort((a, b) => b.amount - a.amount);

    return { byCategory, totalExpense, totalIncome };
  }, [transactions, categories, budget]);

  if (!user || loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.gold} />
      </View>
    );
  }

  const maxAmount = byCategory[0]?.amount ?? 1;

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <Text style={s.title}>Análise</Text>
        <View style={s.monthRow}>
          <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} />
          <View style={s.calendarBtn}>
            <CalendarIcon size={16} color={theme.gold} />
          </View>
        </View>
      </View>

      <View style={s.kpiRow}>
        <View style={s.kpiCard}>
          <Text style={s.kpiLabel}>RECEITAS</Text>
          <Text style={[s.kpiValue, { color: theme.income }]}>{fCHF(totalIncome, 0)}</Text>
        </View>
        <View style={s.kpiCard}>
          <Text style={s.kpiLabel}>DESPESAS</Text>
          <Text style={[s.kpiValue, { color: theme.expense }]}>{fCHF(totalExpense, 0)}</Text>
        </View>
      </View>

      <Text style={s.sectionTitle}>Gastos por categoria</Text>

      {byCategory.length === 0 ? (
        <View style={s.emptyBox}>
          <Text style={s.emptyText}>Nenhuma despesa registrada em {MONTHS_FULL[viewMonth]}.</Text>
        </View>
      ) : (
        <View style={{ paddingHorizontal: 16, gap: 10 }}>
          {byCategory.map(c => {
            const overBudget = c.budgetPct !== null && c.budgetPct > 100;
            return (
              <View key={c.catId} style={s.catCard}>
                <View style={s.barLabelRow}>
                  <Text style={s.barLabel}>{c.label}</Text>
                  <Text style={s.barPct}>{c.pct}%</Text>
                </View>
                <View style={s.barTrack}>
                  <View
                    style={[
                      s.barFill,
                      {
                        width: `${Math.max(4, (c.amount / maxAmount) * 100)}%`,
                        backgroundColor: overBudget ? theme.danger : theme.gold,
                      },
                    ]}
                  />
                </View>
                <View style={s.bottomRow}>
                  <Text style={s.barAmount}>{fCHF(c.amount, 0)}</Text>
                  {c.budgetPct !== null && (
                    <View style={[s.budgetBadge, overBudget && s.budgetBadgeOver]}>
                      <Text style={[s.budgetBadgeText, overBudget && s.budgetBadgeTextOver]}>
                        {c.budgetPct}% do orçamento
                      </Text>
                    </View>
                  )}
                </View>
              </View>
            );
          })}
        </View>
      )}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { padding: 20, paddingBottom: 12, gap: 12 },
  title: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5 },
  monthRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  calendarBtn: { width: 36, height: 36, borderRadius: 10, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: theme.border },
  calendarIcon: { fontSize: 15 },
  kpiRow: { flexDirection: 'row', gap: 8, paddingHorizontal: 16, marginBottom: 8 },
  kpiCard: {
    flex: 1, backgroundColor: theme.surface, borderRadius: 14, padding: 14,
    borderWidth: 1, borderColor: theme.border,
  },
  kpiLabel: { fontSize: 10, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 },
  kpiValue: { fontSize: 18, fontWeight: '800' },
  sectionTitle: {
    fontSize: 15, fontWeight: '700', color: theme.white,
    marginHorizontal: 16, marginTop: 16, marginBottom: 10, letterSpacing: -0.2,
  },
  emptyBox: {
    marginHorizontal: 16, padding: 24, backgroundColor: theme.surface,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, alignItems: 'center',
  },
  emptyText: { color: theme.textSec, fontSize: 13, textAlign: 'center' },
  catCard: {
    backgroundColor: theme.surface, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, gap: 8,
  },
  barLabelRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  barLabel: { fontSize: 14, fontWeight: '700', color: theme.white },
  barPct: { fontSize: 13, color: theme.textSec, fontWeight: '600' },
  barTrack: { height: 6, backgroundColor: 'rgba(255,255,255,.08)', borderRadius: 3, overflow: 'hidden' },
  barFill: { height: 6, borderRadius: 3 },
  bottomRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  barAmount: { fontSize: 12, color: theme.textSec, fontWeight: '600' },
  budgetBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8, backgroundColor: theme.goldSoft },
  budgetBadgeOver: { backgroundColor: 'rgba(248,113,113,0.15)' },
  budgetBadgeText: { fontSize: 10, fontWeight: '700', color: theme.gold },
  budgetBadgeTextOver: { color: theme.danger },
});
FILEEOF

npx tsc --noEmit
echo "TypeScript OK. Fazendo commit..."
git add -A
git commit -m "Replace UI chrome emojis with custom line icons (no new dependency)"
git push
echo "Pronto! Recarrega o app (tecla r) pra ver os icones novos."
