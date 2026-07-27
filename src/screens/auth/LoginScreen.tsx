import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, KeyboardAvoidingView, Platform,
  ScrollView, ActivityIndicator,
} from 'react-native';
import * as AppleAuthentication from 'expo-apple-authentication';
import { useRouter } from 'expo-router';
import { useAuth } from '../../context/AuthContext';

const T = {
  brand:   '#1756F5',
  brandD:  '#1248C8',
  text:    '#0A1929',
  textSec: '#3D5168',
  textTer: '#8097B1',
  border:  '#D8E4F0',
  surface: '#F2F6FA',
  white:   '#FFFFFF',
  red:     '#E53935',
};

export default function LoginScreen() {
  const { signInWithEmail, signInWithApple, loading } = useAuth();
  const router = useRouter();

  const [email,    setEmail]    = useState('');
  const [password, setPassword] = useState('');
  const [pwHidden, setPwHidden] = useState(true);
  const [error,    setError]    = useState('');

  const handleEmail = async () => {
    if (!email.trim() || !password) { setError('Preencha todos os campos.'); return; }
    setError('');
    const res = await signInWithEmail(email.trim(), password);
    if (res.error) setError(res.error);
  };

  const handleApple = async () => {
    setError('');
    const res = await signInWithApple();
    if (res.error && res.error !== 'Cancelled') setError(res.error);
  };

  return (
    <KeyboardAvoidingView
      style={styles.root}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView
        contentContainerStyle={styles.scroll}
        keyboardShouldPersistTaps="handled"
      >
        {/* Logo */}
        <View style={styles.header}>
          <View style={styles.logoCircle}>
            <Text style={styles.logoText}>V</Text>
          </View>
          <Text style={styles.appName}>Valura</Text>
          <Text style={styles.tagline}>As suas finanças. Simples.</Text>
        </View>

        {/* Error */}
        {!!error && (
          <View style={styles.errorBox}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}

        {/* Email */}
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

        {/* Password */}
        <View style={styles.field}>
          <View style={styles.labelRow}>
            <Text style={styles.label}>Password</Text>
            <TouchableOpacity onPress={() => router.push('/(auth)/forgot-password')}>
              <Text style={styles.forgotLink}>Esqueci</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.passwordWrap}>
            <TextInput
              style={[styles.input, { flex: 1, borderWidth: 0 }]}
              value={password}
              onChangeText={setPassword}
              placeholder="••••••••"
              placeholderTextColor={T.textTer}
              secureTextEntry={pwHidden}
              autoCapitalize="none"
            />
            <TouchableOpacity onPress={() => setPwHidden(!pwHidden)} style={styles.eyeBtn}>
              <Text style={styles.eyeText}>{pwHidden ? '👁️' : '🙈'}</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Sign in button */}
        <TouchableOpacity
          style={[styles.primaryBtn, loading && styles.btnDisabled]}
          onPress={handleEmail}
          disabled={loading}
          activeOpacity={0.85}
        >
          {loading
            ? <ActivityIndicator color={T.white} />
            : <Text style={styles.primaryBtnText}>Entrar</Text>
          }
        </TouchableOpacity>

        {/* Divider */}
        <View style={styles.divider}>
          <View style={styles.dividerLine} />
          <Text style={styles.dividerText}>ou continuar com</Text>
          <View style={styles.dividerLine} />
        </View>

        {/* Apple Sign-In — botão nativo obrigatório pela Apple */}
        <AppleAuthentication.AppleAuthenticationButton
          buttonType={AppleAuthentication.AppleAuthenticationButtonType.SIGN_IN}
          buttonStyle={AppleAuthentication.AppleAuthenticationButtonStyle.BLACK}
          cornerRadius={12}
          style={styles.appleBtn}
          onPress={handleApple}
        />

        {/* Register link */}
        <View style={styles.registerRow}>
          <Text style={styles.registerText}>Ainda não tem conta? </Text>
          <TouchableOpacity onPress={() => router.push('/(auth)/register')}>
            <Text style={styles.registerLink}>Criar conta</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  root:           { flex: 1, backgroundColor: T.white },
  scroll:         { flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 },
  header:         { alignItems: 'center', paddingTop: 60, paddingBottom: 40 },
  logoCircle:     { width: 72, height: 72, borderRadius: 36, backgroundColor: T.brand, alignItems: 'center', justifyContent: 'center', marginBottom: 16 },
  logoText:       { fontSize: 32, fontWeight: '800', color: T.white },
  appName:        { fontSize: 30, fontWeight: '800', color: T.text, letterSpacing: -0.5, marginBottom: 6 },
  tagline:        { fontSize: 14, color: T.textSec, fontWeight: '400' },
  errorBox:       { backgroundColor: '#FDECEA', borderRadius: 10, padding: 12, marginBottom: 16 },
  errorText:      { color: T.red, fontSize: 13, fontWeight: '500' },
  field:          { marginBottom: 16 },
  label:          { fontSize: 13, fontWeight: '500', color: T.textSec, marginBottom: 6 },
  labelRow:       { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 },
  forgotLink:     { fontSize: 13, color: T.brand, fontWeight: '500' },
  input:          { borderWidth: 1.5, borderColor: T.border, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: T.text, backgroundColor: T.white },
  passwordWrap:   { flexDirection: 'row', alignItems: 'center', borderWidth: 1.5, borderColor: T.border, borderRadius: 10, overflow: 'hidden', backgroundColor: T.white },
  eyeBtn:         { paddingHorizontal: 12, paddingVertical: 12 },
  eyeText:        { fontSize: 16 },
  primaryBtn:     { backgroundColor: T.brand, borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 8, shadowColor: T.brand, shadowOpacity: 0.35, shadowRadius: 12, shadowOffset: { width: 0, height: 4 }, elevation: 6 },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: T.white, letterSpacing: -0.2 },
  btnDisabled:    { opacity: 0.6 },
  divider:        { flexDirection: 'row', alignItems: 'center', marginVertical: 24, gap: 10 },
  dividerLine:    { flex: 1, height: 1, backgroundColor: T.border },
  dividerText:    { fontSize: 12, color: T.textTer, fontWeight: '400' },
  appleBtn:       { width: '100%', height: 50, marginBottom: 12 },
  registerRow:    { flexDirection: 'row', justifyContent: 'center', marginTop: 16 },
  registerText:   { fontSize: 14, color: T.textSec },
  registerLink:   { fontSize: 14, color: T.brand, fontWeight: '600' },
});
