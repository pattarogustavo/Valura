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
