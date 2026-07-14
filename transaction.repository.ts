import { supabase } from '../lib/supabase';
import type { Transaction, CreateTransactionInput, UpdateTransactionInput, Result } from '../types';

// ─── HELPERS ─────────────────────────────────────────────────────────────────

function monthRange(year: number, month: number): [string, string] {
  const y = year, m = month + 1; // month is 0-indexed
  const start = `${y}-${String(m).padStart(2,'0')}-01`;
  const nextM = m === 12 ? 1  : m + 1;
  const nextY = m === 12 ? y + 1 : y;
  const end   = `${nextY}-${String(nextM).padStart(2,'0')}-01`;
  return [start, end];
}

// ─── QUERIES ─────────────────────────────────────────────────────────────────

/** All transactions for the current month */
export async function getMonthTransactions(
  userId: string,
  year: number,
  month: number
): Promise<Result<Transaction[]>> {
  const [start, end] = monthRange(year, month);
  const { data, error } = await supabase
    .from('transactions')
    .select('*')
    .eq('user_id', userId)
    .gte('date', start)
    .lt('date', end)
    .order('date', { ascending: false })
    .order('created_at', { ascending: false });

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Transaction[] };
}

/** All transactions (for cross-device restore) */
export async function getAllTransactions(
  userId: string
): Promise<Result<Transaction[]>> {
  const { data, error } = await supabase
    .from('transactions')
    .select('*')
    .eq('user_id', userId)
    .order('date', { ascending: false });

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Transaction[] };
}

// ─── MUTATIONS ────────────────────────────────────────────────────────────────

export async function createTransaction(
  userId: string,
  input: CreateTransactionInput
): Promise<Result<Transaction>> {
  const { data, error } = await supabase
    .from('transactions')
    .insert({ ...input, user_id: userId })
    .select()
    .single();

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Transaction };
}

export async function updateTransaction(
  userId: string,
  id: string,
  input: UpdateTransactionInput
): Promise<Result<Transaction>> {
  const { data, error } = await supabase
    .from('transactions')
    .update(input)
    .eq('id', id)
    .eq('user_id', userId)     // RLS double-check
    .select()
    .single();

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Transaction };
}

export async function deleteTransaction(
  userId: string,
  id: string
): Promise<Result<void>> {
  const { error } = await supabase
    .from('transactions')
    .delete()
    .eq('id', id)
    .eq('user_id', userId);

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: undefined };
}

// ─── BULK MIGRATION (first login from local data) ────────────────────────────

export async function bulkInsertTransactions(
  userId: string,
  txs: CreateTransactionInput[]
): Promise<Result<Transaction[]>> {
  if (txs.length === 0) return { ok: true, data: [] };

  const rows = txs.map(t => ({ ...t, user_id: userId }));

  const { data, error } = await supabase
    .from('transactions')
    .upsert(rows, {
      onConflict: 'user_id,description,amount,date', // prevent duplicates
      ignoreDuplicates: true,
    })
    .select();

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Transaction[] };
}
