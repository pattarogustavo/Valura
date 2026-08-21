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
