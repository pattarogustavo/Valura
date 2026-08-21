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
