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
import { EyeIcon, EyeOffIcon } from '../../src/components/Icons';

export default function RegisterScreen() {
  const { signUpWithEmail, loading } = useAuth();
  const router = useRouter();
  const insets = useSafeAreaInsets();

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
  };

  return (
    <KeyboardAvoidingView style={styles.root} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={[styles.scroll, { paddingTop: insets.top + 40 }]} keyboardShouldPersistTaps="handled">
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
            placeholderTextColor={theme.textTer}
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
            placeholderTextColor={theme.textTer}
            keyboardType="email-address"
            autoCapitalize="none"
            autoComplete="email"
          />
        </View>

        <View style={styles.field}>
          <Text style={styles.label}>Password</Text>
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
          <Text style={styles.label}>Confirmar password</Text>
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
          style={[styles.primaryBtn, loading && styles.btnDisabled]}
          onPress={handleSubmit}
          disabled={loading}
          activeOpacity={0.85}
        >
          {loading
            ? <ActivityIndicator color={theme.bg} />
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
  root:           { flex: 1, backgroundColor: theme.bg },
  scroll:         { flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 },
  header:         { alignItems: 'center', paddingBottom: 32 },
  logoCircle:     { width: 64, height: 64, borderRadius: 32, backgroundColor: theme.gold, alignItems: 'center', justifyContent: 'center', marginBottom: 14 },
  logoText:       { fontSize: 28, fontWeight: '800', color: theme.bg },
  appName:        { fontSize: 24, fontWeight: '800', color: theme.white, letterSpacing: -0.5, marginBottom: 6 },
  tagline:        { fontSize: 14, color: theme.textSec, fontWeight: '400' },
  errorBox:       { backgroundColor: 'rgba(248,113,113,0.12)', borderRadius: 10, padding: 12, marginBottom: 16 },
  errorText:      { color: theme.danger, fontSize: 13, fontWeight: '500' },
  field:          { marginBottom: 16 },
  label:          { fontSize: 13, fontWeight: '500', color: theme.textSec, marginBottom: 6 },
  input:          { borderWidth: 1, borderColor: theme.border, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: theme.inputText, backgroundColor: theme.inputBg },
  passwordWrap:   { flexDirection: 'row', alignItems: 'center', borderWidth: 1, borderColor: theme.border, borderRadius: 10, overflow: 'hidden', backgroundColor: theme.inputBg },
  eyeBtn:         { paddingHorizontal: 12, paddingVertical: 12 },
  primaryBtn:     { backgroundColor: theme.gold, borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 8 },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: theme.bg, letterSpacing: -0.2 },
  btnDisabled:    { opacity: 0.6 },
  loginRow:       { flexDirection: 'row', justifyContent: 'center', marginTop: 24 },
  loginText:      { fontSize: 14, color: theme.textSec },
  loginLink:      { fontSize: 14, color: theme.gold, fontWeight: '600' },
});
