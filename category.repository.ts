import { supabase } from '../lib/supabase';
import type { Category, CreateCategoryInput, UpdateCategoryInput, MonthlySnapshot, Result } from '../types';

// ─── CATEGORIES ───────────────────────────────────────────────────────────────

/** Returns user's categories (own + system defaults they own as copies) */
export async function getUserCategories(userId: string): Promise<Result<Category[]>> {
  const { data, error } = await supabase
    .from('categories')
    .select('*')
    .eq('user_id', userId)
    .order('sort_order', { ascending: true });

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Category[] };
}

export async function createCategory(
  userId: string,
  input: CreateCategoryInput
): Promise<Result<Category>> {
  const { data, error } = await supabase
    .from('categories')
    .insert({ ...input, user_id: userId, is_system: false })
    .select()
    .single();

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Category };
}

export async function updateCategory(
  userId: string,
  id: string,
  input: UpdateCategoryInput
): Promise<Result<Category>> {
  const { data, error } = await supabase
    .from('categories')
    .update(input)
    .eq('id', id)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Category };
}

/** Only custom (non-system) categories can be deleted */
export async function deleteCategory(
  userId: string,
  id: string
): Promise<Result<void>> {
  const { error } = await supabase
    .from('categories')
    .delete()
    .eq('id', id)
    .eq('user_id', userId)
    .eq('is_system', false);

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: undefined };
}

// ─── MONTHLY SNAPSHOTS ────────────────────────────────────────────────────────

/** Last N months of snapshots for the Analysis screen */
export async function getRecentSnapshots(
  userId: string,
  limit = 6
): Promise<Result<MonthlySnapshot[]>> {
  const { data, error } = await supabase
    .from('monthly_snapshots')
    .select('*')
    .eq('user_id', userId)
    .order('year',  { ascending: false })
    .order('month', { ascending: false })
    .limit(limit);

  if (error) return { ok: false, error: error.message };
  // Return in chronological order (oldest first) for charts
  return { ok: true, data: (data as MonthlySnapshot[]).reverse() };
}
