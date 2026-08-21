import React, { useMemo, useState, useEffect } from 'react';
import { View, Text, ScrollView, StyleSheet, TextInput, ActivityIndicator } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAuth } from '../../../src/context/AuthContext';
import * as TxRepo from '../../../src/repositories/transaction.repository';
import { theme, fCHF } from '../../../src/theme';

const INVESTMENT_CATEGORY_SLUG = 'investment';

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

/** Sum of all-time expenses logged under the "Investimento" category. */
function useInvestedSoFar(userId: string) {
  const [invested, setInvested] = useState<number | null>(null);

  useEffect(() => {
    let mounted = true;
    TxRepo.getAllTransactions(userId).then(res => {
      if (!mounted) return;
      if (res.ok) {
        const total = res.data
          .filter(t => t.type === 'expense' && t.cat_id === INVESTMENT_CATEGORY_SLUG)
          .reduce((s, t) => s + t.amount, 0);
        setInvested(total);
      } else {
        setInvested(0);
      }
    });
    return () => { mounted = false; };
  }, [userId]);

  return invested;
}

export default function ProjecoesScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();
  const profile = user?.profile;
  const investedSoFar = useInvestedSoFar(user!.id);

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

      {/* Invested so far — pulled from real "Investimento" category expenses */}
      <View style={s.investedCard}>
        <Text style={s.investedLabel}>Investido até o momento</Text>
        {investedSoFar === null ? (
          <ActivityIndicator size="small" color={theme.brand} style={{ marginTop: 6 }} />
        ) : (
          <>
            <Text style={s.investedValue}>{fCHF(investedSoFar, 0)}</Text>
            <Text style={s.investedHint}>
              Soma de todas as transações na categoria Investimento
            </Text>
          </>
        )}
      </View>

      <View style={s.formCard}>
        <Field label="Patrimônio inicial (CHF)" value={startingValue} onChangeText={setStartingValue} />
        <Field label="Aporte mensal (CHF)" value={monthlyContribution} onChangeText={setMonthlyContribution} />
        <Field label="Rentabilidade anual (%)" value={annualRate} onChangeText={setAnnualRate} />
        <Field label="Período (anos)" value={years} onChangeText={setYears} />
      </View>

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
  resultCard: {
    marginHorizontal: 16, backgroundColor: theme.brand,
    borderRadius: 14, padding: 18,
  },
  resultLabel: { fontSize: 12, color: 'rgba(255,255,255,.7)', marginBottom: 4 },
  resultValue: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5, marginBottom: 10 },
  resultRow: { flexDirection: 'row', justifyContent: 'space-between' },
  resultSub: { fontSize: 12, color: 'rgba(255,255,255,.85)', fontWeight: '600' },
  investedCard: {
    marginHorizontal: 16, marginTop: 10, backgroundColor: theme.white,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, padding: 16,
  },
  investedLabel: { fontSize: 11, color: theme.textTer, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 4 },
  investedValue: { fontSize: 20, fontWeight: '800', color: theme.text },
  investedHint: { fontSize: 11, color: theme.textTer, marginTop: 4 },
  formCard: {
    marginHorizontal: 16, marginTop: 12, backgroundColor: theme.white, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, gap: 12,
  },
  fieldRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  fieldLabel: { fontSize: 13, color: theme.textSec, flex: 1 },
  fieldInput: {
    width: 110, borderWidth: 1, borderColor: theme.border, borderRadius: 8,
    paddingHorizontal: 10, paddingVertical: 8, fontSize: 14, textAlign: 'right', color: theme.text,
  },
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
