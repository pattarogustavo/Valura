import React, { useMemo, useState, useEffect, useCallback } from 'react';
import { View, Text, ScrollView, StyleSheet, TextInput, ActivityIndicator, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { useAuth } from '../../../src/context/AuthContext';
import * as TxRepo from '../../../src/repositories/transaction.repository';
import { theme, fCHF, MONTHS_SHORT } from '../../../src/theme';
import { LineChart, LineChartPoint } from '../../../src/components/LineChart';

const INVESTMENT_CATEGORY_SLUG = 'investment';
const MAX_MONTHLY_YEARS = 5;

interface YearProjection {
  year: number;
  contributed: number;
  value: number;
}

function projectYearly(
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

function projectMonthly(
  startingValue: number,
  monthlyContribution: number,
  annualRatePct: number,
  months: number
): { label: string; value: number }[] {
  const monthlyRate = annualRatePct / 100 / 12;
  let value = startingValue;
  const results: { label: string; value: number }[] = [];
  const base = new Date();

  for (let i = 1; i <= months; i++) {
    value = value * (1 + monthlyRate) + monthlyContribution;
    const d = new Date(base.getFullYear(), base.getMonth() + i, 1);
    results.push({ label: `${MONTHS_SHORT[d.getMonth()]}/${String(d.getFullYear()).slice(2)}`, value });
  }
  return results;
}

function useInvestedSoFar(userId: string) {
  const [invested, setInvested] = useState<number | null>(null);

  const load = useCallback(async () => {
    if (!userId) return;
    const res = await TxRepo.getAllTransactions(userId);
    if (res.ok) {
      const total = res.data
        .filter(t => t.type === 'expense' && t.cat_id === INVESTMENT_CATEGORY_SLUG)
        .reduce((s, t) => s + t.amount, 0);
      setInvested(total);
    } else {
      setInvested(0);
    }
  }, [userId]);

  useEffect(() => { load(); }, [load]);
  useFocusEffect(useCallback(() => { load(); }, [load]));

  return invested;
}

export default function ProjecoesScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();
  const profile = user?.profile;
  const investedSoFar = useInvestedSoFar(user?.id ?? '');

  const [initialPatrimony, setInitialPatrimony] = useState(String(profile?.net_worth ?? 0));
  const [monthlyContribution, setMonthlyContribution] = useState(
    String(profile?.monthly_income ? Math.round(profile.monthly_income * 0.2) : 500)
  );
  const [annualRate, setAnnualRate] = useState('5');
  const [years, setYears] = useState('10');
  const [view, setView] = useState<'ano' | 'mes'>('ano');

  const effectiveStartingValue = useMemo(() => {
    const other = parseFloat(initialPatrimony.replace(',', '.')) || 0;
    return other + (investedSoFar ?? 0);
  }, [initialPatrimony, investedSoFar]);

  const yearsNum = Math.max(1, Math.min(50, parseInt(years, 10) || 1));
  const mc = parseFloat(monthlyContribution.replace(',', '.')) || 0;
  const rate = parseFloat(annualRate.replace(',', '.')) || 0;

  const yearlyResults = useMemo(
    () => projectYearly(effectiveStartingValue, mc, rate, yearsNum),
    [effectiveStartingValue, mc, rate, yearsNum]
  );

  const monthlyMonthsToShow = Math.min(yearsNum, MAX_MONTHLY_YEARS) * 12;
  const monthlyResults = useMemo(
    () => projectMonthly(effectiveStartingValue, mc, rate, monthlyMonthsToShow),
    [effectiveStartingValue, mc, rate, monthlyMonthsToShow]
  );

  const final = yearlyResults[yearlyResults.length - 1];

  const chartData: LineChartPoint[] = view === 'ano'
    ? yearlyResults.map(r => ({ label: `Ano ${r.year}`, value: r.value }))
    : monthlyResults.map(r => ({ label: r.label, value: r.value }));

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <Text style={s.title}>Projeções</Text>
        <Text style={s.subtitle}>Simule a evolução do seu patrimônio</Text>
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

      <View style={s.investedCard}>
        <Text style={s.investedLabel}>VALOR INVESTIDO</Text>
        {investedSoFar === null ? (
          <ActivityIndicator size="small" color={theme.gold} style={{ marginTop: 6 }} />
        ) : (
          <>
            <Text style={s.investedValue}>{fCHF(investedSoFar, 0)}</Text>
            <Text style={s.investedHint}>
              Soma de todas as transações na categoria Investimento.
            </Text>
          </>
        )}
      </View>

      <View style={s.formCard}>
        <Field label="Patrimônio inicial (CHF)" value={initialPatrimony} onChangeText={setInitialPatrimony} />
        <Field label="Aporte mensal (CHF)" value={monthlyContribution} onChangeText={setMonthlyContribution} />
        <Field label="Rentabilidade anual (%)" value={annualRate} onChangeText={setAnnualRate} />
        <Field label="Período (anos)" value={years} onChangeText={setYears} />
        <Text style={s.formHint}>
          A simulação soma Patrimônio inicial + Valor investido como ponto de partida: {fCHF(effectiveStartingValue, 0)}.
        </Text>
      </View>

      <View style={s.sectionHeaderRow}>
        <Text style={s.sectionTitle}>Evolução</Text>
        <View style={s.toggle}>
          <TouchableOpacity
            style={[s.toggleBtn, view === 'mes' && s.toggleBtnActive]}
            onPress={() => setView('mes')}
          >
            <Text style={[s.toggleText, view === 'mes' && s.toggleTextActive]}>Mês</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[s.toggleBtn, view === 'ano' && s.toggleBtnActive]}
            onPress={() => setView('ano')}
          >
            <Text style={[s.toggleText, view === 'ano' && s.toggleTextActive]}>Ano</Text>
          </TouchableOpacity>
        </View>
      </View>

      {view === 'mes' && yearsNum > MAX_MONTHLY_YEARS && (
        <Text style={s.monthlyNote}>
          Mostrando os primeiros {MAX_MONTHLY_YEARS} anos em detalhe mensal.
        </Text>
      )}

      <View style={s.chartBox}>
        <LineChart
          data={chartData}
          height={180}
          color={theme.gold}
          dotBorderColor={theme.white}
          scrollable={view === 'mes'}
          minPointSpacing={40}
          axisLabelColor="#94A3B8"
          gridColor="rgba(11,18,32,0.08)"
        />
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
  title: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5 },
  subtitle: { fontSize: 14, color: theme.textSec, marginTop: 2 },
  resultCard: {
    marginHorizontal: 16, backgroundColor: theme.surface,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, padding: 18,
  },
  resultLabel: { fontSize: 12, color: theme.textSec, marginBottom: 4 },
  resultValue: { fontSize: 26, fontWeight: '800', color: theme.white, letterSpacing: -0.5, marginBottom: 10 },
  resultRow: { flexDirection: 'row', justifyContent: 'space-between' },
  resultSub: { fontSize: 12, color: theme.textSec, fontWeight: '600' },
  investedCard: {
    marginHorizontal: 16, marginTop: 10, backgroundColor: theme.surface,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, padding: 16,
  },
  investedLabel: { fontSize: 11, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 },
  investedValue: { fontSize: 22, fontWeight: '800', color: theme.white },
  investedHint: { fontSize: 11, color: theme.textSec, marginTop: 6, lineHeight: 16 },
  formCard: {
    marginHorizontal: 16, marginTop: 12, backgroundColor: theme.surface, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, gap: 12,
  },
  fieldRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  fieldLabel: { fontSize: 13, color: theme.textSec, flex: 1 },
  fieldInput: {
    width: 110, borderWidth: 1, borderColor: theme.border, borderRadius: 8,
    paddingHorizontal: 10, paddingVertical: 8, fontSize: 14, textAlign: 'right',
    color: theme.inputText, backgroundColor: theme.inputBg,
  },
  totalRow: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    backgroundColor: theme.goldSoft, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 10,
  },
  totalLabel: { fontSize: 12, color: theme.textSec, fontWeight: '600' },
  totalValue: { fontSize: 14, color: theme.gold, fontWeight: '800' },
  formHint: { fontSize: 11, color: theme.textSec, marginTop: 2, lineHeight: 16 },
  sectionHeaderRow: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    marginHorizontal: 16, marginTop: 18, marginBottom: 10,
  },
  sectionTitle: { fontSize: 15, fontWeight: '700', color: theme.white, letterSpacing: -0.2 },
  toggle: { flexDirection: 'row', backgroundColor: theme.surface, borderRadius: 8, padding: 2, borderWidth: 1, borderColor: theme.border },
  toggleBtn: { paddingHorizontal: 14, paddingVertical: 6, borderRadius: 6 },
  toggleBtnActive: { backgroundColor: theme.gold },
  toggleText: { fontSize: 12, fontWeight: '600', color: theme.textSec },
  toggleTextActive: { color: theme.bg },
  monthlyNote: { fontSize: 11, color: theme.textSec, marginHorizontal: 16, marginBottom: 8 },
  chartBox: {
    marginHorizontal: 16, backgroundColor: theme.white, borderRadius: 14,
    padding: 16,
  },
});
