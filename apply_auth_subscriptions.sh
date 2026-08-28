#!/bin/bash
set -e
echo "Aplicando telas de auth que faltavam + camada de subscription/ads..."
mkdir -p src/repositories src/services src/hooks "app/(auth)"

mkdir -p "$(dirname "app/(auth)/register.tsx")"
cat > "app/(auth)/register.tsx" << 'FILEEOF'
import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, KeyboardAvoidingView, Platform,
  ScrollView, ActivityIndicator,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';

const T = {
  brand:   '#1756F5',
  text:    '#0A1929',
  textSec: '#3D5168',
  textTer: '#8097B1',
  border:  '#D8E4F0',
  white:   '#FFFFFF',
  red:     '#E53935',
};

export default function RegisterScreen() {
  const { signUpWithEmail, loading } = useAuth();
  const router = useRouter();

  const [name,     setName]     = useState('');
  const [email,    setEmail]    = useState('');
  const [password, setPassword] = useState('');
  const [confirm,  setConfirm]  = useState('');
  const [pwHidden, setPwHidden] = useState(true);
  const [error,    setError]    = useState('');

  const handleSubmit = async () => {
    if (!name.trim() || !email.trim() || !password) {
      setError('Preencha todos os campos.');
      return;
    }
    if (password.length < 6) {
      setError('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (password !== confirm) {
      setError('As senhas não coincidem.');
      return;
    }
    setError('');
    const res = await signUpWithEmail(email.trim(), password, name.trim());
    if (res.error) setError(res.error);
    // On success, AuthContext's onAuthStateChange listener updates the user
    // and the root layout redirects into the app automatically.
  };

  return (
    <KeyboardAvoidingView style={styles.root} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <View style={styles.header}>
          <View style={styles.logoCircle}>
            <Text style={styles.logoText}>V</Text>
          </View>
          <Text style={styles.appName}>Criar conta</Text>
          <Text style={styles.tagline}>Comece a organizar suas finanças</Text>
        </View>

        {!!error && (
          <View style={styles.errorBox}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}

        <View style={styles.field}>
          <Text style={styles.label}>Nome</Text>
          <TextInput
            style={styles.input}
            value={name}
            onChangeText={setName}
            placeholder="Seu nome"
            placeholderTextColor={T.textTer}
            autoCapitalize="words"
            autoComplete="name"
          />
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>E-mail</Text>
          <TextInput
            style={styles.input}
            value={email}
            onChangeText={setEmail}
            placeholder="seu@email.com"
            placeholderTextColor={T.textTer}
            keyboardType="email-address"
            autoCapitalize="none"
            autoComplete="email"
          />
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>Password</Text>
          <View style={styles.passwordWrap}>
            <TextInput
              style={[styles.input, { flex: 1, borderWidth: 0 }]}
              value={password}
              onChangeText={setPassword}
              placeholder="Mínimo 6 caracteres"
              placeholderTextColor={T.textTer}
              secureTextEntry={pwHidden}
              autoCapitalize="none"
            />
            <TouchableOpacity onPress={() => setPwHidden(!pwHidden)} style={styles.eyeBtn}>
              <Text style={styles.eyeText}>{pwHidden ? 'Mostrar' : 'Ocultar'}</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>Confirmar password</Text>
          <TextInput
            style={styles.input}
            value={confirm}
            onChangeText={setConfirm}
            placeholder="Repita a senha"
            placeholderTextColor={T.textTer}
            secureTextEntry={pwHidden}
            autoCapitalize="none"
          />
        </View>

        <TouchableOpacity
          style={[styles.primaryBtn, loading && styles.btnDisabled]}
          onPress={handleSubmit}
          disabled={loading}
          activeOpacity={0.85}
        >
          {loading
            ? <ActivityIndicator color={T.white} />
            : <Text style={styles.primaryBtnText}>Criar conta</Text>
          }
        </TouchableOpacity>

        <View style={styles.loginRow}>
          <Text style={styles.loginText}>Já tem conta? </Text>
          <TouchableOpacity onPress={() => router.back()}>
            <Text style={styles.loginLink}>Entrar</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  root:           { flex: 1, backgroundColor: T.white },
  scroll:         { flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 },
  header:         { alignItems: 'center', paddingTop: 60, paddingBottom: 32 },
  logoCircle:     { width: 64, height: 64, borderRadius: 32, backgroundColor: T.brand, alignItems: 'center', justifyContent: 'center', marginBottom: 14 },
  logoText:       { fontSize: 28, fontWeight: '800', color: T.white },
  appName:        { fontSize: 24, fontWeight: '800', color: T.text, letterSpacing: -0.5, marginBottom: 6 },
  tagline:        { fontSize: 14, color: T.textSec, fontWeight: '400' },
  errorBox:       { backgroundColor: '#FDECEA', borderRadius: 10, padding: 12, marginBottom: 16 },
  errorText:      { color: T.red, fontSize: 13, fontWeight: '500' },
  field:          { marginBottom: 16 },
  label:          { fontSize: 13, fontWeight: '500', color: T.textSec, marginBottom: 6 },
  input:          { borderWidth: 1.5, borderColor: T.border, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: T.text, backgroundColor: T.white },
  passwordWrap:   { flexDirection: 'row', alignItems: 'center', borderWidth: 1.5, borderColor: T.border, borderRadius: 10, overflow: 'hidden', backgroundColor: T.white },
  eyeBtn:         { paddingHorizontal: 12, paddingVertical: 12 },
  eyeText:        { fontSize: 13, color: T.brand, fontWeight: '600' },
  primaryBtn:     { backgroundColor: T.brand, borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 8, shadowColor: T.brand, shadowOpacity: 0.35, shadowRadius: 12, shadowOffset: { width: 0, height: 4 }, elevation: 6 },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: T.white, letterSpacing: -0.2 },
  btnDisabled:    { opacity: 0.6 },
  loginRow:       { flexDirection: 'row', justifyContent: 'center', marginTop: 24 },
  loginText:      { fontSize: 14, color: T.textSec },
  loginLink:      { fontSize: 14, color: T.brand, fontWeight: '600' },
});
FILEEOF

mkdir -p "$(dirname "app/(auth)/forgot-password.tsx")"
cat > "app/(auth)/forgot-password.tsx" << 'FILEEOF'
import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, KeyboardAvoidingView, Platform,
  ScrollView, ActivityIndicator,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';

const T = {
  brand:   '#1756F5',
  text:    '#0A1929',
  textSec: '#3D5168',
  textTer: '#8097B1',
  border:  '#D8E4F0',
  white:   '#FFFFFF',
  red:     '#E53935',
  green:   '#00B374',
};

export default function ForgotPasswordScreen() {
  const { sendPasswordReset } = useAuth();
  const router = useRouter();

  const [email, setEmail]       = useState('');
  const [error, setError]       = useState('');
  const [sent, setSent]         = useState(false);
  const [submitting, setSubmit] = useState(false);

  const handleSubmit = async () => {
    if (!email.trim()) { setError('Digite seu e-mail.'); return; }
    setError('');
    setSubmit(true);
    const res = await sendPasswordReset(email.trim());
    setSubmit(false);
    if (res.error) { setError(res.error); return; }
    setSent(true);
  };

  return (
    <KeyboardAvoidingView style={styles.root} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <View style={styles.header}>
          <View style={styles.logoCircle}>
            <Text style={styles.logoText}>V</Text>
          </View>
          <Text style={styles.appName}>Recuperar senha</Text>
          <Text style={styles.tagline}>
            {sent
              ? 'Verifique seu e-mail'
              : 'Enviaremos um link para redefinir sua senha'}
          </Text>
        </View>

        {!!error && (
          <View style={styles.errorBox}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}

        {sent ? (
          <View style={styles.successBox}>
            <Text style={styles.successText}>
              Se existir uma conta com o e-mail {email.trim()}, você vai receber um link
              para redefinir sua senha em instantes.
            </Text>
          </View>
        ) : (
          <>
            <View style={styles.field}>
              <Text style={styles.label}>E-mail</Text>
              <TextInput
                style={styles.input}
                value={email}
                onChangeText={setEmail}
                placeholder="seu@email.com"
                placeholderTextColor={T.textTer}
                keyboardType="email-address"
                autoCapitalize="none"
                autoComplete="email"
              />
            </View>

            <TouchableOpacity
              style={[styles.primaryBtn, submitting && styles.btnDisabled]}
              onPress={handleSubmit}
              disabled={submitting}
              activeOpacity={0.85}
            >
              {submitting
                ? <ActivityIndicator color={T.white} />
                : <Text style={styles.primaryBtnText}>Enviar link</Text>
              }
            </TouchableOpacity>
          </>
        )}

        <View style={styles.loginRow}>
          <TouchableOpacity onPress={() => router.back()}>
            <Text style={styles.loginLink}>Voltar para o login</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  root:           { flex: 1, backgroundColor: T.white },
  scroll:         { flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 },
  header:         { alignItems: 'center', paddingTop: 60, paddingBottom: 32 },
  logoCircle:     { width: 64, height: 64, borderRadius: 32, backgroundColor: T.brand, alignItems: 'center', justifyContent: 'center', marginBottom: 14 },
  logoText:       { fontSize: 28, fontWeight: '800', color: T.white },
  appName:        { fontSize: 24, fontWeight: '800', color: T.text, letterSpacing: -0.5, marginBottom: 6 },
  tagline:        { fontSize: 14, color: T.textSec, fontWeight: '400', textAlign: 'center', paddingHorizontal: 16 },
  errorBox:       { backgroundColor: '#FDECEA', borderRadius: 10, padding: 12, marginBottom: 16 },
  errorText:      { color: T.red, fontSize: 13, fontWeight: '500' },
  successBox:     { backgroundColor: '#E7F8F1', borderRadius: 10, padding: 16 },
  successText:    { color: T.green, fontSize: 14, lineHeight: 20, fontWeight: '500' },
  field:          { marginBottom: 16 },
  label:          { fontSize: 13, fontWeight: '500', color: T.textSec, marginBottom: 6 },
  input:          { borderWidth: 1.5, borderColor: T.border, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: T.text, backgroundColor: T.white },
  primaryBtn:     { backgroundColor: T.brand, borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 8, shadowColor: T.brand, shadowOpacity: 0.35, shadowRadius: 12, shadowOffset: { width: 0, height: 4 }, elevation: 6 },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: T.white, letterSpacing: -0.2 },
  btnDisabled:    { opacity: 0.6 },
  loginRow:       { flexDirection: 'row', justifyContent: 'center', marginTop: 24 },
  loginLink:      { fontSize: 14, color: T.brand, fontWeight: '600' },
});
FILEEOF

mkdir -p "$(dirname "app/(auth)/reset-password.tsx")"
cat > "app/(auth)/reset-password.tsx" << 'FILEEOF'
import React, { useEffect, useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, KeyboardAvoidingView, Platform,
  ScrollView, ActivityIndicator,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { supabase } from '../../src/lib/supabase';
import { useAuth } from '../../src/context/AuthContext';

const T = {
  brand:   '#1756F5',
  text:    '#0A1929',
  textSec: '#3D5168',
  textTer: '#8097B1',
  border:  '#D8E4F0',
  white:   '#FFFFFF',
  red:     '#E53935',
  green:   '#00B374',
};

export default function ResetPasswordScreen() {
  // Supabase sends a `code` query param in the recovery link (PKCE flow).
  // detectSessionInUrl is disabled for React Native, so we exchange it
  // for a session manually here.
  const params = useLocalSearchParams<{ code?: string }>();
  const router = useRouter();
  const { updatePassword } = useAuth();

  const [exchanging, setExchanging] = useState(true);
  const [sessionReady, setSessionReady] = useState(false);
  const [error, setError] = useState('');

  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [pwHidden, setPwHidden] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [done, setDone] = useState(false);

  useEffect(() => {
    let mounted = true;
    async function exchange() {
      if (!params.code) {
        if (mounted) {
          setError('Link inválido ou expirado. Solicite um novo link de recuperação.');
          setExchanging(false);
        }
        return;
      }
      const { error } = await supabase.auth.exchangeCodeForSession(params.code);
      if (!mounted) return;
      if (error) {
        setError('Link inválido ou expirado. Solicite um novo link de recuperação.');
      } else {
        setSessionReady(true);
      }
      setExchanging(false);
    }
    exchange();
    return () => { mounted = false; };
  }, [params.code]);

  const handleSubmit = async () => {
    if (password.length < 6) { setError('A senha precisa ter pelo menos 6 caracteres.'); return; }
    if (password !== confirm) { setError('As senhas não coincidem.'); return; }
    setError('');
    setSubmitting(true);
    const res = await updatePassword(password);
    setSubmitting(false);
    if (res.error) { setError(res.error); return; }
    setDone(true);
  };

  return (
    <KeyboardAvoidingView style={styles.root} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <View style={styles.header}>
          <View style={styles.logoCircle}>
            <Text style={styles.logoText}>V</Text>
          </View>
          <Text style={styles.appName}>Nova senha</Text>
          {!exchanging && sessionReady && !done && (
            <Text style={styles.tagline}>Escolha uma nova senha para sua conta</Text>
          )}
        </View>

        {exchanging && (
          <View style={styles.center}>
            <ActivityIndicator color={T.brand} size="large" />
          </View>
        )}

        {!exchanging && !!error && (
          <View style={styles.errorBox}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}

        {!exchanging && sessionReady && !done && (
          <>
            <View style={styles.field}>
              <Text style={styles.label}>Nova senha</Text>
              <View style={styles.passwordWrap}>
                <TextInput
                  style={[styles.input, { flex: 1, borderWidth: 0 }]}
                  value={password}
                  onChangeText={setPassword}
                  placeholder="Mínimo 6 caracteres"
                  placeholderTextColor={T.textTer}
                  secureTextEntry={pwHidden}
                  autoCapitalize="none"
                />
                <TouchableOpacity onPress={() => setPwHidden(!pwHidden)} style={styles.eyeBtn}>
                  <Text style={styles.eyeText}>{pwHidden ? 'Mostrar' : 'Ocultar'}</Text>
                </TouchableOpacity>
              </View>
            </View>

            <View style={styles.field}>
              <Text style={styles.label}>Confirmar nova senha</Text>
              <TextInput
                style={styles.input}
                value={confirm}
                onChangeText={setConfirm}
                placeholder="Repita a senha"
                placeholderTextColor={T.textTer}
                secureTextEntry={pwHidden}
                autoCapitalize="none"
              />
            </View>

            <TouchableOpacity
              style={[styles.primaryBtn, submitting && styles.btnDisabled]}
              onPress={handleSubmit}
              disabled={submitting}
              activeOpacity={0.85}
            >
              {submitting
                ? <ActivityIndicator color={T.white} />
                : <Text style={styles.primaryBtnText}>Salvar nova senha</Text>
              }
            </TouchableOpacity>
          </>
        )}

        {done && (
          <View style={styles.successBox}>
            <Text style={styles.successText}>Senha alterada com sucesso!</Text>
            <TouchableOpacity style={[styles.primaryBtn, { marginTop: 16 }]} onPress={() => router.replace('/')}>
              <Text style={styles.primaryBtnText}>Continuar</Text>
            </TouchableOpacity>
          </View>
        )}

        {!exchanging && !sessionReady && (
          <TouchableOpacity style={styles.primaryBtn} onPress={() => router.replace('/(auth)/forgot-password')}>
            <Text style={styles.primaryBtnText}>Solicitar novo link</Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  root:           { flex: 1, backgroundColor: T.white },
  scroll:         { flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 },
  header:         { alignItems: 'center', paddingTop: 60, paddingBottom: 32 },
  logoCircle:     { width: 64, height: 64, borderRadius: 32, backgroundColor: T.brand, alignItems: 'center', justifyContent: 'center', marginBottom: 14 },
  logoText:       { fontSize: 28, fontWeight: '800', color: T.white },
  appName:        { fontSize: 24, fontWeight: '800', color: T.text, letterSpacing: -0.5, marginBottom: 6 },
  tagline:        { fontSize: 14, color: T.textSec, fontWeight: '400', textAlign: 'center' },
  center:         { alignItems: 'center', paddingVertical: 20 },
  errorBox:       { backgroundColor: '#FDECEA', borderRadius: 10, padding: 12, marginBottom: 16 },
  errorText:      { color: T.red, fontSize: 13, fontWeight: '500' },
  successBox:     { backgroundColor: '#E7F8F1', borderRadius: 10, padding: 16, alignItems: 'center' },
  successText:    { color: T.green, fontSize: 15, fontWeight: '600' },
  field:          { marginBottom: 16 },
  label:          { fontSize: 13, fontWeight: '500', color: T.textSec, marginBottom: 6 },
  input:          { borderWidth: 1.5, borderColor: T.border, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: T.text, backgroundColor: T.white },
  passwordWrap:   { flexDirection: 'row', alignItems: 'center', borderWidth: 1.5, borderColor: T.border, borderRadius: 10, overflow: 'hidden', backgroundColor: T.white },
  eyeBtn:         { paddingHorizontal: 12, paddingVertical: 12 },
  eyeText:        { fontSize: 13, color: T.brand, fontWeight: '600' },
  primaryBtn:     { backgroundColor: T.brand, borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 8, shadowColor: T.brand, shadowOpacity: 0.35, shadowRadius: 12, shadowOffset: { width: 0, height: 4 }, elevation: 6 },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: T.white, letterSpacing: -0.2 },
  btnDisabled:    { opacity: 0.6 },
});
FILEEOF

mkdir -p "$(dirname "src/context/AuthContext.tsx")"
cat > "src/context/AuthContext.tsx" << 'FILEEOF'
import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import * as AuthService from '../services/auth.service';
import * as SubscriptionService from '../services/subscription.service';
import type { AuthUser, AuthState } from '../types';

// ─── CONTEXT SHAPE ────────────────────────────────────────────────────────────

interface AuthContextValue extends AuthState {
  signInWithEmail:    (email: string, password: string) => Promise<{ error?: string }>;
  signUpWithEmail:    (email: string, password: string, name?: string) => Promise<{ error?: string }>;
  signInWithApple:    () => Promise<{ error?: string }>;
  signOut:            () => Promise<void>;
  refreshUser:        () => Promise<void>;
  sendPasswordReset:  (email: string) => Promise<{ error?: string }>;
  updatePassword:     (newPassword: string) => Promise<{ error?: string }>;
  deleteAccount:      () => Promise<{ error?: string }>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

// ─── PROVIDER ─────────────────────────────────────────────────────────────────

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user:        null,
    loading:     true,
    initialized: false,
  });

  const setUser = (user: AuthUser | null) => {
    setState(s => ({ ...s, user, loading: false, initialized: true }));
    // Keep RevenueCat's identity in lockstep with the Supabase user (see
    // SubscriptionService — these are stubs until the native SDK is added).
    if (user) {
      SubscriptionService.identifyUser(user.id);
    } else {
      SubscriptionService.resetIdentity();
    }
  };

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

  const sendPasswordReset = useCallback(async (email: string) => {
    const result = await AuthService.sendPasswordReset(email);
    if (result.ok) return {};
    return { error: result.error };
  }, []);

  const updatePassword = useCallback(async (newPassword: string) => {
    const result = await AuthService.updatePassword(newPassword);
    if (result.ok) return {};
    return { error: result.error };
  }, []);

  const deleteAccount = useCallback(async () => {
    const result = await AuthService.deleteAccount();
    if (result.ok) {
      setUser(null);
      return {};
    }
    return { error: result.error };
  }, []);

  return (
    <AuthContext.Provider value={{
      ...state,
      signInWithEmail,
      signUpWithEmail,
      signInWithApple,
      signOut,
      refreshUser,
      sendPasswordReset,
      updatePassword,
      deleteAccount,
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
FILEEOF

mkdir -p "$(dirname "src/services/auth.service.ts")"
cat > "src/services/auth.service.ts" << 'FILEEOF'
import * as AppleAuthentication from 'expo-apple-authentication';
import { supabase } from '../lib/supabase';
import type { AuthUser, Result, AuthError, UpdateProfileInput } from '../types';

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
      return { ok: false, error: 'No identity token returned from Apple', code: 'oauth_cancelled' };
    }

    const { data, error } = await supabase.auth.signInWithIdToken({
      provider: 'apple',
      token: identityToken,
    });
    if (error) return { ok: false, error: error.message, code: mapError(error.message) };

    // Guarda o nome completo (só disponível no primeiro login)
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

export async function deleteAccount(): Promise<Result<void>> {
  try {
    // IMPORTANT: call the Edge Function BEFORE signing out — it needs the
    // active session's JWT to verify who's calling. It never trusts a
    // client-supplied user id; the account deleted is always the caller's
    // own, resolved server-side from the token.
    const { error } = await supabase.functions.invoke('delete-account');
    if (error) return { ok: false, error: error.message };

    await supabase.auth.signOut();
    return { ok: true, data: undefined };
  } catch (e: any) {
    return { ok: false, error: e.message };
  }
}
FILEEOF

mkdir -p "$(dirname "src/services/subscription.service.ts")"
cat > "src/services/subscription.service.ts" << 'FILEEOF'
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
FILEEOF

mkdir -p "$(dirname "src/services/ad.service.ts")"
cat > "src/services/ad.service.ts" << 'FILEEOF'
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
FILEEOF

mkdir -p "$(dirname "src/repositories/subscription.repository.ts")"
cat > "src/repositories/subscription.repository.ts" << 'FILEEOF'
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
FILEEOF

mkdir -p "$(dirname "src/hooks/useSubscription.ts")"
cat > "src/hooks/useSubscription.ts" << 'FILEEOF'
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
FILEEOF

mkdir -p "$(dirname "src/types/index.ts")"
cat > "src/types/index.ts" << 'FILEEOF'
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

// ─── SUBSCRIPTION ─────────────────────────────────────────────────────────────

export type SubscriptionStatus =
  | 'none'           // never subscribed
  | 'trialing'       // in a free trial period
  | 'active'         // paid and current
  | 'expired'        // lapsed, not renewed
  | 'cancelled'      // user cancelled, may still be active until expires_at
  | 'billing_issue'  // payment failed, Apple/Google retrying
  | 'grace_period';  // billing issue but still within grace window

export interface Subscription {
  user_id:                string;
  revenuecat_customer_id: string | null;
  product_id:              string | null;
  entitlement:             string | null;
  status:                  SubscriptionStatus;
  store:                   string | null;
  expires_at:               string | null; // ISO timestamp
  will_renew:               boolean;
  created_at:               string;
  updated_at:               string;
}

// ─── SUPABASE DATABASE TYPES (auto-generated shape) ──────────────────────────

export type Database = {
  public: {
    Tables: {
      profiles:         { Row: Profile };
      categories:       { Row: Category };
      transactions:     { Row: Transaction };
      budgets:          { Row: Budget };
      monthly_snapshots:{ Row: MonthlySnapshot };
      subscriptions:    { Row: Subscription };
    };
  };
};
FILEEOF

npx tsc --noEmit
echo "TypeScript OK. Fazendo commit..."
git add -A
git commit -m "Add missing auth screens (register/forgot-password/reset-password), fix delete-account security, add subscription/ad service layer"
git push
echo "Pronto! Deploy do banco e das Edge Functions ja foram aplicados direto no Supabase."
