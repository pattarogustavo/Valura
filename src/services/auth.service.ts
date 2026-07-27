import * as AppleAuthentication from 'expo-apple-authentication';
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
      return { ok: false, error: 'No identity token', code: 'oauth_cancelled' };
    }

    const { data, error } = await supabase.auth.signInWithIdToken({
      provider: 'apple',
      token: identityToken,
    });

    if (error) return { ok: false, error: error.message, code: mapError(error.message) };

    const user = await buildAuthUser();
    return { ok: true, data: user! };

  } catch (e: any) {
    // ERR_REQUEST_CANCELED = utilizador cancelou — não é crash
    if (e.code === 'ERR_REQUEST_CANCELED') {
      return { ok: false, error: 'Cancelled', code: 'oauth_cancelled' };
    }
    return { ok: false, error: e.message ?? 'Unknown error', code: 'unknown' };
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
