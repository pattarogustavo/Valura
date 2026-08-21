#!/bin/bash
set -e
echo "Aplicando correção de erro silencioso ao adicionar transação..."

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
  updateTransaction: (id: string, input: Partial<CreateTransactionInput>) => Promise<void>;
  deleteTransaction: (id: string) => Promise<void>;
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
    } else {
      await load(); // re-sync from DB on failure
      setError(result.error);
    }
  }, [userId, load]);

  const deleteTransaction = useCallback(async (id: string) => {
    // Optimistic delete
    setTransactions(prev => prev.filter(t => t.id !== id));
    const result = await TxRepo.deleteTransaction(userId, id);
    if (!result.ok) {
      await load(); // restore on failure
      setError(result.error);
    }
  }, [userId, load]);

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
    const result = await addTransaction({
      description: description.trim(),
      amount: parseFloat(amount.replace(',', '.')),
      cat_id: catId!,
      type,
      date: now.toISOString().slice(0, 10),
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

npx tsc --noEmit
echo "TypeScript OK. Fazendo commit..."
git add -A
git commit -m "Fix: surface real errors when adding a transaction instead of failing silently"
git push
echo "Pronto! Recarrega o app (tecla r) e tenta adicionar a transação de novo."
