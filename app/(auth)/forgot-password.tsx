import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, KeyboardAvoidingView, Platform,
  ScrollView, ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';
import { theme } from '../../src/theme';

export default function ForgotPasswordScreen() {
  const { sendPasswordReset } = useAuth();
  const router = useRouter();
  const insets = useSafeAreaInsets();

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
      <ScrollView contentContainerStyle={[styles.scroll, { paddingTop: insets.top + 40 }]} keyboardShouldPersistTaps="handled">
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
                placeholderTextColor={theme.textTer}
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
                ? <ActivityIndicator color={theme.bg} />
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
  root:           { flex: 1, backgroundColor: theme.bg },
  scroll:         { flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 },
  header:         { alignItems: 'center', paddingBottom: 32 },
  logoCircle:     { width: 64, height: 64, borderRadius: 32, backgroundColor: theme.gold, alignItems: 'center', justifyContent: 'center', marginBottom: 14 },
  logoText:       { fontSize: 28, fontWeight: '800', color: theme.bg },
  appName:        { fontSize: 24, fontWeight: '800', color: theme.white, letterSpacing: -0.5, marginBottom: 6 },
  tagline:        { fontSize: 14, color: theme.textSec, fontWeight: '400', textAlign: 'center', paddingHorizontal: 16 },
  errorBox:       { backgroundColor: 'rgba(248,113,113,0.12)', borderRadius: 10, padding: 12, marginBottom: 16 },
  errorText:      { color: theme.danger, fontSize: 13, fontWeight: '500' },
  successBox:     { backgroundColor: 'rgba(74,222,128,0.12)', borderRadius: 10, padding: 16 },
  successText:    { color: theme.income, fontSize: 14, lineHeight: 20, fontWeight: '500' },
  field:          { marginBottom: 16 },
  label:          { fontSize: 13, fontWeight: '500', color: theme.textSec, marginBottom: 6 },
  input:          { borderWidth: 1, borderColor: theme.border, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: theme.inputText, backgroundColor: theme.inputBg },
  primaryBtn:     { backgroundColor: theme.gold, borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 8 },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: theme.bg, letterSpacing: -0.2 },
  btnDisabled:    { opacity: 0.6 },
  loginRow:       { flexDirection: 'row', justifyContent: 'center', marginTop: 24 },
  loginLink:      { fontSize: 14, color: theme.gold, fontWeight: '600' },
});
