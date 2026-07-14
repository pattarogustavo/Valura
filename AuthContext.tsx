import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import * as AuthService from '../services/auth.service';
import type { AuthUser, AuthState } from '../types';

// ─── CONTEXT SHAPE ────────────────────────────────────────────────────────────

interface AuthContextValue extends AuthState {
  signInWithEmail:    (email: string, password: string) => Promise<{ error?: string }>;
  signUpWithEmail:    (email: string, password: string, name?: string) => Promise<{ error?: string }>;
  signInWithGoogle:   () => Promise<{ error?: string }>;
  signInWithApple:    () => Promise<{ error?: string }>;
  signOut:            () => Promise<void>;
  refreshUser:        () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

// ─── PROVIDER ─────────────────────────────────────────────────────────────────

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user:        null,
    loading:     true,
    initialized: false,
  });

  const setUser = (user: AuthUser | null) =>
    setState(s => ({ ...s, user, loading: false, initialized: true }));

  // ── Initialize: restore session on app start ──────────────────────────────
  useEffect(() => {
    let mounted = true;

    const init = async () => {
      const session = await AuthService.getSession();
      if (!mounted) return;

      if (session) {
        const user = await AuthService.getCurrentUser();
        if (mounted) setUser(user);
      } else {
        if (mounted) setUser(null);
      }
    };

    init();

    // ── Listen for auth state changes (OAuth redirects, token refresh, etc.)
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return;
        if (session) {
          const user = await AuthService.getCurrentUser();
          if (mounted) setUser(user);
        } else {
          if (mounted) setUser(null);
        }
      }
    );

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  // ── Methods ───────────────────────────────────────────────────────────────

  const signInWithEmail = useCallback(async (email: string, password: string) => {
    setState(s => ({ ...s, loading: true }));
    const result = await AuthService.signInWithEmail(email, password);
    if (result.ok) {
      setUser(result.data);
      return {};
    }
    setState(s => ({ ...s, loading: false }));
    return { error: result.error };
  }, []);

  const signUpWithEmail = useCallback(async (email: string, password: string, name?: string) => {
    setState(s => ({ ...s, loading: true }));
    const result = await AuthService.signUpWithEmail(email, password, name);
    if (result.ok) {
      setUser(result.data);
      return {};
    }
    setState(s => ({ ...s, loading: false }));
    return { error: result.error };
  }, []);

  const signInWithGoogle = useCallback(async () => {
    setState(s => ({ ...s, loading: true }));
    const result = await AuthService.signInWithGoogle();
    if (result.ok) { setUser(result.data); return {}; }
    setState(s => ({ ...s, loading: false }));
    return { error: result.error };
  }, []);

  const signInWithApple = useCallback(async () => {
    setState(s => ({ ...s, loading: true }));
    const result = await AuthService.signInWithApple();
    if (result.ok) { setUser(result.data); return {}; }
    setState(s => ({ ...s, loading: false }));
    return { error: result.error };
  }, []);

  const signOut = useCallback(async () => {
    setState(s => ({ ...s, loading: true }));
    await AuthService.signOut();
    setUser(null);
  }, []);

  const refreshUser = useCallback(async () => {
    const user = await AuthService.getCurrentUser();
    setUser(user);
  }, []);

  return (
    <AuthContext.Provider value={{
      ...state,
      signInWithEmail,
      signUpWithEmail,
      signInWithGoogle,
      signInWithApple,
      signOut,
      refreshUser,
    }}>
      {children}
    </AuthContext.Provider>
  );
}

// ─── HOOK ─────────────────────────────────────────────────────────────────────

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>');
  return ctx;
}
