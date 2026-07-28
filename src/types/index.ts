// ─── DOMAIN TYPES ─────────────────────────────────────────────────────────────

export interface Profile {
  id: string;
  display_name: string | null;
  avatar_url: string | null;
  currency_code: string;
  monthly_income: number;
  net_worth: number;
  onboarded: boolean;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  user_id: string | null;   // null = system default
  slug: string;
  label: string;
  icon: string;
  color: string;
  bg: string;
  type: 'income' | 'expense';
  is_system: boolean;
  sort_order: number;
  created_at: string;
}

export interface Transaction {
  id: string;
  user_id: string;
  description: string;
  amount: number;
  cat_id: string;
  type: 'income' | 'expense';
  date: string;           // ISO 'YYYY-MM-DD'
  notes?: string | null;
  created_at: string;
  updated_at: string;
}

export interface Budget {
  id: string;
  user_id: string;
  cat_id: string;
  amount: number;
  month_year: string;     // 'YYYY-MM'
  created_at: string;
  updated_at: string;
}

export interface MonthlySnapshot {
  id: string;
  user_id: string;
  month: number;          // 0-indexed
  year: number;
  total_income: number;
  total_expense: number;
  by_category: Record<string, number>;
  created_at: string;
  updated_at: string;
}

// ─── INPUT TYPES ──────────────────────────────────────────────────────────────

export type CreateTransactionInput = Omit<Transaction, 'id' | 'user_id' | 'created_at' | 'updated_at'>;
export type UpdateTransactionInput = Partial<CreateTransactionInput>;

export type CreateCategoryInput = Omit<Category, 'id' | 'user_id' | 'is_system' | 'created_at'>;
export type UpdateCategoryInput = Partial<CreateCategoryInput>;

export type UpsertBudgetInput = {
  cat_id: string;
  amount: number;
  month_year: string;
};

export type UpdateProfileInput = Partial<Pick<Profile, 'display_name' | 'avatar_url' | 'currency_code' | 'monthly_income' | 'net_worth' | 'onboarded'>>;

// ─── AUTH TYPES ───────────────────────────────────────────────────────────────

export interface AuthUser {
  id: string;
  email: string | null;
  profile: Profile | null;
}

export interface AuthState {
  user: AuthUser | null;
  loading: boolean;
  initialized: boolean;
}

export type AuthError =
  | 'invalid_credentials'
  | 'email_taken'
  | 'weak_password'
  | 'network_error'
  | 'oauth_cancelled'
  | 'email_not_confirmed'
  | 'unknown';

// ─── RESULT WRAPPER ───────────────────────────────────────────────────────────

export type Result<T> =
  | { ok: true;  data: T }
  | { ok: false; error: string; code?: AuthError };

// ─── BUDGET MAP (summary view) ────────────────────────────────────────────────

// key = cat_id, value = planned amount
export type BudgetMap = Record<string, number>;

// ─── SUPABASE DATABASE TYPES (auto-generated shape) ──────────────────────────

export type Database = {
  public: {
    Tables: {
      profiles:         { Row: Profile };
      categories:       { Row: Category };
      transactions:     { Row: Transaction };
      budgets:          { Row: Budget };
      monthly_snapshots:{ Row: MonthlySnapshot };
    };
  };
};
