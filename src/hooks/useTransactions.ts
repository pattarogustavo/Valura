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
