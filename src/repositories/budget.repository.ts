import { supabase } from '../lib/supabase';
import type { Budget, BudgetMap, UpsertBudgetInput, Result } from '../types';

/** Returns budget map for a given YYYY-MM month */
export async function getMonthBudget(
  userId: string,
  monthYear: string    // 'YYYY-MM'
): Promise<Result<BudgetMap>> {
  const { data, error } = await supabase
    .from('budgets')
    .select('cat_id, amount')
    .eq('user_id', userId)
    .eq('month_year', monthYear);

  if (error) return { ok: false, error: error.message };

  const map: BudgetMap = {};
  for (const row of data as Pick<Budget, 'cat_id' | 'amount'>[]) {
    map[row.cat_id] = Number(row.amount);
  }
  return { ok: true, data: map };
}

/** Upserts a single category budget — creates or updates */
export async function upsertBudget(
  userId: string,
  input: UpsertBudgetInput
): Promise<Result<Budget>> {
  const { data, error } = await supabase
    .from('budgets')
    .upsert(
      { ...input, user_id: userId },
      { onConflict: 'user_id,cat_id,month_year' }
    )
    .select()
    .single();

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Budget };
}

/** Bulk-seeds a full budget map (used on first login / migration) */
export async function bulkUpsertBudget(
  userId: string,
  map: BudgetMap,
  monthYear: string
): Promise<Result<void>> {
  if (Object.keys(map).length === 0) return { ok: true, data: undefined };

  const rows = Object.entries(map).map(([cat_id, amount]) => ({
    user_id: userId,
    cat_id,
    amount,
    month_year: monthYear,
  }));

  const { error } = await supabase
    .from('budgets')
    .upsert(rows, { onConflict: 'user_id,cat_id,month_year', ignoreDuplicates: true });

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: undefined };
}
