import * as SubscriptionRepo from '../repositories/subscription.repository';
import type { Subscription, SubscriptionStatus } from '../types';

/**
 * SubscriptionService — the ONLY place in the app that should know about
 * subscription/entitlement logic. UI code should call these functions
 * instead of reading `subscription.status` directly, so that when the
 * RevenueCat native SDK is wired in later, only this file needs to change.
 *
 * Current state: reads subscription status from Supabase (`subscriptions`
 * table), which is kept up to date by the RevenueCat webhook. Purchase
 * actions (startPurchase / restorePurchases / identifyUser) are stubs —
 * they'll call the `react-native-purchases` SDK once it's installed, which
 * requires a new native build and is intentionally deferred.
 */

const ACTIVE_STATUSES: SubscriptionStatus[] = ['trialing', 'active', 'cancelled', 'billing_issue', 'grace_period'];
// Note: 'cancelled' still grants access — the user turned off auto-renew
// but already paid through `expires_at`. The expiry check below is what
// actually cuts off access once the paid period truly ends.

// ─── STATUS ───────────────────────────────────────────────────────────────────

export async function getSubscription(userId: string): Promise<Subscription | null> {
  const result = await SubscriptionRepo.getSubscription(userId);
  return result.ok ? result.data : null;
}

/** True if the user currently has paid/trial access, regardless of the
 *  specific entitlement name — use `hasEntitlement` if you need to check
 *  a specific one (useful once there's more than one paid tier). */
export function hasPremiumAccess(subscription: Subscription | null): boolean {
  if (!subscription) return false;
  if (!ACTIVE_STATUSES.includes(subscription.status)) return false;
  if (subscription.expires_at && new Date(subscription.expires_at).getTime() < Date.now()) {
    return false; // status hasn't caught up with expiry yet — fail closed
  }
  return true;
}

export function hasEntitlement(subscription: Subscription | null, entitlement: string): boolean {
  return hasPremiumAccess(subscription) && subscription?.entitlement === entitlement;
}

export function isTrialing(subscription: Subscription | null): boolean {
  return subscription?.status === 'trialing';
}

export function isExpired(subscription: Subscription | null): boolean {
  if (!subscription) return false;
  return subscription.status === 'expired'
    || (!!subscription.expires_at && new Date(subscription.expires_at).getTime() < Date.now());
}

export function willRenew(subscription: Subscription | null): boolean {
  return subscription?.will_renew ?? false;
}

// ─── PURCHASE ACTIONS (stubs until react-native-purchases is installed) ──────

/**
 * Associates the Supabase user with a RevenueCat customer. Should be
 * called once, right after sign-in, with `Purchases.logIn(userId)` — using
 * the Supabase user id as RevenueCat's App User ID keeps the two systems
 * in lockstep (see item 15 of the subscriptions plan).
 */
export async function identifyUser(userId: string): Promise<void> {
  // TODO(revenuecat-sdk): Purchases.logIn(userId)
  if (__DEV__) {
    console.info('[SubscriptionService] identifyUser stub — RevenueCat SDK not installed yet:', userId);
  }
}

/** Clears the RevenueCat identity on sign-out. */
export async function resetIdentity(): Promise<void> {
  // TODO(revenuecat-sdk): Purchases.logOut()
  if (__DEV__) {
    console.info('[SubscriptionService] resetIdentity stub — RevenueCat SDK not installed yet');
  }
}

export async function startPurchase(productId: string): Promise<{ ok: boolean; error?: string }> {
  // TODO(revenuecat-sdk): const { customerInfo } = await Purchases.purchaseProduct(productId)
  return { ok: false, error: 'Compras ainda não estão disponíveis nesta versão do app.' };
}

export async function restorePurchases(): Promise<{ ok: boolean; error?: string }> {
  // TODO(revenuecat-sdk): const customerInfo = await Purchases.restorePurchases()
  return { ok: false, error: 'Restaurar compras ainda não está disponível nesta versão do app.' };
}
