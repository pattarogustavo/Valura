#!/bin/bash
set -e
echo "Aplicando estrutura de navegação por abas..."

mkdir -p "app/(app)/(tabs)"

# Move index.tsx se ainda estiver no lugar antigo
if [ -f "app/(app)/index.tsx" ]; then
  git mv "app/(app)/index.tsx" "app/(app)/(tabs)/index.tsx" 2>/dev/null || mv "app/(app)/index.tsx" "app/(app)/(tabs)/index.tsx"
fi

mkdir -p "$(dirname "src/theme.ts")"
cat > "src/theme.ts" << 'FILEEOF'
// ─── SHARED DESIGN TOKENS ───────────────────────────────────────────────────
// Matches the palette already used in app/(app)/index.tsx (Resumo screen).

export const theme = {
  brand:        '#1756F5',
  brandDark:    '#1248C8',
  text:         '#0A1929',
  textSec:      '#3D5168',
  textTer:      '#8097B1',
  border:       '#D8E4F0',
  white:        '#FFFFFF',
  bg:           '#F2F6FA',
  income:       '#00B374',
  expense:      '#E53935',
  good:         '#00E5A0',
  warn:         '#FFCC32',
  danger:       '#FF5252',
};

export const fCHF = (n: number, d = 2) =>
  'CHF ' + Number(n || 0).toLocaleString('pt-PT', { minimumFractionDigits: d, maximumFractionDigits: d });

export const MONTHS_FULL = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/_layout.tsx")"
cat > "app/(app)/(tabs)/_layout.tsx" << 'FILEEOF'
import React from 'react';
import { Tabs, useRouter } from 'expo-router';
import { View, Text, TouchableOpacity, Platform, StyleSheet } from 'react-native';
import { theme } from '../../../src/theme';

function TabIcon({ emoji, focused }: { emoji: string; focused: boolean }) {
  return (
    <Text style={{ fontSize: 22, opacity: focused ? 1 : 0.5 }}>{emoji}</Text>
  );
}

export default function TabsLayout() {
  const router = useRouter();

  return (
    <View style={{ flex: 1 }}>
      <Tabs
        screenOptions={{
          headerShown: false,
          tabBarActiveTintColor: theme.brand,
          tabBarInactiveTintColor: theme.textTer,
          tabBarStyle: {
            borderTopColor: theme.border,
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
            tabBarIcon: ({ focused }) => <TabIcon emoji="🏠" focused={focused} />,
          }}
        />
        <Tabs.Screen
          name="analise"
          options={{
            title: 'Análise',
            tabBarIcon: ({ focused }) => <TabIcon emoji="📊" focused={focused} />,
          }}
        />
        <Tabs.Screen
          name="orcamento"
          options={{
            title: 'Orçamento',
            tabBarIcon: ({ focused }) => <TabIcon emoji="🎯" focused={focused} />,
          }}
        />
        <Tabs.Screen
          name="projecoes"
          options={{
            title: 'Projeções',
            tabBarIcon: ({ focused }) => <TabIcon emoji="📈" focused={focused} />,
          }}
        />
      </Tabs>

      {/* Floating action button — opens the "add transaction" modal */}
      <TouchableOpacity
        style={styles.fab}
        activeOpacity={0.85}
        onPress={() => router.push('/(app)/adicionar')}
      >
        <Text style={styles.fabIcon}>+</Text>
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
    backgroundColor: theme.brand,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 8,
    elevation: 6,
  },
  fabIcon: {
    fontSize: 30,
    color: theme.white,
    fontWeight: '400',
    marginTop: -2,
  },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/index.tsx")"
cat > "app/(app)/(tabs)/index.tsx" << 'FILEEOF'
/**
 * app/(app)/index.tsx  →  Summary / Dashboard tab
 *
 * This is the main entry point for authenticated users.
 * All state now comes from Supabase via the custom hooks.
 *
 * The UI code is the same SummaryScreen from Valura.jsx —
 * only the DATA SOURCE changed from INIT_TX → useTransactions().
 */

import React, { useMemo } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet } from 'react-native';
import { useAuth }         from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget }       from '../../../src/hooks/useBudget';
import { useCategories }   from '../../../src/hooks/useBudget';

const now = new Date();
const CY  = now.getFullYear();
const CM  = now.getMonth();   // 0-indexed

const fCHF = (n: number, d = 2) =>
  'CHF ' + Number(n || 0).toLocaleString('pt-PT', { minimumFractionDigits: d, maximumFractionDigits: d });

const MONTHS_FULL = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];

export default function SummaryScreen() {
  const { user }       = useAuth();
  
  if (!user) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color="#1756F5" />
      </View>
    );
  }
  const userId         = user!.id;
  const monthYear      = `${CY}-${String(CM + 1).padStart(2, '0')}`;

  const { transactions, loading: txLoading }   = useTransactions({ userId, year: CY, month: CM });
  const { budget,       loading: budLoading }  = useBudget(userId, monthYear);
  const { categories,   loading: catLoading }  = useCategories(userId);

  const loading = txLoading || budLoading || catLoading;

  const { totalIncome, totalExpense, remaining, savingsRate } = useMemo(() => {
    const totalIncome  = transactions.filter(t => t.type === 'income' ).reduce((s, t) => s + t.amount, 0);
    const totalExpense = transactions.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0);
    const remaining    = totalIncome - totalExpense;
    const savingsRate  = totalIncome > 0 ? Math.max(0, Math.round((remaining / totalIncome) * 100)) : 0;
    return { totalIncome, totalExpense, remaining, savingsRate };
  }, [transactions]);

  if (loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color="#1756F5" />
      </View>
    );
  }

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 100 }}>
      {/* ── Header ── */}
      <View style={s.header}>
        <Text style={s.greeting}>Bom dia, {user?.profile?.display_name ?? 'Ana'} 👋</Text>
        <Text style={s.month}>{MONTHS_FULL[CM]} {CY}</Text>

        <Text style={s.balLabel}>Saldo disponível</Text>
        <Text style={s.balance}>{fCHF(remaining)}</Text>

        {/* Progress bar */}
        <View style={s.barBg}>
          <View style={[s.barFill, {
            width: `${Math.min(100, Math.round((totalExpense / (Object.values(budget).reduce((s, v) => s + v, 0) || 1)) * 100))}%`,
            backgroundColor: savingsRate > 20 ? '#00E5A0' : savingsRate > 5 ? '#FFCC32' : '#FF5252',
          }]} />
        </View>

        <View style={s.barRow}>
          <Text style={s.barText}>Gasto: {fCHF(totalExpense, 0)}</Text>
          <Text style={s.barText}>Orçamento: {fCHF(Object.values(budget).reduce((s, v) => s + v, 0), 0)}</Text>
        </View>
      </View>

      {/* ── KPIs ── */}
      <View style={s.kpiRow}>
        {[
          { l: 'Receitas',   v: fCHF(totalIncome,  0), c: '#00B374' },
          { l: 'Despesas',   v: fCHF(totalExpense, 0), c: '#E53935' },
          { l: 'Limite/dia', v: fCHF(Math.max(0, remaining) / Math.max(1, new Date(CY, CM + 1, 0).getDate() - now.getDate()), 0), c: '#1756F5' },
        ].map(k => (
          <View key={k.l} style={s.kpiCard}>
            <Text style={s.kpiLabel}>{k.l}</Text>
            <Text style={[s.kpiValue, { color: k.c }]}>{k.v}</Text>
          </View>
        ))}
      </View>

      {/* ── Recent transactions ── */}
      <Text style={s.sectionTitle}>Últimas transações</Text>
      {transactions.slice(0, 8).map(tx => {
        const cat = categories.find(c => c.slug === tx.cat_id) ?? categories[categories.length - 1];
        return (
          <View key={tx.id} style={s.txRow}>
            <View style={[s.txIcon, { backgroundColor: cat?.bg ?? '#F8FAFC' }]}>
              <Text style={{ fontSize: 18 }}>{cat?.icon ?? '📦'}</Text>
            </View>
            <View style={{ flex: 1 }}>
              <Text style={s.txDesc}>{tx.description}</Text>
              <Text style={s.txMeta}>{cat?.label} · {tx.date.slice(8)}/{tx.date.slice(5, 7)}</Text>
            </View>
            <Text style={[s.txAmount, { color: tx.type === 'income' ? '#00B374' : '#E53935' }]}>
              {tx.type === 'income' ? '+' : '-'}{fCHF(tx.amount)}
            </Text>
          </View>
        );
      })}
    </ScrollView>
  );
}

const T = { brand: '#1756F5', text: '#0A1929', textSec: '#3D5168', textTer: '#8097B1', border: '#D8E4F0', white: '#FFFFFF' };

const s = StyleSheet.create({
  center:       { flex: 1, alignItems: 'center', justifyContent: 'center' },
  scroll:       { flex: 1, backgroundColor: '#F2F6FA' },
  header:       { backgroundColor: '#1756F5', padding: 20, paddingBottom: 26 },
  greeting:     { fontSize: 12, color: 'rgba(255,255,255,.55)', marginBottom: 2 },
  month:        { fontSize: 16, fontWeight: '600', color: 'rgba(255,255,255,.9)', marginBottom: 18, letterSpacing: -0.2 },
  balLabel:     { fontSize: 11, color: 'rgba(255,255,255,.55)', textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 5 },
  balance:      { fontSize: 33, fontWeight: '700', color: T.white, letterSpacing: -0.5, marginBottom: 16 },
  barBg:        { height: 5, backgroundColor: 'rgba(255,255,255,.2)', borderRadius: 3, marginBottom: 8 },
  barFill:      { height: 5, borderRadius: 3 },
  barRow:       { flexDirection: 'row', justifyContent: 'space-between' },
  barText:      { fontSize: 11, color: 'rgba(255,255,255,.5)' },
  kpiRow:       { flexDirection: 'row', gap: 8, padding: 14 },
  kpiCard:      { flex: 1, backgroundColor: T.white, borderRadius: 14, padding: 12, alignItems: 'center', borderWidth: 1, borderColor: '#D8E4F0' },
  kpiLabel:     { fontSize: 10, color: T.textTer, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 5 },
  kpiValue:     { fontSize: 16, fontWeight: '800', letterSpacing: -0.4 },
  sectionTitle: { fontSize: 14, fontWeight: '700', color: T.text, marginHorizontal: 16, marginTop: 8, marginBottom: 12, letterSpacing: -0.2 },
  txRow:        { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingVertical: 11, borderBottomWidth: 1, borderColor: '#D8E4F0', backgroundColor: T.white },
  txIcon:       { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  txDesc:       { fontSize: 14, fontWeight: '600', color: T.text, letterSpacing: -0.1 },
  txMeta:       { fontSize: 11, color: T.textTer, marginTop: 2 },
  txAmount:     { fontSize: 15, fontWeight: '800', letterSpacing: -0.3 },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/analise.tsx")"
cat > "app/(app)/(tabs)/analise.tsx" << 'FILEEOF'
import React, { useMemo } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet } from 'react-native';
import { useAuth } from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useCategories } from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';

const now = new Date();
const CY = now.getFullYear();
const CM = now.getMonth();

export default function AnaliseScreen() {
  const { user } = useAuth();
  const userId = user!.id;

  const { transactions, loading: txLoading } = useTransactions({ userId, year: CY, month: CM });
  const { categories, loading: catLoading } = useCategories(userId);

  const loading = txLoading || catLoading;

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
        return {
          catId,
          amount,
          label: cat?.label ?? catId,
          icon: cat?.icon ?? '📦',
          color: cat?.color ?? theme.brand,
          bg: cat?.bg ?? '#F8FAFC',
          pct: totalExpense > 0 ? Math.round((amount / totalExpense) * 100) : 0,
        };
      })
      .sort((a, b) => b.amount - a.amount);

    return { byCategory, totalExpense, totalIncome };
  }, [transactions, categories]);

  if (loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.brand} />
      </View>
    );
  }

  const maxAmount = byCategory[0]?.amount ?? 1;

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={s.header}>
        <Text style={s.title}>Análise</Text>
        <Text style={s.subtitle}>{MONTHS_FULL[CM]} {CY}</Text>
      </View>

      <View style={s.kpiRow}>
        <View style={s.kpiCard}>
          <Text style={s.kpiLabel}>Receitas</Text>
          <Text style={[s.kpiValue, { color: theme.income }]}>{fCHF(totalIncome, 0)}</Text>
        </View>
        <View style={s.kpiCard}>
          <Text style={s.kpiLabel}>Despesas</Text>
          <Text style={[s.kpiValue, { color: theme.expense }]}>{fCHF(totalExpense, 0)}</Text>
        </View>
      </View>

      <Text style={s.sectionTitle}>Gastos por categoria</Text>

      {byCategory.length === 0 ? (
        <View style={s.emptyBox}>
          <Text style={s.emptyText}>Nenhuma despesa registrada este mês ainda.</Text>
        </View>
      ) : (
        <View style={s.chartBox}>
          {byCategory.map(c => (
            <View key={c.catId} style={s.barRow}>
              <View style={s.barLabelRow}>
                <Text style={s.barIcon}>{c.icon}</Text>
                <Text style={s.barLabel} numberOfLines={1}>{c.label}</Text>
                <Text style={s.barPct}>{c.pct}%</Text>
              </View>
              <View style={s.barTrack}>
                <View
                  style={[
                    s.barFill,
                    {
                      width: `${Math.max(4, (c.amount / maxAmount) * 100)}%`,
                      backgroundColor: c.color,
                    },
                  ]}
                />
              </View>
              <Text style={s.barAmount}>{fCHF(c.amount, 0)}</Text>
            </View>
          ))}
        </View>
      )}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { padding: 20, paddingBottom: 12 },
  title: { fontSize: 24, fontWeight: '800', color: theme.text, letterSpacing: -0.5 },
  subtitle: { fontSize: 14, color: theme.textSec, marginTop: 2 },
  kpiRow: { flexDirection: 'row', gap: 8, paddingHorizontal: 16, marginBottom: 8 },
  kpiCard: {
    flex: 1, backgroundColor: theme.white, borderRadius: 14, padding: 14,
    borderWidth: 1, borderColor: theme.border,
  },
  kpiLabel: { fontSize: 11, color: theme.textTer, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 6 },
  kpiValue: { fontSize: 18, fontWeight: '800' },
  sectionTitle: {
    fontSize: 14, fontWeight: '700', color: theme.text,
    marginHorizontal: 16, marginTop: 16, marginBottom: 10, letterSpacing: -0.2,
  },
  emptyBox: {
    marginHorizontal: 16, padding: 24, backgroundColor: theme.white,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, alignItems: 'center',
  },
  emptyText: { color: theme.textTer, fontSize: 13, textAlign: 'center' },
  chartBox: {
    marginHorizontal: 16, backgroundColor: theme.white, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, gap: 16,
  },
  barRow: { gap: 6 },
  barLabelRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  barIcon: { fontSize: 14 },
  barLabel: { flex: 1, fontSize: 13, fontWeight: '600', color: theme.text },
  barPct: { fontSize: 12, color: theme.textTer, fontWeight: '600' },
  barTrack: { height: 8, backgroundColor: '#EEF3F8', borderRadius: 4, overflow: 'hidden' },
  barFill: { height: 8, borderRadius: 4 },
  barAmount: { fontSize: 12, color: theme.textSec, fontWeight: '600' },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/orcamento.tsx")"
cat > "app/(app)/(tabs)/orcamento.tsx" << 'FILEEOF'
import React, { useMemo, useState } from 'react';
import {
  View, Text, ScrollView, ActivityIndicator, StyleSheet,
  TextInput, TouchableOpacity, Keyboard,
} from 'react-native';
import { useAuth } from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget, useCategories } from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';

const now = new Date();
const CY = now.getFullYear();
const CM = now.getMonth();
const monthYear = `${CY}-${String(CM + 1).padStart(2, '0')}`;

export default function OrcamentoScreen() {
  const { user } = useAuth();
  const userId = user!.id;

  const { transactions, loading: txLoading } = useTransactions({ userId, year: CY, month: CM });
  const { budget, loading: budLoading, updateBudget } = useBudget(userId, monthYear);
  const { categories, loading: catLoading } = useCategories(userId);

  const [editingId, setEditingId] = useState<string | null>(null);
  const [draftValue, setDraftValue] = useState('');

  const loading = txLoading || budLoading || catLoading;

  const spentByCategory = useMemo(() => {
    const map = new Map<string, number>();
    for (const t of transactions.filter(t => t.type === 'expense')) {
      map.set(t.cat_id, (map.get(t.cat_id) ?? 0) + t.amount);
    }
    return map;
  }, [transactions]);

  const expenseCategories = categories.filter(c => c.type === 'expense');

  const totalBudget = Object.values(budget).reduce((s, v) => s + v, 0);
  const totalSpent = Array.from(spentByCategory.values()).reduce((s, v) => s + v, 0);

  const startEditing = (catId: string) => {
    setEditingId(catId);
    setDraftValue(budget[catId] ? String(budget[catId]) : '');
  };

  const commitEdit = async (catId: string) => {
    const amount = parseFloat(draftValue.replace(',', '.')) || 0;
    setEditingId(null);
    Keyboard.dismiss();
    await updateBudget({ cat_id: catId, amount, month_year: monthYear });
  };

  if (loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.brand} />
      </View>
    );
  }

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={s.header}>
        <Text style={s.title}>Orçamento</Text>
        <Text style={s.subtitle}>{MONTHS_FULL[CM]} {CY}</Text>
      </View>

      <View style={s.summaryCard}>
        <Text style={s.summaryLabel}>Total orçado</Text>
        <Text style={s.summaryValue}>{fCHF(totalBudget, 0)}</Text>
        <View style={s.barTrack}>
          <View
            style={[
              s.barFill,
              {
                width: `${totalBudget > 0 ? Math.min(100, (totalSpent / totalBudget) * 100) : 0}%`,
                backgroundColor: totalSpent > totalBudget && totalBudget > 0 ? theme.danger : theme.brand,
              },
            ]}
          />
        </View>
        <Text style={s.summaryHint}>
          Gasto: {fCHF(totalSpent, 0)} de {fCHF(totalBudget, 0)}
        </Text>
      </View>

      <Text style={s.sectionTitle}>Metas por categoria</Text>

      {expenseCategories.length === 0 ? (
        <View style={s.emptyBox}>
          <Text style={s.emptyText}>Nenhuma categoria de despesa cadastrada ainda.</Text>
        </View>
      ) : (
        <View style={{ gap: 10, paddingHorizontal: 16 }}>
          {expenseCategories.map(cat => {
            const spent = spentByCategory.get(cat.slug) ?? 0;
            const goal = budget[cat.slug] ?? 0;
            const pct = goal > 0 ? Math.min(100, Math.round((spent / goal) * 100)) : 0;
            const over = goal > 0 && spent > goal;

            return (
              <View key={cat.id} style={s.catCard}>
                <View style={s.catRow}>
                  <View style={[s.catIconWrap, { backgroundColor: cat.bg }]}>
                    <Text style={{ fontSize: 16 }}>{cat.icon}</Text>
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={s.catLabel}>{cat.label}</Text>
                    <Text style={s.catSpent}>
                      {fCHF(spent, 0)} {goal > 0 ? `de ${fCHF(goal, 0)}` : 'gasto'}
                    </Text>
                  </View>

                  {editingId === cat.slug ? (
                    <TextInput
                      style={s.input}
                      value={draftValue}
                      onChangeText={setDraftValue}
                      keyboardType="decimal-pad"
                      autoFocus
                      onBlur={() => commitEdit(cat.slug)}
                      onSubmitEditing={() => commitEdit(cat.slug)}
                      placeholder="0"
                    />
                  ) : (
                    <TouchableOpacity onPress={() => startEditing(cat.slug)}>
                      <Text style={s.editLink}>{goal > 0 ? 'Editar' : 'Definir'}</Text>
                    </TouchableOpacity>
                  )}
                </View>

                {goal > 0 && (
                  <View style={s.catBarTrack}>
                    <View
                      style={[
                        s.catBarFill,
                        { width: `${pct}%`, backgroundColor: over ? theme.danger : cat.color },
                      ]}
                    />
                  </View>
                )}
              </View>
            );
          })}
        </View>
      )}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { padding: 20, paddingBottom: 12 },
  title: { fontSize: 24, fontWeight: '800', color: theme.text, letterSpacing: -0.5 },
  subtitle: { fontSize: 14, color: theme.textSec, marginTop: 2 },
  summaryCard: {
    marginHorizontal: 16, backgroundColor: theme.white, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, marginBottom: 8,
  },
  summaryLabel: { fontSize: 11, color: theme.textTer, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 4 },
  summaryValue: { fontSize: 22, fontWeight: '800', color: theme.text, marginBottom: 10 },
  summaryHint: { fontSize: 12, color: theme.textSec, marginTop: 6 },
  barTrack: { height: 8, backgroundColor: '#EEF3F8', borderRadius: 4, overflow: 'hidden' },
  barFill: { height: 8, borderRadius: 4 },
  sectionTitle: {
    fontSize: 14, fontWeight: '700', color: theme.text,
    marginHorizontal: 16, marginTop: 12, marginBottom: 10, letterSpacing: -0.2,
  },
  emptyBox: {
    marginHorizontal: 16, padding: 24, backgroundColor: theme.white,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, alignItems: 'center',
  },
  emptyText: { color: theme.textTer, fontSize: 13, textAlign: 'center' },
  catCard: {
    backgroundColor: theme.white, borderRadius: 14, borderWidth: 1,
    borderColor: theme.border, padding: 12,
  },
  catRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  catIconWrap: { width: 36, height: 36, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  catLabel: { fontSize: 14, fontWeight: '700', color: theme.text },
  catSpent: { fontSize: 12, color: theme.textTer, marginTop: 2 },
  editLink: { fontSize: 13, fontWeight: '700', color: theme.brand },
  input: {
    width: 80, borderWidth: 1, borderColor: theme.brand, borderRadius: 8,
    paddingHorizontal: 8, paddingVertical: 6, fontSize: 14, textAlign: 'right',
    color: theme.text,
  },
  catBarTrack: { height: 5, backgroundColor: '#EEF3F8', borderRadius: 3, overflow: 'hidden', marginTop: 10 },
  catBarFill: { height: 5, borderRadius: 3 },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/projecoes.tsx")"
cat > "app/(app)/(tabs)/projecoes.tsx" << 'FILEEOF'
import React, { useMemo, useState } from 'react';
import { View, Text, ScrollView, StyleSheet, TextInput } from 'react-native';
import { useAuth } from '../../../src/context/AuthContext';
import { theme, fCHF } from '../../../src/theme';

interface YearProjection {
  year: number;
  contributed: number;
  value: number;
}

function project(
  startingValue: number,
  monthlyContribution: number,
  annualRatePct: number,
  years: number
): YearProjection[] {
  const monthlyRate = annualRatePct / 100 / 12;
  let value = startingValue;
  let contributed = startingValue;
  const results: YearProjection[] = [];

  for (let y = 1; y <= years; y++) {
    for (let m = 0; m < 12; m++) {
      value = value * (1 + monthlyRate) + monthlyContribution;
      contributed += monthlyContribution;
    }
    results.push({ year: y, contributed, value });
  }
  return results;
}

export default function ProjecoesScreen() {
  const { user } = useAuth();
  const profile = user?.profile;

  const [startingValue, setStartingValue] = useState(String(profile?.net_worth ?? 0));
  const [monthlyContribution, setMonthlyContribution] = useState(
    String(profile?.monthly_income ? Math.round(profile.monthly_income * 0.2) : 500)
  );
  const [annualRate, setAnnualRate] = useState('5');
  const [years, setYears] = useState('10');

  const results = useMemo(() => {
    const sv = parseFloat(startingValue.replace(',', '.')) || 0;
    const mc = parseFloat(monthlyContribution.replace(',', '.')) || 0;
    const rate = parseFloat(annualRate.replace(',', '.')) || 0;
    const yrs = Math.max(1, Math.min(50, parseInt(years, 10) || 1));
    return project(sv, mc, rate, yrs);
  }, [startingValue, monthlyContribution, annualRate, years]);

  const final = results[results.length - 1];
  const maxValue = final?.value ?? 1;

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={s.header}>
        <Text style={s.title}>Projeções</Text>
        <Text style={s.subtitle}>Simule a evolução do seu patrimônio</Text>
      </View>

      <View style={s.formCard}>
        <Field label="Patrimônio inicial (CHF)" value={startingValue} onChangeText={setStartingValue} />
        <Field label="Aporte mensal (CHF)" value={monthlyContribution} onChangeText={setMonthlyContribution} />
        <Field label="Rentabilidade anual (%)" value={annualRate} onChangeText={setAnnualRate} />
        <Field label="Período (anos)" value={years} onChangeText={setYears} />
      </View>

      {final && (
        <View style={s.resultCard}>
          <Text style={s.resultLabel}>Patrimônio estimado em {final.year} {final.year === 1 ? 'ano' : 'anos'}</Text>
          <Text style={s.resultValue}>{fCHF(final.value, 0)}</Text>
          <View style={s.resultRow}>
            <Text style={s.resultSub}>Total aportado: {fCHF(final.contributed, 0)}</Text>
            <Text style={[s.resultSub, { color: theme.income }]}>
              Rendimento: {fCHF(final.value - final.contributed, 0)}
            </Text>
          </View>
        </View>
      )}

      <Text style={s.sectionTitle}>Evolução ano a ano</Text>

      <View style={s.chartBox}>
        {results.map(r => (
          <View key={r.year} style={s.barRow}>
            <Text style={s.barYear}>Ano {r.year}</Text>
            <View style={s.barTrack}>
              <View
                style={[
                  s.barContributed,
                  { width: `${Math.max(2, (r.contributed / maxValue) * 100)}%` },
                ]}
              />
              <View
                style={[
                  s.barTotal,
                  { width: `${Math.max(2, (r.value / maxValue) * 100)}%` },
                ]}
              />
            </View>
            <Text style={s.barValue}>{fCHF(r.value, 0)}</Text>
          </View>
        ))}

        <View style={s.legendRow}>
          <View style={s.legendItem}>
            <View style={[s.legendDot, { backgroundColor: theme.border }]} />
            <Text style={s.legendText}>Aportado</Text>
          </View>
          <View style={s.legendItem}>
            <View style={[s.legendDot, { backgroundColor: theme.brand }]} />
            <Text style={s.legendText}>Total (com rendimento)</Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

function Field({
  label, value, onChangeText,
}: { label: string; value: string; onChangeText: (v: string) => void }) {
  return (
    <View style={s.fieldRow}>
      <Text style={s.fieldLabel}>{label}</Text>
      <TextInput
        style={s.fieldInput}
        value={value}
        onChangeText={onChangeText}
        keyboardType="decimal-pad"
      />
    </View>
  );
}

const s = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { padding: 20, paddingBottom: 12 },
  title: { fontSize: 24, fontWeight: '800', color: theme.text, letterSpacing: -0.5 },
  subtitle: { fontSize: 14, color: theme.textSec, marginTop: 2 },
  formCard: {
    marginHorizontal: 16, backgroundColor: theme.white, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, gap: 12,
  },
  fieldRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  fieldLabel: { fontSize: 13, color: theme.textSec, flex: 1 },
  fieldInput: {
    width: 110, borderWidth: 1, borderColor: theme.border, borderRadius: 8,
    paddingHorizontal: 10, paddingVertical: 8, fontSize: 14, textAlign: 'right', color: theme.text,
  },
  resultCard: {
    marginHorizontal: 16, marginTop: 12, backgroundColor: theme.brand,
    borderRadius: 14, padding: 18,
  },
  resultLabel: { fontSize: 12, color: 'rgba(255,255,255,.7)', marginBottom: 4 },
  resultValue: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5, marginBottom: 10 },
  resultRow: { flexDirection: 'row', justifyContent: 'space-between' },
  resultSub: { fontSize: 12, color: 'rgba(255,255,255,.85)', fontWeight: '600' },
  sectionTitle: {
    fontSize: 14, fontWeight: '700', color: theme.text,
    marginHorizontal: 16, marginTop: 18, marginBottom: 10, letterSpacing: -0.2,
  },
  chartBox: {
    marginHorizontal: 16, backgroundColor: theme.white, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, gap: 12,
  },
  barRow: { gap: 4 },
  barYear: { fontSize: 12, fontWeight: '600', color: theme.textSec },
  barTrack: { height: 14, justifyContent: 'center' },
  barContributed: {
    position: 'absolute', height: 14, borderRadius: 4, backgroundColor: theme.border,
  },
  barTotal: {
    position: 'absolute', height: 6, top: 4, borderRadius: 3, backgroundColor: theme.brand,
  },
  barValue: { fontSize: 12, color: theme.text, fontWeight: '700', marginTop: 2 },
  legendRow: { flexDirection: 'row', gap: 16, marginTop: 8 },
  legendItem: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  legendDot: { width: 8, height: 8, borderRadius: 4 },
  legendText: { fontSize: 11, color: theme.textTer },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/_layout.tsx")"
cat > "app/(app)/_layout.tsx" << 'FILEEOF'
import React from 'react';
import { Stack } from 'expo-router';

export default function AppLayout() {
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(tabs)" />
      <Stack.Screen name="adicionar" options={{ presentation: 'modal' }} />
    </Stack>
  );
}
FILEEOF

mkdir -p "$(dirname "app/(app)/adicionar.tsx")"
cat > "app/(app)/adicionar.tsx" << 'FILEEOF'
import React, { useState, useMemo } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TextInput,
  TouchableOpacity, KeyboardAvoidingView, Platform, Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';
import { useTransactions } from '../../src/hooks/useTransactions';
import { useCategories } from '../../src/hooks/useBudget';
import { theme } from '../../src/theme';

const now = new Date();

export default function AdicionarScreen() {
  const router = useRouter();
  const { user } = useAuth();
  const userId = user!.id;

  const { categories } = useCategories(userId);
  const { addTransaction } = useTransactions({
    userId, year: now.getFullYear(), month: now.getMonth(),
  });

  const [type, setType] = useState<'expense' | 'income'>('expense');
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState('');
  const [catId, setCatId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  const filteredCategories = useMemo(
    () => categories.filter(c => c.type === type),
    [categories, type]
  );

  const canSave = description.trim().length > 0 && parseFloat(amount.replace(',', '.')) > 0 && catId;

  const handleSave = async () => {
    if (!canSave) return;
    setSaving(true);
    try {
      await addTransaction({
        description: description.trim(),
        amount: parseFloat(amount.replace(',', '.')),
        cat_id: catId!,
        type,
        date: now.toISOString().slice(0, 10),
        notes: null,
      });
      router.back();
    } catch (e) {
      Alert.alert('Erro', 'Não foi possível salvar a transação. Tente novamente.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView style={s.scroll} contentContainerStyle={{ padding: 20, paddingBottom: 60 }}>
        <View style={s.headerRow}>
          <Text style={s.title}>Nova transação</Text>
          <TouchableOpacity onPress={() => router.back()}>
            <Text style={s.close}>Fechar</Text>
          </TouchableOpacity>
        </View>

        <View style={s.typeToggle}>
          <TouchableOpacity
            style={[s.typeBtn, type === 'expense' && s.typeBtnActiveExpense]}
            onPress={() => { setType('expense'); setCatId(null); }}
          >
            <Text style={[s.typeBtnText, type === 'expense' && s.typeBtnTextActive]}>Despesa</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[s.typeBtn, type === 'income' && s.typeBtnActiveIncome]}
            onPress={() => { setType('income'); setCatId(null); }}
          >
            <Text style={[s.typeBtnText, type === 'income' && s.typeBtnTextActive]}>Receita</Text>
          </TouchableOpacity>
        </View>

        <Text style={s.label}>Descrição</Text>
        <TextInput
          style={s.input}
          value={description}
          onChangeText={setDescription}
          placeholder="Ex: Supermercado"
          placeholderTextColor={theme.textTer}
        />

        <Text style={s.label}>Valor (CHF)</Text>
        <TextInput
          style={s.input}
          value={amount}
          onChangeText={setAmount}
          placeholder="0.00"
          placeholderTextColor={theme.textTer}
          keyboardType="decimal-pad"
        />

        <Text style={s.label}>Categoria</Text>
        <View style={s.catGrid}>
          {filteredCategories.map(cat => (
            <TouchableOpacity
              key={cat.id}
              style={[
                s.catChip,
                { backgroundColor: cat.bg },
                catId === cat.slug && { borderColor: cat.color, borderWidth: 2 },
              ]}
              onPress={() => setCatId(cat.slug)}
            >
              <Text style={{ fontSize: 16 }}>{cat.icon}</Text>
              <Text style={s.catChipLabel} numberOfLines={1}>{cat.label}</Text>
            </TouchableOpacity>
          ))}
          {filteredCategories.length === 0 && (
            <Text style={s.emptyText}>Nenhuma categoria de {type === 'expense' ? 'despesa' : 'receita'} cadastrada.</Text>
          )}
        </View>

        <TouchableOpacity
          style={[s.saveBtn, !canSave && { opacity: 0.4 }]}
          onPress={handleSave}
          disabled={!canSave || saving}
        >
          <Text style={s.saveBtnText}>{saving ? 'Salvando…' : 'Salvar transação'}</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const s = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: theme.white },
  headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 },
  title: { fontSize: 20, fontWeight: '800', color: theme.text, letterSpacing: -0.4 },
  close: { fontSize: 14, color: theme.brand, fontWeight: '600' },
  typeToggle: { flexDirection: 'row', gap: 8, marginBottom: 20 },
  typeBtn: {
    flex: 1, paddingVertical: 12, borderRadius: 10, alignItems: 'center',
    backgroundColor: '#F2F6FA', borderWidth: 1, borderColor: theme.border,
  },
  typeBtnActiveExpense: { backgroundColor: '#FDECEC', borderColor: theme.expense },
  typeBtnActiveIncome: { backgroundColor: '#E7F8F1', borderColor: theme.income },
  typeBtnText: { fontSize: 14, fontWeight: '700', color: theme.textSec },
  typeBtnTextActive: { color: theme.text },
  label: { fontSize: 12, fontWeight: '600', color: theme.textSec, marginBottom: 6, marginTop: 14 },
  input: {
    borderWidth: 1, borderColor: theme.border, borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: theme.text,
  },
  catGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 4 },
  catChip: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    paddingHorizontal: 12, paddingVertical: 9, borderRadius: 10,
    borderWidth: 2, borderColor: 'transparent', maxWidth: 160,
  },
  catChipLabel: { fontSize: 13, fontWeight: '600', color: theme.text },
  emptyText: { fontSize: 13, color: theme.textTer },
  saveBtn: {
    marginTop: 28, backgroundColor: theme.brand, borderRadius: 12,
    paddingVertical: 15, alignItems: 'center',
  },
  saveBtnText: { color: theme.white, fontSize: 15, fontWeight: '700' },
});
FILEEOF

mkdir -p "$(dirname "app/(auth)/_layout.tsx")"
cat > "app/(auth)/_layout.tsx" << 'FILEEOF'
import React from 'react';
import { Stack } from 'expo-router';

export default function AuthLayout() {
  return <Stack screenOptions={{ headerShown: false }} />;
}
FILEEOF

npx tsc --noEmit
echo "TypeScript OK. Fazendo commit..."

git add -A
git commit -m "Add tab navigation, Analise/Orcamento/Projecoes screens, add-transaction modal"
git push

echo "Pronto! Agora e so recarregar o app (tecla r no terminal do expo start, ou shake no iPhone)."
