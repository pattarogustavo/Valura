import * as AppleAuthentication from 'expo-apple-authentication';
import * as Google from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';
import { supabase } from '../lib/supabase';
import type { AuthUser, Result, AuthError, UpdateProfileInput } from '../types';

WebBrowser.maybeCompleteAuthSession();

// ─── HELPERS ─────────────────────────────────────────────────────────────────

function mapError(msg: string): AuthError {
  const m = msg.toLowerCase();
  if (m.includes('invalid login credentials')) return 'invalid_credentials';
  if (m.includes('user already registered'))  return 'email_taken';
  if (m.includes('password should be'))       return 'weak_password';
  if (m.includes('email not confirmed'))      return 'email_not_confirmed';
  if (m.includes('network'))                  return 'network_error';
  return 'unknown';
}

async function buildAuthUser(): Promise<AuthUser | null> {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  return { id: user.id, email: user.email ?? null, profile: profile ?? null };
}

// ─── EMAIL AUTH ───────────────────────────────────────────────────────────────

export async function signUpWithEmail(
  email: string,
  password: string,
  displayName?: string
): Promise<Result<AuthUser>> {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: displayName },
        emailRedirectTo: 'valura://auth/callback',
      },
    });
    if (error) return { ok: false, error: error.message, code: mapError(error.message) };
    if (!data.user) return { ok: false, error: 'No user returned', code: 'unknown' };

    const user = await buildAuthUser();
    return { ok: true, data: user! };
  } catch (e: any) {
    return { ok: false, error: e.message, code: 'network_error' };
  }
}

export async function signInWithEmail(
  email: string,
  password: string
): Promise<Result<AuthUser>> {
  try {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return { ok: false, error: error.message, code: mapError(error.message) };

    const user = await buildAuthUser();
    return { ok: true, data: user! };
  } catch (e: any) {
    return { ok: false, error: e.message, code: 'network_error' };
  }
}

export async function sendPasswordReset(email: string): Promise<Result<void>> {
  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: 'valura://auth/reset-password',
    });
    if (error) return { ok: false, error: error.message };
    return { ok: true, data: undefined };
  } catch (e: any) {
    return { ok: false, error: e.message };
  }
}

export async function updatePassword(newPassword: string): Promise<Result<void>> {
  try {
    const { error } = await supabase.auth.updateUser({ password: newPassword });
    if (error) return { ok: false, error: error.message };
    return { ok: true, data: undefined };
  } catch (e: any) {
    return { ok: false, error: e.message };
  }
}

// ─── GOOGLE OAUTH ─────────────────────────────────────────────────────────────
// Configure EXPO_PUBLIC_GOOGLE_CLIENT_ID (Web Client ID from Google Cloud Console)

export async function signInWithGoogle(): Promise<Result<AuthUser>> {
  try {
    const clientId = process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID;
    if (!clientId) throw new Error('EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID not set');

    // This uses expo-auth-session under the hood
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo:   'valura://auth/callback',
        queryParams: { access_type: 'offline', prompt: 'consent' },
      },
    });
    if (error) return { ok: false, error: error.message, code: 'oauth_cancelled' };

    // Open browser for OAuth — the session will be picked up by the deep link listener
    if (data.url) await WebBrowser.openBrowserAsync(data.url);

    const user = await buildAuthUser();
    if (!user) return { ok: false, error: 'OAuth did not complete', code: 'oauth_cancelled' };
    return { ok: true, data: user };
  } catch (e: any) {
    return { ok: false, error: e.message, code: 'oauth_cancelled' };
  }
}

// ─── APPLE SIGN-IN ────────────────────────────────────────────────────────────

export async function signInWithApple(): Promise<Result<AuthUser>> {
  try {
    const credential = await AppleAuthentication.signInAsync({
      requestedScopes: [
        AppleAuthentication.AppleAuthenticationScope.FULL_NAME,
        AppleAuthentication.AppleAuthenticationScope.EMAIL,
      ],
    });

    const { identityToken } = credential;
    if (!identityToken) {
      return { ok: false, error: 'No identity token returned from Apple', code: 'oauth_cancelled' };
    }

    const { data, error } = await supabase.auth.signInWithIdToken({
      provider: 'apple',
      token: identityToken,
    });
    if (error) return { ok: false, error: error.message, code: mapError(error.message) };

    // Update display name if Apple provided it (only available on first login)
    const fullName = [
      credential.fullName?.givenName,
      credential.fullName?.familyName,
    ].filter(Boolean).join(' ');

    if (fullName && data.user) {
      await supabase.from('profiles')
        .update({ display_name: fullName })
        .eq('id', data.user.id);
    }

    const user = await buildAuthUser();
    return { ok: true, data: user! };
  } catch (e: any) {
    if (e.code === 'ERR_REQUEST_CANCELED') {
      return { ok: false, error: 'Cancelled', code: 'oauth_cancelled' };
    }
    return { ok: false, error: e.message, code: 'unknown' };
  }
}

// ─── SESSION ──────────────────────────────────────────────────────────────────

export async function getSession() {
  const { data: { session } } = await supabase.auth.getSession();
  return session;
}

export async function getCurrentUser(): Promise<AuthUser | null> {
  return buildAuthUser();
}

export async function signOut(): Promise<void> {
  await supabase.auth.signOut();
}

// ─── PROFILE ──────────────────────────────────────────────────────────────────

export async function updateProfile(
  userId: string,
  input: UpdateProfileInput
): Promise<Result<void>> {
  try {
    const { error } = await supabase
      .from('profiles')
      .update(input)
      .eq('id', userId);
    if (error) return { ok: false, error: error.message };
    return { ok: true, data: undefined };
  } catch (e: any) {
    return { ok: false, error: e.message };
  }
}

export async function updateEmail(newEmail: string): Promise<Result<void>> {
  try {
    const { error } = await supabase.auth.updateUser({ email: newEmail });
    if (error) return { ok: false, error: error.message };
    return { ok: true, data: undefined };
  } catch (e: any) {
    return { ok: false, error: e.message };
  }
}

// ─── ACCOUNT DELETION ─────────────────────────────────────────────────────────
// All data cascades via FK ON DELETE CASCADE — profiles → all tables

export async function deleteAccount(userId: string): Promise<Result<void>> {
  try {
    // 1. Sign out first to invalidate the session
    await supabase.auth.signOut();

    // 2. Call a server-side Edge Function (avoids needing service_role in client)
    //    The function deletes the auth.users row which cascades to profiles
    const { error } = await supabase.functions.invoke('delete-account', {
      body: { user_id: userId },
    });
    if (error) return { ok: false, error: error.message };
    return { ok: true, data: undefined };
  } catch (e: any) {
    return { ok: false, error: e.message };
  }
}
