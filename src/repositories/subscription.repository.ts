import { supabase } from '../lib/supabase';
import type { Result, Subscription } from '../types';

/**
 * Reads the current user's subscription row. This table is READ-ONLY from
 * the client (RLS only grants SELECT) — all writes happen server-side via
 * the RevenueCat webhook Edge Function using the service role key.
 */
export async function getSubscription(userId: string): Promise<Result<Subscription | null>> {
  const { data, error } = await supabase
    .from('subscriptions')
    .select('*')
    .eq('user_id', userId)
    .maybeSingle();

  if (error) return { ok: false, error: error.message };
  return { ok: true, data: data as Subscription | null };
}
