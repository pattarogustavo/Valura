import React, { useEffect, useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, KeyboardAvoidingView, Platform,
  ScrollView, ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { supabase } from '../../src/lib/supabase';
import { useAuth } from '../../src/context/AuthContext';
import { theme } from '../../src/theme';
import { EyeIcon, EyeOffIcon } from '../../src/components/Icons';

export default function ResetPasswordScreen() {
  // Supabase sends a `code` query param in the recovery link (PKCE flow).
  // detectSessionInUrl is disabled for React Native, so we exchange it
  // for a session manually here.
  const params = useLocalSearchParams<{ code?: string }>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
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
      <ScrollView contentContainerStyle={[styles.scroll, { paddingTop: insets.top + 40 }]} keyboardShouldPersistTaps="handled">
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
            <ActivityIndicator color={theme.gold} size="large" />
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
                  style={[styles.input, { flex: 1, borderWidth: 0, backgroundColor: 'transparent' }]}
                  value={password}
                  onChangeText={setPassword}
                  placeholder="Mínimo 6 caracteres"
                  placeholderTextColor={theme.textTer}
                  secureTextEntry={pwHidden}
                  autoCapitalize="none"
                />
                <TouchableOpacity onPress={() => setPwHidden(!pwHidden)} style={styles.eyeBtn}>
                  {pwHidden
                    ? <EyeIcon size={18} color={theme.textSec} />
                    : <EyeOffIcon size={18} color={theme.textSec} />}
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
                placeholderTextColor={theme.textTer}
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
                ? <ActivityIndicator color={theme.bg} />
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
  root:           { flex: 1, backgroundColor: theme.bg },
  scroll:         { flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 },
  header:         { alignItems: 'center', paddingBottom: 32 },
  logoCircle:     { width: 64, height: 64, borderRadius: 32, backgroundColor: theme.gold, alignItems: 'center', justifyContent: 'center', marginBottom: 14 },
  logoText:       { fontSize: 28, fontWeight: '800', color: theme.bg },
  appName:        { fontSize: 24, fontWeight: '800', color: theme.white, letterSpacing: -0.5, marginBottom: 6 },
  tagline:        { fontSize: 14, color: theme.textSec, fontWeight: '400', textAlign: 'center' },
  center:         { alignItems: 'center', paddingVertical: 20 },
  errorBox:       { backgroundColor: 'rgba(248,113,113,0.12)', borderRadius: 10, padding: 12, marginBottom: 16 },
  errorText:      { color: theme.danger, fontSize: 13, fontWeight: '500' },
  successBox:     { backgroundColor: 'rgba(74,222,128,0.12)', borderRadius: 10, padding: 16, alignItems: 'center' },
  successText:    { color: theme.income, fontSize: 15, fontWeight: '600' },
  field:          { marginBottom: 16 },
  label:          { fontSize: 13, fontWeight: '500', color: theme.textSec, marginBottom: 6 },
  input:          { borderWidth: 1, borderColor: theme.border, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: theme.inputText, backgroundColor: theme.inputBg },
  passwordWrap:   { flexDirection: 'row', alignItems: 'center', borderWidth: 1, borderColor: theme.border, borderRadius: 10, overflow: 'hidden', backgroundColor: theme.inputBg },
  eyeBtn:         { paddingHorizontal: 12, paddingVertical: 12 },
  primaryBtn:     { backgroundColor: theme.gold, borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 8 },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: theme.bg, letterSpacing: -0.2 },
  btnDisabled:    { opacity: 0.6 },
});
