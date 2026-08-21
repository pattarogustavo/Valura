#!/bin/bash
set -e
echo "Aplicando lote de correções e novas funcionalidades..."
mkdir -p src/components

mkdir -p "$(dirname "src/components/MonthSelector.tsx")"
cat > "src/components/MonthSelector.tsx" << 'FILEEOF'
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { theme, MONTHS_FULL } from '../theme';

interface MonthSelectorProps {
  year: number;
  month: number; // 0-indexed
  onChange: (year: number, month: number) => void;
  light?: boolean; // true = white text (for use over a colored/dark header)
}

export function MonthSelector({ year, month, onChange, light }: MonthSelectorProps) {
  const now = new Date();
  const isCurrentMonth = year === now.getFullYear() && month === now.getMonth();

  const goPrev = () => {
    if (month === 0) onChange(year - 1, 11);
    else onChange(year, month - 1);
  };

  const goNext = () => {
    if (isCurrentMonth) return; // don't allow navigating into the future
    if (month === 11) onChange(year + 1, 0);
    else onChange(year, month + 1);
  };

  return (
    <View style={s.row}>
      <TouchableOpacity onPress={goPrev} style={s.arrowBtn} hitSlop={8}>
        <Text style={[s.arrow, light && s.arrowLight]}>‹</Text>
      </TouchableOpacity>

      <Text style={[s.label, light && s.labelLight]}>
        {MONTHS_FULL[month]} {year}
      </Text>

      <TouchableOpacity
        onPress={goNext}
        style={s.arrowBtn}
        hitSlop={8}
        disabled={isCurrentMonth}
      >
        <Text style={[s.arrow, light && s.arrowLight, isCurrentMonth && s.arrowDisabled]}>›</Text>
      </TouchableOpacity>
    </View>
  );
}

const s = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  arrowBtn: { padding: 4 },
  arrow: { fontSize: 22, fontWeight: '700', color: theme.text },
  arrowLight: { color: theme.white },
  arrowDisabled: { opacity: 0.3 },
  label: { fontSize: 14, fontWeight: '600', color: theme.textSec, minWidth: 120, textAlign: 'center' },
  labelLight: { color: 'rgba(255,255,255,.9)' },
});
FILEEOF

mkdir -p "$(dirname "src/components/DatePickerField.tsx")"
cat > "src/components/DatePickerField.tsx" << 'FILEEOF'
import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Modal, Pressable } from 'react-native';
import { theme, MONTHS_FULL } from '../theme';

interface DatePickerFieldProps {
  value: string; // 'YYYY-MM-DD'
  onChange: (date: string) => void;
}

const WEEKDAYS = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

function toISODate(y: number, m: number, d: number): string {
  return `${y}-${String(m + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

function parseISODate(iso: string): { y: number; m: number; d: number } {
  const [y, m, d] = iso.split('-').map(Number);
  return { y, m: m - 1, d };
}

function formatDisplay(iso: string): string {
  const { y, m, d } = parseISODate(iso);
  return `${String(d).padStart(2, '0')} de ${MONTHS_FULL[m]} de ${y}`;
}

export function DatePickerField({ value, onChange }: DatePickerFieldProps) {
  const [open, setOpen] = useState(false);
  const selected = parseISODate(value);
  const [viewYear, setViewYear] = useState(selected.y);
  const [viewMonth, setViewMonth] = useState(selected.m);

  const openPicker = () => {
    setViewYear(selected.y);
    setViewMonth(selected.m);
    setOpen(true);
  };

  const firstWeekday = new Date(viewYear, viewMonth, 1).getDay();
  const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();

  const cells: (number | null)[] = [];
  for (let i = 0; i < firstWeekday; i++) cells.push(null);
  for (let d = 1; d <= daysInMonth; d++) cells.push(d);

  const goPrevMonth = () => {
    if (viewMonth === 0) { setViewYear(y => y - 1); setViewMonth(11); }
    else setViewMonth(m => m - 1);
  };
  const goNextMonth = () => {
    if (viewMonth === 11) { setViewYear(y => y + 1); setViewMonth(0); }
    else setViewMonth(m => m + 1);
  };

  const pickDay = (d: number) => {
    onChange(toISODate(viewYear, viewMonth, d));
    setOpen(false);
  };

  return (
    <>
      <TouchableOpacity style={s.field} onPress={openPicker}>
        <Text style={s.fieldText}>{formatDisplay(value)}</Text>
        <Text style={s.fieldIcon}>📅</Text>
      </TouchableOpacity>

      <Modal visible={open} transparent animationType="fade" onRequestClose={() => setOpen(false)}>
        <Pressable style={s.backdrop} onPress={() => setOpen(false)}>
          <Pressable style={s.calendarBox} onPress={() => {}}>
            <View style={s.calHeader}>
              <TouchableOpacity onPress={goPrevMonth} hitSlop={8}>
                <Text style={s.calArrow}>‹</Text>
              </TouchableOpacity>
              <Text style={s.calTitle}>{MONTHS_FULL[viewMonth]} {viewYear}</Text>
              <TouchableOpacity onPress={goNextMonth} hitSlop={8}>
                <Text style={s.calArrow}>›</Text>
              </TouchableOpacity>
            </View>

            <View style={s.weekRow}>
              {WEEKDAYS.map((w, i) => (
                <Text key={i} style={s.weekLabel}>{w}</Text>
              ))}
            </View>

            <View style={s.grid}>
              {cells.map((d, i) => {
                if (d === null) return <View key={i} style={s.cell} />;
                const isSelected = d === selected.d && viewMonth === selected.m && viewYear === selected.y;
                return (
                  <TouchableOpacity
                    key={i}
                    style={[s.cell, isSelected && s.cellSelected]}
                    onPress={() => pickDay(d)}
                  >
                    <Text style={[s.cellText, isSelected && s.cellTextSelected]}>{d}</Text>
                  </TouchableOpacity>
                );
              })}
            </View>

            <TouchableOpacity style={s.closeBtn} onPress={() => setOpen(false)}>
              <Text style={s.closeBtnText}>Cancelar</Text>
            </TouchableOpacity>
          </Pressable>
        </Pressable>
      </Modal>
    </>
  );
}

const CELL_SIZE = 40;

const s = StyleSheet.create({
  field: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    borderWidth: 1, borderColor: theme.border, borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 12,
  },
  fieldText: { fontSize: 15, color: theme.text },
  fieldIcon: { fontSize: 16 },
  backdrop: { flex: 1, backgroundColor: 'rgba(10,25,41,.5)', alignItems: 'center', justifyContent: 'center' },
  calendarBox: {
    width: 320, backgroundColor: theme.white, borderRadius: 16, padding: 16,
  },
  calHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  calArrow: { fontSize: 22, fontWeight: '700', color: theme.text, paddingHorizontal: 8 },
  calTitle: { fontSize: 15, fontWeight: '700', color: theme.text },
  weekRow: { flexDirection: 'row', marginBottom: 4 },
  weekLabel: { width: CELL_SIZE, textAlign: 'center', fontSize: 11, color: theme.textTer, fontWeight: '600' },
  grid: { flexDirection: 'row', flexWrap: 'wrap' },
  cell: { width: CELL_SIZE, height: CELL_SIZE, alignItems: 'center', justifyContent: 'center' },
  cellSelected: { backgroundColor: theme.brand, borderRadius: CELL_SIZE / 2 },
  cellText: { fontSize: 14, color: theme.text },
  cellTextSelected: { color: theme.white, fontWeight: '700' },
  closeBtn: { marginTop: 8, alignItems: 'center', paddingVertical: 10 },
  closeBtnText: { fontSize: 14, color: theme.textTer, fontWeight: '600' },
});
FILEEOF

mkdir -p "$(dirname "src/hooks/useBudget.ts")"
cat > "src/hooks/useBudget.ts" << 'FILEEOF'
import { useState, useEffect, useCallback, useRef } from 'react';
import { supabase } from '../lib/supabase';
import * as BudgetRepo from '../repositories/budget.repository';
import * as CatRepo    from '../repositories/category.repository';
import type { BudgetMap, Category, MonthlySnapshot, UpsertBudgetInput } from '../types';

// ─── useBudget ────────────────────────────────────────────────────────────────

interface UseBudgetReturn {
  budget:       BudgetMap;
  loading:      boolean;
  error:        string | null;
  updateBudget: (input: UpsertBudgetInput) => Promise<void>;
}

export function useBudget(
  userId:    string,
  monthYear: string  // 'YYYY-MM'
): UseBudgetReturn {
  const [budget,  setBudget]  = useState<BudgetMap>({});
  const [loading, setLoading] = useState(true);
  const [error,   setError]   = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    const result = await BudgetRepo.getMonthBudget(userId, monthYear);
    if (result.ok) {
      setBudget(result.data);
      setError(null);
    } else {
      setError(result.error);
    }
    setLoading(false);
  }, [userId, monthYear]);

  useEffect(() => { load(); }, [load]);

  // ── Real-time subscription: keeps every screen using this hook in sync
  //    whenever the budget changes anywhere else (e.g. another tab). ────────
  useEffect(() => {
    const channel = supabase
      .channel(`budgets:${userId}:${monthYear}`)
      .on(
        'postgres_changes',
        {
          event:  '*',
          schema: 'public',
          table:  'budgets',
          filter: `user_id=eq.${userId}`,
        },
        () => { load(); }
      )
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [userId, monthYear, load]);

  const updateBudget = useCallback(async (input: UpsertBudgetInput) => {
    // Optimistic update
    setBudget(prev => ({ ...prev, [input.cat_id]: input.amount }));
    const result = await BudgetRepo.upsertBudget(userId, input);
    if (!result.ok) {
      await load(); // rollback
      setError(result.error);
    }
  }, [userId, load]);

  return { budget, loading, error, updateBudget };
}

// ─── useCategories ────────────────────────────────────────────────────────────

interface UseCategoriesReturn {
  categories:    Category[];
  loading:       boolean;
  error:         string | null;
  addCategory:   (input: Omit<Category, 'id'|'user_id'|'is_system'|'created_at'>) => Promise<void>;
  refresh:       () => Promise<void>;
}

export function useCategories(userId: string): UseCategoriesReturn {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading,    setLoading]    = useState(true);
  const [error,      setError]      = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    const result = await CatRepo.getUserCategories(userId);
    if (result.ok) { setCategories(result.data); setError(null); }
    else             setError(result.error);
    setLoading(false);
  }, [userId]);

  useEffect(() => { load(); }, [load]);

  const addCategory = useCallback(async (
    input: Omit<Category, 'id'|'user_id'|'is_system'|'created_at'>
  ) => {
    const result = await CatRepo.createCategory(userId, input);
    if (result.ok) setCategories(prev => [...prev, result.data]);
    else setError(result.error);
  }, [userId]);

  return { categories, loading, error, addCategory, refresh: load };
}

// ─── useSnapshots (for Analysis screen history) ────────────────────────────────

interface UseSnapshotsReturn {
  snapshots: MonthlySnapshot[];
  loading:   boolean;
}

export function useSnapshots(userId: string): UseSnapshotsReturn {
  const [snapshots, setSnapshots] = useState<MonthlySnapshot[]>([]);
  const [loading,   setLoading]   = useState(true);

  useEffect(() => {
    CatRepo.getRecentSnapshots(userId, 6).then(res => {
      if (res.ok) setSnapshots(res.data);
      setLoading(false);
    });
  }, [userId]);

  return { snapshots, loading };
}
FILEEOF

mkdir -p "$(dirname "app/_layout.tsx")"
cat > "app/_layout.tsx" << 'FILEEOF'
import React, { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider, useAuth } from '../src/context/AuthContext';

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
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: '#1756F5' }}>
        <ActivityIndicator color="#ffffff" size="large" />
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

mkdir -p "$(dirname "app/(app)/(tabs)/index.tsx")"
cat > "app/(app)/(tabs)/index.tsx" << 'FILEEOF'
/**
 * app/(app)/(tabs)/index.tsx  →  Summary / Dashboard tab
 */

import React, { useMemo, useState } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAuth }         from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget }       from '../../../src/hooks/useBudget';
import { useCategories }   from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';

const now = new Date();

export default function SummaryScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();

  const [viewYear, setViewYear] = useState(now.getFullYear());
  const [viewMonth, setViewMonth] = useState(now.getMonth());
  const isCurrentMonth = viewYear === now.getFullYear() && viewMonth === now.getMonth();

  if (!user) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.brand} />
      </View>
    );
  }
  const userId = user.id;
  const monthYear = `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}`;

  const { transactions, loading: txLoading } = useTransactions({ userId, year: viewYear, month: viewMonth });
  const { budget, loading: budLoading } = useBudget(userId, monthYear);
  const { categories, loading: catLoading } = useCategories(userId);

  const loading = txLoading || budLoading || catLoading;

  const { totalIncome, totalExpense, remaining, savingsRate } = useMemo(() => {
    const totalIncome = transactions.filter(t => t.type === 'income').reduce((s, t) => s + t.amount, 0);
    const totalExpense = transactions.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0);
    const remaining = totalIncome - totalExpense;
    const savingsRate = totalIncome > 0 ? Math.max(0, Math.round((remaining / totalIncome) * 100)) : 0;
    return { totalIncome, totalExpense, remaining, savingsRate };
  }, [transactions]);

  const totalBudget = Object.values(budget).reduce((s, v) => s + v, 0);

  // "Limite/dia" only makes sense for the current, ongoing month.
  // For past months, show the average daily spend instead.
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

  if (loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.brand} />
      </View>
    );
  }

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 100 }}>
      {/* ── Header ── */}
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <View style={s.headerTop}>
          <Text style={s.greeting}>Bom dia, {user.profile?.display_name ?? 'Ana'} 👋</Text>
          <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} light />
        </View>

        <Text style={s.balLabel}>Saldo disponível</Text>
        <Text style={s.balance}>{fCHF(remaining)}</Text>

        {/* Progress bar */}
        <View style={s.barBg}>
          <View style={[s.barFill, {
            width: `${Math.min(100, Math.round((totalExpense / (totalBudget || 1)) * 100))}%`,
            backgroundColor: savingsRate > 20 ? theme.good : savingsRate > 5 ? theme.warn : theme.danger,
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
          { l: thirdKpi.label, v: thirdKpi.value, c: theme.brand },
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
            <View style={[s.txIcon, { backgroundColor: cat?.bg ?? '#F8FAFC' }]}>
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
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { backgroundColor: theme.brand, padding: 20, paddingBottom: 26 },
  headerTop: { marginBottom: 18 },
  greeting: { fontSize: 12, color: 'rgba(255,255,255,.55)', marginBottom: 10 },
  balLabel: { fontSize: 11, color: 'rgba(255,255,255,.55)', textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 5 },
  balance: { fontSize: 33, fontWeight: '700', color: theme.white, letterSpacing: -0.5, marginBottom: 16 },
  barBg: { height: 5, backgroundColor: 'rgba(255,255,255,.2)', borderRadius: 3, marginBottom: 8 },
  barFill: { height: 5, borderRadius: 3 },
  barRow: { flexDirection: 'row', justifyContent: 'space-between' },
  barText: { fontSize: 11, color: 'rgba(255,255,255,.5)' },
  kpiRow: { flexDirection: 'row', gap: 8, padding: 14 },
  kpiCard: { flex: 1, backgroundColor: theme.white, borderRadius: 14, padding: 12, alignItems: 'center', borderWidth: 1, borderColor: theme.border },
  kpiLabel: { fontSize: 10, color: theme.textTer, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 5 },
  kpiValue: { fontSize: 16, fontWeight: '800', letterSpacing: -0.4 },
  sectionTitle: { fontSize: 14, fontWeight: '700', color: theme.text, marginHorizontal: 16, marginTop: 8, marginBottom: 12, letterSpacing: -0.2 },
  emptyBox: { marginHorizontal: 16, padding: 24, backgroundColor: theme.white, borderRadius: 14, borderWidth: 1, borderColor: theme.border, alignItems: 'center' },
  emptyText: { color: theme.textTer, fontSize: 13 },
  txRow: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingVertical: 11, borderBottomWidth: 1, borderColor: theme.border, backgroundColor: theme.white },
  txIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  txDesc: { fontSize: 14, fontWeight: '600', color: theme.text, letterSpacing: -0.1 },
  txMeta: { fontSize: 11, color: theme.textTer, marginTop: 2 },
  txAmount: { fontSize: 15, fontWeight: '800', letterSpacing: -0.3 },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/analise.tsx")"
cat > "app/(app)/(tabs)/analise.tsx" << 'FILEEOF'
import React, { useMemo, useState } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAuth } from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget, useCategories } from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';

const now = new Date();

export default function AnaliseScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();
  const userId = user!.id;

  const [viewYear, setViewYear] = useState(now.getFullYear());
  const [viewMonth, setViewMonth] = useState(now.getMonth());
  const monthYear = `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}`;

  const { transactions, loading: txLoading } = useTransactions({ userId, year: viewYear, month: viewMonth });
  const { categories, loading: catLoading } = useCategories(userId);
  const { budget, loading: budLoading } = useBudget(userId, monthYear);

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
          color: cat?.color ?? theme.brand,
          bg: cat?.bg ?? '#F8FAFC',
          pct: totalExpense > 0 ? Math.round((amount / totalExpense) * 100) : 0,
          goal,
          budgetPct, // % of the budget goal used — can exceed 100
        };
      })
      .sort((a, b) => b.amount - a.amount);

    return { byCategory, totalExpense, totalIncome };
  }, [transactions, categories, budget]);

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
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <Text style={s.title}>Análise</Text>
        <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} />
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
          <Text style={s.emptyText}>Nenhuma despesa registrada em {MONTHS_FULL[viewMonth]}.</Text>
        </View>
      ) : (
        <View style={s.chartBox}>
          {byCategory.map(c => {
            const overBudget = c.budgetPct !== null && c.budgetPct > 100;
            return (
              <View key={c.catId} style={s.barRow}>
                <View style={s.barLabelRow}>
                  <Text style={s.barIcon}>{c.icon}</Text>
                  <Text style={s.barLabel} numberOfLines={1}>{c.label}</Text>
                  {c.budgetPct !== null && (
                    <View style={[s.budgetBadge, overBudget && s.budgetBadgeOver]}>
                      <Text style={[s.budgetBadgeText, overBudget && s.budgetBadgeTextOver]}>
                        {c.budgetPct}% do orçamento
                      </Text>
                    </View>
                  )}
                  <Text style={s.barPct}>{c.pct}%</Text>
                </View>
                <View style={s.barTrack}>
                  <View
                    style={[
                      s.barFill,
                      {
                        width: `${Math.max(4, (c.amount / maxAmount) * 100)}%`,
                        backgroundColor: overBudget ? theme.danger : c.color,
                      },
                    ]}
                  />
                </View>
                <Text style={s.barAmount}>
                  {fCHF(c.amount, 0)}{c.goal > 0 ? ` de ${fCHF(c.goal, 0)}` : ''}
                </Text>
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
  header: { padding: 20, paddingBottom: 12, gap: 10 },
  title: { fontSize: 24, fontWeight: '800', color: theme.text, letterSpacing: -0.5 },
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
  budgetBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8, backgroundColor: '#EEF3F8' },
  budgetBadgeOver: { backgroundColor: '#FDECEC' },
  budgetBadgeText: { fontSize: 10, fontWeight: '700', color: theme.textSec },
  budgetBadgeTextOver: { color: theme.danger },
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
import { useSafeAreaInsets } from 'react-native-safe-area-context';
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
  const insets = useSafeAreaInsets();
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
  const totalPct = totalBudget > 0 ? Math.round((totalSpent / totalBudget) * 100) : 0;

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
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <Text style={s.title}>Orçamento</Text>
        <Text style={s.subtitle}>{MONTHS_FULL[CM]} {CY}</Text>
      </View>

      <View style={s.summaryCard}>
        <View style={s.summaryTopRow}>
          <View>
            <Text style={s.summaryLabel}>Total orçado</Text>
            <Text style={s.summaryValue}>{fCHF(totalBudget, 0)}</Text>
          </View>
          {totalBudget > 0 && (
            <Text style={[s.summaryPct, totalPct > 100 && s.summaryPctOver]}>{totalPct}%</Text>
          )}
        </View>
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
            // Real percentage, unclamped, so overspending is visible (e.g. 120%).
            const pct = goal > 0 ? Math.round((spent / goal) * 100) : 0;
            const barWidthPct = Math.min(100, pct); // bar itself is capped so it doesn't overflow the track
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
                      {goal > 0 && (
                        <Text style={over ? s.catPctOver : s.catPct}> · {pct}%</Text>
                      )}
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
                        { width: `${barWidthPct}%`, backgroundColor: over ? theme.danger : cat.color },
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
  summaryTopRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 },
  summaryLabel: { fontSize: 11, color: theme.textTer, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 4 },
  summaryValue: { fontSize: 22, fontWeight: '800', color: theme.text },
  summaryPct: { fontSize: 16, fontWeight: '800', color: theme.brand },
  summaryPctOver: { color: theme.danger },
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
  catPct: { color: theme.textSec, fontWeight: '700' },
  catPctOver: { color: theme.danger, fontWeight: '700' },
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
FILEEOF

mkdir -p "$(dirname "app/(app)/adicionar.tsx")"
cat > "app/(app)/adicionar.tsx" << 'FILEEOF'
import React, { useState, useMemo } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TextInput,
  TouchableOpacity, KeyboardAvoidingView, Platform, Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';
import { useTransactions } from '../../src/hooks/useTransactions';
import { useCategories } from '../../src/hooks/useBudget';
import { theme } from '../../src/theme';
import { DatePickerField } from '../../src/components/DatePickerField';

const now = new Date();

function todayISO(): string {
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

export default function AdicionarScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
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
  const [date, setDate] = useState(todayISO());
  const [saving, setSaving] = useState(false);

  const filteredCategories = useMemo(
    () => categories.filter(c => c.type === type),
    [categories, type]
  );

  const canSave = description.trim().length > 0 && parseFloat(amount.replace(',', '.')) > 0 && catId;

  const handleSave = async () => {
    if (!canSave) return;
    setSaving(true);
    const result = await addTransaction({
      description: description.trim(),
      amount: parseFloat(amount.replace(',', '.')),
      cat_id: catId!,
      type,
      date,
      notes: null,
    });
    setSaving(false);

    if (result.ok) {
      router.back();
    } else {
      Alert.alert('Erro ao salvar', result.error ?? 'Não foi possível salvar a transação. Tente novamente.');
    }
  };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView
        style={s.scroll}
        contentContainerStyle={{ padding: 20, paddingTop: insets.top + 16, paddingBottom: 60 }}
      >
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

        <Text style={s.label}>Data</Text>
        <DatePickerField value={date} onChange={setDate} />

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

npx tsc --noEmit
echo "TypeScript OK. Fazendo commit..."
git add -A
git commit -m "Add safe area insets, month selectors, date picker, invested-so-far field, fix budget %/sync bugs"
git push
echo "Pronto! Recarrega o app (tecla r) pra ver as mudancas."
