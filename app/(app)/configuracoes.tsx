import React, { useState } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TouchableOpacity,
  TextInput, Alert, ActivityIndicator, Linking, Platform,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';
import { useSubscription } from '../../src/hooks/useSubscription';
import * as SubscriptionService from '../../src/services/subscription.service';
import { theme } from '../../src/theme';
import { ChevronRightIcon } from '../../src/components/Icons';

const STATUS_LABEL: Record<string, string> = {
  none:          'Nenhuma assinatura ativa',
  trialing:      'Período de teste',
  active:        'Assinatura ativa',
  expired:       'Expirada',
  cancelled:     'Cancelada',
  billing_issue: 'Problema no pagamento',
  grace_period:  'Período de carência',
};

function formatDate(iso: string | null): string {
  if (!iso) return '';
  const d = new Date(iso);
  return d.toLocaleDateString('pt-PT', { day: '2-digit', month: 'long', year: 'numeric' });
}

export default function ConfiguracoesScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { user, signOut, updatePassword, deleteAccount } = useAuth();
  const { subscription, loading: subLoading, hasPremiumAccess } = useSubscription(user?.id ?? '');

  const [changingPw, setChangingPw] = useState(false);
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [pwSaving, setPwSaving] = useState(false);
  const [pwError, setPwError] = useState('');
  const [pwSuccess, setPwSuccess] = useState(false);

  const [deleting, setDeleting] = useState(false);

  const initials = (user?.profile?.display_name ?? user?.email ?? '?')
    .trim()
    .split(' ')
    .map(p => p[0])
    .slice(0, 2)
    .join('')
    .toUpperCase();

  const handleChangePassword = async () => {
    setPwError('');
    if (newPassword.length < 6) { setPwError('A senha precisa ter pelo menos 6 caracteres.'); return; }
    if (newPassword !== confirmPassword) { setPwError('As senhas não coincidem.'); return; }
    setPwSaving(true);
    const res = await updatePassword(newPassword);
    setPwSaving(false);
    if (res.error) { setPwError(res.error); return; }
    setPwSuccess(true);
    setNewPassword('');
    setConfirmPassword('');
    setTimeout(() => { setChangingPw(false); setPwSuccess(false); }, 1500);
  };

  const handleRestorePurchases = async () => {
    const res = await SubscriptionService.restorePurchases();
    if (!res.ok) Alert.alert('Restaurar compras', res.error ?? 'Não foi possível restaurar as compras.');
  };

  const handleManageSubscription = () => {
    if (Platform.OS === 'ios') {
      Linking.openURL('itms-apps://apps.apple.com/account/subscriptions');
    }
  };

  const handleSignOut = () => {
    Alert.alert('Sair', 'Tem certeza que deseja sair da sua conta?', [
      { text: 'Cancelar', style: 'cancel' },
      { text: 'Sair', style: 'destructive', onPress: () => signOut() },
    ]);
  };

  const handleDeleteAccount = () => {
    Alert.alert(
      'Excluir conta',
      'Isso vai apagar permanentemente sua conta e todos os seus dados financeiros. Essa ação não pode ser desfeita.',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Excluir conta',
          style: 'destructive',
          onPress: async () => {
            setDeleting(true);
            const res = await deleteAccount();
            setDeleting(false);
            if (res.error) Alert.alert('Erro', res.error);
            // On success, AuthContext clears the user and the root layout
            // redirects to login automatically.
          },
        },
      ]
    );
  };

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingTop: insets.top + 16, paddingBottom: 60 }}>
      <View style={s.headerRow}>
        <Text style={s.title}>Conta</Text>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={s.close}>Fechar</Text>
        </TouchableOpacity>
      </View>

      {/* ── Profile ── */}
      <View style={s.profileCard}>
        <View style={s.avatar}>
          <Text style={s.avatarText}>{initials}</Text>
        </View>
        <View style={{ flex: 1 }}>
          <Text style={s.profileName}>{user?.profile?.display_name ?? 'Usuário'}</Text>
          <Text style={s.profileEmail}>{user?.email}</Text>
        </View>
      </View>

      {/* ── Subscription ── */}
      <Text style={s.sectionTitle}>Assinatura</Text>
      <View style={s.card}>
        {subLoading ? (
          <ActivityIndicator color={theme.gold} />
        ) : (
          <>
            <View style={s.subRow}>
              <Text style={s.subLabel}>Status</Text>
              <View style={[s.subBadge, hasPremiumAccess && s.subBadgeActive]}>
                <Text style={[s.subBadgeText, hasPremiumAccess && s.subBadgeTextActive]}>
                  {STATUS_LABEL[subscription?.status ?? 'none']}
                </Text>
              </View>
            </View>
            {subscription?.expires_at && (
              <View style={s.subRow}>
                <Text style={s.subLabel}>
                  {subscription.will_renew ? 'Renova em' : 'Expira em'}
                </Text>
                <Text style={s.subValue}>{formatDate(subscription.expires_at)}</Text>
              </View>
            )}
          </>
        )}

        <View style={s.divider} />

        <TouchableOpacity style={s.row} onPress={handleRestorePurchases}>
          <Text style={s.rowLabel}>Restaurar compras</Text>
          <ChevronRightIcon size={14} color={theme.textTer} />
        </TouchableOpacity>

        {Platform.OS === 'ios' && (
          <TouchableOpacity style={s.row} onPress={handleManageSubscription}>
            <Text style={s.rowLabel}>Gerenciar assinatura</Text>
            <ChevronRightIcon size={14} color={theme.textTer} />
          </TouchableOpacity>
        )}
      </View>

      {/* ── Security ── */}
      <Text style={s.sectionTitle}>Segurança</Text>
      <View style={s.card}>
        {!changingPw ? (
          <TouchableOpacity style={s.row} onPress={() => setChangingPw(true)}>
            <Text style={s.rowLabel}>Alterar senha</Text>
            <ChevronRightIcon size={14} color={theme.textTer} />
          </TouchableOpacity>
        ) : (
          <View style={{ gap: 10 }}>
            {!!pwError && <Text style={s.pwError}>{pwError}</Text>}
            {pwSuccess ? (
              <Text style={s.pwSuccess}>Senha alterada com sucesso!</Text>
            ) : (
              <>
                <TextInput
                  style={s.input}
                  value={newPassword}
                  onChangeText={setNewPassword}
                  placeholder="Nova senha"
                  placeholderTextColor={theme.textTer}
                  secureTextEntry
                  autoCapitalize="none"
                />
                <TextInput
                  style={s.input}
                  value={confirmPassword}
                  onChangeText={setConfirmPassword}
                  placeholder="Confirmar nova senha"
                  placeholderTextColor={theme.textTer}
                  secureTextEntry
                  autoCapitalize="none"
                />
                <View style={{ flexDirection: 'row', gap: 8 }}>
                  <TouchableOpacity
                    style={[s.smallBtn, { flex: 1 }]}
                    onPress={() => { setChangingPw(false); setPwError(''); setNewPassword(''); setConfirmPassword(''); }}
                  >
                    <Text style={s.smallBtnTextSecondary}>Cancelar</Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={[s.smallBtn, s.smallBtnPrimary, { flex: 1 }]}
                    onPress={handleChangePassword}
                    disabled={pwSaving}
                  >
                    {pwSaving
                      ? <ActivityIndicator color={theme.bg} size="small" />
                      : <Text style={s.smallBtnText}>Salvar</Text>}
                  </TouchableOpacity>
                </View>
              </>
            )}
          </View>
        )}
      </View>

      {/* ── Session ── */}
      <View style={s.card}>
        <TouchableOpacity style={s.row} onPress={handleSignOut}>
          <Text style={s.rowLabel}>Sair da conta</Text>
        </TouchableOpacity>
      </View>

      {/* ── Danger zone ── */}
      <Text style={s.sectionTitle}>Zona de risco</Text>
      <View style={s.card}>
        <TouchableOpacity style={s.row} onPress={handleDeleteAccount} disabled={deleting}>
          {deleting
            ? <ActivityIndicator color={theme.danger} size="small" />
            : <Text style={s.dangerLabel}>Excluir conta</Text>}
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const s = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: theme.bg, paddingHorizontal: 20 },
  headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 },
  title: { fontSize: 22, fontWeight: '800', color: theme.white, letterSpacing: -0.4 },
  close: { fontSize: 14, color: theme.gold, fontWeight: '600' },
  profileCard: {
    flexDirection: 'row', alignItems: 'center', gap: 14,
    backgroundColor: theme.surface, borderRadius: 14, borderWidth: 1, borderColor: theme.border,
    padding: 16, marginBottom: 20,
  },
  avatar: {
    width: 52, height: 52, borderRadius: 26, backgroundColor: theme.goldSoft,
    alignItems: 'center', justifyContent: 'center',
  },
  avatarText: { fontSize: 18, fontWeight: '800', color: theme.gold },
  profileName: { fontSize: 16, fontWeight: '700', color: theme.white },
  profileEmail: { fontSize: 12, color: theme.textSec, marginTop: 2 },
  sectionTitle: { fontSize: 12, fontWeight: '700', color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 8, marginTop: 4 },
  card: {
    backgroundColor: theme.surface, borderRadius: 14, borderWidth: 1, borderColor: theme.border,
    padding: 14, marginBottom: 20, gap: 4,
  },
  subRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 6 },
  subLabel: { fontSize: 13, color: theme.textSec },
  subValue: { fontSize: 13, color: theme.white, fontWeight: '600' },
  subBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 8, backgroundColor: 'rgba(255,255,255,0.06)' },
  subBadgeActive: { backgroundColor: theme.goldSoft },
  subBadgeText: { fontSize: 12, fontWeight: '700', color: theme.textSec },
  subBadgeTextActive: { color: theme.gold },
  divider: { height: 1, backgroundColor: theme.border, marginVertical: 8 },
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 10 },
  rowLabel: { fontSize: 14, fontWeight: '600', color: theme.white },
  dangerLabel: { fontSize: 14, fontWeight: '600', color: theme.danger },
  input: {
    borderWidth: 1, borderColor: theme.border, borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 11, fontSize: 14,
    color: theme.inputText, backgroundColor: theme.inputBg,
  },
  pwError: { fontSize: 12, color: theme.danger },
  pwSuccess: { fontSize: 13, color: theme.income, fontWeight: '600', textAlign: 'center', paddingVertical: 8 },
  smallBtn: { paddingVertical: 11, borderRadius: 10, alignItems: 'center', backgroundColor: 'rgba(255,255,255,0.06)' },
  smallBtnPrimary: { backgroundColor: theme.gold },
  smallBtnText: { fontSize: 13, fontWeight: '700', color: theme.bg },
  smallBtnTextSecondary: { fontSize: 13, fontWeight: '700', color: theme.textSec },
});
