/**
 * First-login data migration
 * Uploads any locally stored data to Supabase, then marks migration as done.
 * Called once, right after the user's first successful authentication.
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import { bulkInsertTransactions } from '../repositories/transaction.repository';
import { bulkUpsertBudget }       from '../repositories/budget.repository';
import type { CreateTransactionInput, BudgetMap } from '../types';

const MIGRATION_KEY  = '@valura:migrated';
const LOCAL_TX_KEY   = '@valura:transactions';
const LOCAL_BUD_KEY  = '@valura:budget';

/** Returns true if migration has already been completed */
export async function isMigrated(): Promise<boolean> {
  const v = await AsyncStorage.getItem(MIGRATION_KEY);
  return v === 'true';
}

/** Marks migration as done */
async function markMigrated(): Promise<void> {
  await AsyncStorage.setItem(MIGRATION_KEY, 'true');
}

/**
 * Runs the migration:
 * 1. Reads local transactions and budget from AsyncStorage.
 * 2. Uploads them to Supabase (ignoring duplicates).
 * 3. Sets the migration flag so it never runs again.
 */
export async function runMigration(userId: string): Promise<void> {
  if (await isMigrated()) return;

  const now       = new Date();
  const monthYear = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;

  try {
    // ── Transactions ────────────────────────────────────────────────────────
    const rawTx = await AsyncStorage.getItem(LOCAL_TX_KEY);
    if (rawTx) {
      const localTx: CreateTransactionInput[] = JSON.parse(rawTx);
      if (localTx.length > 0) {
        await bulkInsertTransactions(userId, localTx);
      }
    }

    // ── Budget ───────────────────────────────────────────────────────────────
    const rawBud = await AsyncStorage.getItem(LOCAL_BUD_KEY);
    if (rawBud) {
      const localBud: BudgetMap = JSON.parse(rawBud);
      if (Object.keys(localBud).length > 0) {
        await bulkUpsertBudget(userId, localBud, monthYear);
      }
    }

    await markMigrated();
    console.info('[Valura] Local data migrated to Supabase ✓');
  } catch (e) {
    // Non-fatal: the user can still use the app — data will sync next time
    console.warn('[Valura] Migration error (will retry):', e);
  }
}

/**
 * Saves app state to AsyncStorage for offline support and migration.
 * Call this whenever transactions or budget change.
 */
export async function persistLocally(
  transactions: CreateTransactionInput[],
  budget: BudgetMap
): Promise<void> {
  await Promise.all([
    AsyncStorage.setItem(LOCAL_TX_KEY,  JSON.stringify(transactions)),
    AsyncStorage.setItem(LOCAL_BUD_KEY, JSON.stringify(budget)),
  ]);
}
