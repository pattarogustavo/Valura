import * as SubscriptionService from './subscription.service';
import type { Subscription } from '../types';

/**
 * AdService — centralizes the free-vs-premium ad decision so it's never
 * scattered across screens. No ad platform is integrated yet; this only
 * decides WHETHER ads should show, not how to render them.
 *
 * Wiring a real ad SDK later (AdMob, etc.) only touches this file plus
 * wherever the actual ad units get rendered — the decision logic itself
 * (free users see ads, premium users don't) stays here.
 */
export function shouldShowAds(subscription: Subscription | null): boolean {
  return !SubscriptionService.hasPremiumAccess(subscription);
}
