#!/bin/bash
set -e
echo "Aplicando edicao/exclusao de transacao + correcao Projecoes (so JS, sem build)..."

mkdir -p "$(dirname "src/hooks/useTransactions.ts")"
cat > "src/hooks/useTransactions.ts" << 'FILEEOF'
import { useState, useEffect, useCallback, useRef } from 'react';
import { supabase } from '../lib/supabase';
import * as TxRepo from '../repositories/transaction.repository';
import type { Transaction, CreateTransactionInput } from '../types';

interface UseTransactionsOptions {
  userId: string;
  year:   number;
  month:  number;  // 0-indexed
}

interface UseTransactionsReturn {
  transactions: Transaction[];
  loading:      boolean;
  error:        string | null;
  addTransaction:    (input: CreateTransactionInput) => Promise<{ ok: boolean; error?: string }>;
  updateTransaction: (id: string, input: Partial<CreateTransactionInput>) => Promise<{ ok: boolean; error?: string }>;
  deleteTransaction: (id: string) => Promise<{ ok: boolean; error?: string }>;
  refresh:           () => Promise<void>;
}

export function useTransactions(opts: UseTransactionsOptions): UseTransactionsReturn {
  const { userId, year, month } = opts;
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading]           = useState(true);
  const [error, setError]               = useState<string | null>(null);
  const realtimeRef = useRef<any>(null);

  const load = useCallback(async () => {
    setLoading(true);
    const result = await TxRepo.getMonthTransactions(userId, year, month);
    if (result.ok) {
      setTransactions(result.data);
      setError(null);
    } else {
      setError(result.error);
    }
    setLoading(false);
  }, [userId, year, month]);

  // ── Initial load ──────────────────────────────────────────────────────────
  useEffect(() => { load(); }, [load]);

  // ── Real-time subscription (changes on other devices appear instantly) ────
  useEffect(() => {
    const channel = supabase
      .channel(`transactions:${userId}`)
      .on(
        'postgres_changes',
        {
          event:  '*',
          schema: 'public',
          table:  'transactions',
          filter: `user_id=eq.${userId}`,
        },
        () => { load(); }   // re-fetch on any change
      )
      .subscribe();

    realtimeRef.current = channel;
    return () => { supabase.removeChannel(channel); };
  }, [userId, load]);

  // ── Mutations ─────────────────────────────────────────────────────────────

  const addTransaction = useCallback(async (input: CreateTransactionInput) => {
    // Optimistic insert
    const temp: Transaction = {
      ...input,
      id:         `temp-${Date.now()}`,
      user_id:    userId,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    // Only show in list if it's in the current month
    const txMonth = new Date(input.date).getMonth();
    const txYear  = new Date(input.date).getFullYear();
    if (txMonth === month && txYear === year) {
      setTransactions(prev => [temp, ...prev]);
    }

    const result = await TxRepo.createTransaction(userId, input);
    if (result.ok) {
      // Replace temp with real row
      setTransactions(prev =>
        prev.map(t => t.id === temp.id ? result.data : t)
      );
      return { ok: true };
    } else {
      // Roll back
      setTransactions(prev => prev.filter(t => t.id !== temp.id));
      setError(result.error);
      return { ok: false, error: result.error };
    }
  }, [userId, year, month]);

  const updateTransaction = useCallback(async (
    id: string,
    input: Partial<CreateTransactionInput>
  ) => {
    // Optimistic update
    setTransactions(prev =>
      prev.map(t => t.id === id ? { ...t, ...input } : t)
    );
    const result = await TxRepo.updateTransaction(userId, id, input);
    if (result.ok) {
      setTransactions(prev =>
        prev.map(t => t.id === id ? result.data : t)
      );
      return { ok: true };
    } else {
      await load(); // re-sync from DB on failure
      setError(result.error);
      return { ok: false, error: result.error };
    }
  }, [userId, load]);

  const deleteTransaction = useCallback(async (id: string) => {
    // Optimistic delete
    const previous = transactions;
    setTransactions(prev => prev.filter(t => t.id !== id));
    const result = await TxRepo.deleteTransaction(userId, id);
    if (!result.ok) {
      setTransactions(previous); // restore on failure
      setError(result.error);
      return { ok: false, error: result.error };
    }
    return { ok: true };
  }, [userId, transactions]);

  return {
    transactions,
    loading,
    error,
    addTransaction,
    updateTransaction,
    deleteTransaction,
    refresh: load,
  };
}
FILEEOF

mkdir -p "$(dirname "app/(app)/adicionar.tsx")"
cat > "app/(app)/adicionar.tsx" << 'FILEEOF'
import React, { useState, useMemo } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TextInput,
  TouchableOpacity, KeyboardAvoidingView, Platform, Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';
import { useTransactions } from '../../src/hooks/useTransactions';
import { useCategories } from '../../src/hooks/useBudget';
import { theme } from '../../src/theme';
import { DatePickerField } from '../../src/components/DatePickerField';
import { CategoryIcon } from '../../src/components/CategoryIcon';
import type { Transaction } from '../../src/types';

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

  // If a transaction was passed in (tapping a row to edit), we're in edit mode.
  const { transaction: transactionParam } = useLocalSearchParams<{ transaction?: string }>();
  const editingTx: Transaction | null = useMemo(() => {
    if (!transactionParam) return null;
    try { return JSON.parse(transactionParam) as Transaction; } catch { return null; }
  }, [transactionParam]);
  const isEditing = !!editingTx;

  const { categories } = useCategories(userId);
  const { addTransaction, updateTransaction, deleteTransaction } = useTransactions({
    userId, year: now.getFullYear(), month: now.getMonth(),
  });

  const [type, setType] = useState<'expense' | 'income'>(editingTx?.type ?? 'expense');
  const [description, setDescription] = useState(editingTx?.description ?? '');
  const [amount, setAmount] = useState(editingTx ? String(editingTx.amount) : '');
  const [catId, setCatId] = useState<string | null>(editingTx?.cat_id ?? null);
  const [date, setDate] = useState(editingTx?.date ?? todayISO());
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);

  const filteredCategories = useMemo(
    () => categories.filter(c => c.type === type),
    [categories, type]
  );

  const canSave = description.trim().length > 0 && parseFloat(amount.replace(',', '.')) > 0 && catId;

  const handleSave = async () => {
    if (!canSave) return;
    setSaving(true);

    const payload = {
      description: description.trim(),
      amount: parseFloat(amount.replace(',', '.')),
      cat_id: catId!,
      type,
      date,
      notes: null,
    };

    const result = isEditing
      ? await updateTransaction(editingTx!.id, payload)
      : await addTransaction(payload);

    setSaving(false);

    if (result.ok) {
      router.back();
    } else {
      Alert.alert('Erro ao salvar', result.error ?? 'Não foi possível salvar a transação. Tente novamente.');
    }
  };

  const handleDelete = () => {
    if (!editingTx) return;
    Alert.alert(
      'Apagar transação',
      `Tem certeza que deseja apagar "${editingTx.description}"?`,
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Apagar',
          style: 'destructive',
          onPress: async () => {
            setDeleting(true);
            const result = await deleteTransaction(editingTx.id);
            setDeleting(false);
            if (result.ok) {
              router.back();
            } else {
              Alert.alert('Erro', result.error ?? 'Não foi possível apagar a transação.');
            }
          },
        },
      ]
    );
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
          <Text style={s.title}>{isEditing ? 'Editar transação' : 'Nova transação'}</Text>
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
                catId === cat.slug && s.catChipActive,
              ]}
              onPress={() => setCatId(cat.slug)}
            >
              <CategoryIcon slug={cat.slug} size={16} color={catId === cat.slug ? theme.gold : cat.color} />
              <Text style={[s.catChipLabel, catId === cat.slug && s.catChipLabelActive]} numberOfLines={1}>
                {cat.label}
              </Text>
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
          <Text style={s.saveBtnText}>
            {saving ? 'Salvando…' : isEditing ? 'Salvar alterações' : 'Salvar transação'}
          </Text>
        </TouchableOpacity>

        {isEditing && (
          <TouchableOpacity
            style={[s.deleteBtn, deleting && { opacity: 0.5 }]}
            onPress={handleDelete}
            disabled={deleting}
          >
            <Text style={s.deleteBtnText}>{deleting ? 'Apagando…' : 'Apagar transação'}</Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const s = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: theme.bg },
  headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 },
  title: { fontSize: 20, fontWeight: '800', color: theme.white, letterSpacing: -0.4 },
  close: { fontSize: 14, color: theme.gold, fontWeight: '600' },
  typeToggle: { flexDirection: 'row', gap: 8, marginBottom: 20 },
  typeBtn: {
    flex: 1, paddingVertical: 12, borderRadius: 10, alignItems: 'center',
    backgroundColor: theme.surface, borderWidth: 1, borderColor: theme.border,
  },
  typeBtnActiveExpense: { backgroundColor: 'rgba(248,113,113,0.15)', borderColor: theme.expense },
  typeBtnActiveIncome: { backgroundColor: 'rgba(74,222,128,0.15)', borderColor: theme.income },
  typeBtnText: { fontSize: 14, fontWeight: '700', color: theme.textSec },
  typeBtnTextActive: { color: theme.white },
  label: { fontSize: 12, fontWeight: '600', color: theme.textSec, marginBottom: 6, marginTop: 14 },
  input: {
    borderWidth: 1, borderColor: theme.border, borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 12, fontSize: 15,
    color: theme.inputText, backgroundColor: theme.inputBg,
  },
  catGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 4 },
  catChip: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    paddingHorizontal: 12, paddingVertical: 9, borderRadius: 10,
    borderWidth: 1, borderColor: theme.border, backgroundColor: theme.surface, maxWidth: 160,
  },
  catChipActive: { borderColor: theme.gold, backgroundColor: theme.goldSoft },
  catChipLabel: { fontSize: 13, fontWeight: '600', color: theme.textSec },
  catChipLabelActive: { color: theme.white },
  emptyText: { fontSize: 13, color: theme.textSec },
  saveBtn: {
    marginTop: 28, backgroundColor: theme.gold, borderRadius: 12,
    paddingVertical: 15, alignItems: 'center',
  },
  saveBtnText: { color: theme.bg, fontSize: 15, fontWeight: '700' },
  deleteBtn: {
    marginTop: 12, borderRadius: 12, paddingVertical: 15, alignItems: 'center',
    borderWidth: 1, borderColor: theme.danger,
  },
  deleteBtnText: { color: theme.danger, fontSize: 15, fontWeight: '700' },
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
import { useFocusEffect, useRouter } from 'expo-router';
import { useAuth }         from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget }       from '../../../src/hooks/useBudget';
import { useCategories }   from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';
import { BellIcon, CalendarIcon, SettingsIcon } from '../../../src/components/Icons';
import { CategoryIcon } from '../../../src/components/CategoryIcon';

const now = new Date();

export default function SummaryScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();
  const router = useRouter();

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
          <View style={{ flexDirection: 'row', gap: 8 }}>
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
          <TouchableOpacity
            key={tx.id}
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
              {tx.type === 'income' ? '+' : '-'}{fCHF(tx.amount)}
            </Text>
          </TouchableOpacity>
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

mkdir -p "$(dirname "app/(app)/(tabs)/projecoes.tsx")"
cat > "app/(app)/(tabs)/projecoes.tsx" << 'FILEEOF'
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
FILEEOF

npx tsc --noEmit
echo "Confirmando que nao ha import de modulo nativo novo..."
if grep -rlE "^import.*react-native-gesture-handler|^import.*react-native-purchases" app/ src/ 2>/dev/null; then
  echo "AVISO: encontrou import nativo novo, revisar antes de usar o tunel"
else
  echo "OK: seguro para usar com o binario ja instalado (tunel)"
fi

echo "Fazendo commit..."
git add -A
git commit -m "Edit/delete transaction via tap (JS-only, no swipe gesture yet), fix Projecoes patrimonio/investido split"
git push

echo ""
echo "Pronto! Agora e so rodar:"
echo "  npx expo start --dev-client --tunnel"
echo "e testar no app que ja esta instalado no iPhone."
