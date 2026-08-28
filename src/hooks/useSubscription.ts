import { useState, useEffect, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import * as SubscriptionService from '../services/subscription.service';
import type { Subscription } from '../types';

interface UseSubscriptionReturn {
  subscription:      Subscription | null;
  loading:            boolean;
  hasPremiumAccess:   boolean;
  isTrialing:         boolean;
  isExpired:          boolean;
  refresh:            () => Promise<void>;
}

/**
 * Live subscription status for the current user. Updates automatically
 * when the RevenueCat webhook writes a new status to Supabase (e.g. right
 * after a purchase, renewal, or cancellation completes) via realtime.
 */
export function useSubscription(userId: string): UseSubscriptionReturn {
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    if (!userId) { setLoading(false); return; }
    setLoading(true);
    const sub = await SubscriptionService.getSubscription(userId);
    setSubscription(sub);
    setLoading(false);
  }, [userId]);

  useEffect(() => { load(); }, [load]);

  useEffect(() => {
    if (!userId) return;
    const channel = supabase
      .channel(`subscriptions:${userId}`)
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'subscriptions', filter: `user_id=eq.${userId}` },
        () => { load(); }
      )
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [userId, load]);

  return {
    subscription,
    loading,
    hasPremiumAccess: SubscriptionService.hasPremiumAccess(subscription),
    isTrialing:       SubscriptionService.isTrialing(subscription),
    isExpired:        SubscriptionService.isExpired(subscription),
    refresh:          load,
  };
}
