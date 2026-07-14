import { useState, useEffect, useCallback } from 'react';
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
