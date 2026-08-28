#!/bin/bash
set -e
echo "Aplicando tela de Conta/Configuracoes..."
mkdir -p src/components "app/(app)"

mkdir -p "$(dirname "src/components/Icons.tsx")"
cat > "src/components/Icons.tsx" << 'FILEEOF'
import React from 'react';
import { View } from 'react-native';

interface IconProps {
  size?: number;
  color?: string;
  strokeWidth?: number;
}

/** Draws a straight line between two points using the same center-rotation
 *  technique as LineChart, which works reliably across RN versions. */
function Segment({
  x1, y1, x2, y2, color, thickness,
}: { x1: number; y1: number; x2: number; y2: number; color: string; thickness: number }) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const dist = Math.sqrt(dx * dx + dy * dy);
  const angle = Math.atan2(dy, dx) * (180 / Math.PI);
  const midX = (x1 + x2) / 2;
  const midY = (y1 + y2) / 2;
  return (
    <View
      style={{
        position: 'absolute',
        left: midX - dist / 2,
        top: midY - thickness / 2,
        width: dist,
        height: thickness,
        backgroundColor: color,
        borderRadius: thickness / 2,
        transform: [{ rotate: `${angle}deg` }],
      }}
    />
  );
}

export function BellIcon({ size = 20, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{ width: size, height: size, alignItems: 'center' }}>
      <View
        style={{
          width: size * 0.62,
          height: size * 0.5,
          borderWidth: strokeWidth,
          borderColor: color,
          borderBottomWidth: 0,
          borderTopLeftRadius: size * 0.31,
          borderTopRightRadius: size * 0.31,
        }}
      />
      <View style={{ width: size * 0.8, height: strokeWidth, backgroundColor: color, borderRadius: 1 }} />
      <View
        style={{
          width: size * 0.16,
          height: size * 0.16,
          borderRadius: size * 0.08,
          backgroundColor: color,
          marginTop: size * 0.06,
        }}
      />
    </View>
  );
}

export function CalendarIcon({ size = 20, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{ width: size, height: size }}>
      <View
        style={{
          width: size,
          height: size * 0.85,
          marginTop: size * 0.15,
          borderWidth: strokeWidth,
          borderColor: color,
          borderRadius: 3,
        }}
      >
        <View style={{ height: size * 0.22, borderBottomWidth: strokeWidth, borderColor: color }} />
      </View>
      <View style={{ position: 'absolute', top: 0, left: size * 0.22, width: strokeWidth, height: size * 0.28, backgroundColor: color }} />
      <View style={{ position: 'absolute', top: 0, right: size * 0.22, width: strokeWidth, height: size * 0.28, backgroundColor: color }} />
    </View>
  );
}

export function HomeIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <Segment x1={w * 0.08} y1={h * 0.5} x2={w * 0.5} y2={h * 0.08} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.5} y1={h * 0.08} x2={w * 0.92} y2={h * 0.5} color={color} thickness={strokeWidth} />
      <View
        style={{
          position: 'absolute', left: w * 0.2, top: h * 0.42, width: w * 0.6, height: h * 0.5,
          borderWidth: strokeWidth, borderColor: color, borderTopWidth: 0,
        }}
      />
    </View>
  );
}

export function BarChartIcon({ size = 22, color = '#FFFFFF' }: IconProps) {
  return (
    <View style={{ width: size, height: size, flexDirection: 'row', alignItems: 'flex-end', gap: size * 0.12 }}>
      <View style={{ width: size * 0.2, height: size * 0.45, backgroundColor: color, borderRadius: 1 }} />
      <View style={{ width: size * 0.2, height: size * 0.7, backgroundColor: color, borderRadius: 1 }} />
      <View style={{ width: size * 0.2, height: size * 0.95, backgroundColor: color, borderRadius: 1 }} />
    </View>
  );
}

export function TargetIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View
      style={{
        width: size, height: size, borderRadius: size / 2,
        borderWidth: strokeWidth, borderColor: color,
        alignItems: 'center', justifyContent: 'center',
      }}
    >
      <View
        style={{
          width: size * 0.6, height: size * 0.6, borderRadius: size * 0.3,
          borderWidth: strokeWidth, borderColor: color,
          alignItems: 'center', justifyContent: 'center',
        }}
      >
        <View style={{ width: size * 0.24, height: size * 0.24, borderRadius: size * 0.12, backgroundColor: color }} />
      </View>
    </View>
  );
}

export function TrendingUpIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size;
  const p1 = { x: w * 0.06, y: h * 0.78 };
  const p2 = { x: w * 0.4, y: h * 0.46 };
  const p3 = { x: w * 0.62, y: h * 0.62 };
  const p4 = { x: w * 0.95, y: h * 0.18 };
  return (
    <View style={{ width: w, height: h }}>
      <Segment x1={p1.x} y1={p1.y} x2={p2.x} y2={p2.y} color={color} thickness={strokeWidth} />
      <Segment x1={p2.x} y1={p2.y} x2={p3.x} y2={p3.y} color={color} thickness={strokeWidth} />
      <Segment x1={p3.x} y1={p3.y} x2={p4.x} y2={p4.y} color={color} thickness={strokeWidth} />
      {/* arrow head at the top-right end */}
      <Segment x1={p4.x} y1={p4.y} x2={p4.x - w * 0.22} y2={p4.y} color={color} thickness={strokeWidth} />
      <Segment x1={p4.x} y1={p4.y} x2={p4.x} y2={p4.y + h * 0.22} color={color} thickness={strokeWidth} />
    </View>
  );
}

export function PlusIcon({ size = 24, color = '#FFFFFF', strokeWidth = 2.2 }: IconProps) {
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ position: 'absolute', width: size * 0.7, height: strokeWidth, backgroundColor: color, borderRadius: 2 }} />
      <View style={{ position: 'absolute', width: strokeWidth, height: size * 0.7, backgroundColor: color, borderRadius: 2 }} />
    </View>
  );
}

export function SettingsIcon({ size = 20, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const cx = size / 2, cy = size / 2;
  const rRing = size * 0.3;
  const rToothStart = size * 0.32;
  const rToothEnd = size * 0.48;
  const teeth = 6;
  return (
    <View style={{ width: size, height: size }}>
      <View
        style={{
          position: 'absolute', left: cx - rRing, top: cy - rRing,
          width: rRing * 2, height: rRing * 2, borderRadius: rRing,
          borderWidth: strokeWidth, borderColor: color,
        }}
      />
      {Array.from({ length: teeth }).map((_, i) => {
        const theta = (i / teeth) * Math.PI * 2;
        const x1 = cx + rToothStart * Math.cos(theta);
        const y1 = cy + rToothStart * Math.sin(theta);
        const x2 = cx + rToothEnd * Math.cos(theta);
        const y2 = cy + rToothEnd * Math.sin(theta);
        return (
          <Segment key={i} x1={x1} y1={y1} x2={x2} y2={y2} color={color} thickness={strokeWidth * 1.6} />
        );
      })}
    </View>
  );
}

export function ChevronRightIcon({ size = 16, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <Segment x1={w * 0.32} y1={h * 0.18} x2={w * 0.72} y2={h * 0.5} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.72} y1={h * 0.5} x2={w * 0.32} y2={h * 0.82} color={color} thickness={strokeWidth} />
    </View>
  );
}

// ─── Category icons ────────────────────────────────────────────────────────────

export function CartIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{
        position: 'absolute', left: w * 0.18, top: h * 0.28, width: w * 0.68, height: h * 0.4,
        borderWidth: strokeWidth, borderColor: color, borderTopWidth: 0,
      }} />
      <Segment x1={w * 0.1} y1={h * 0.15} x2={w * 0.22} y2={h * 0.15} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.22} y1={h * 0.15} x2={w * 0.32} y2={h * 0.68} color={color} thickness={strokeWidth} />
      <View style={{ position: 'absolute', left: w * 0.28, top: h * 0.82, width: w * 0.12, height: w * 0.12, borderRadius: w * 0.06, backgroundColor: color }} />
      <View style={{ position: 'absolute', left: w * 0.62, top: h * 0.82, width: w * 0.12, height: w * 0.12, borderRadius: w * 0.06, backgroundColor: color }} />
    </View>
  );
}

export function CarIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{
        position: 'absolute', left: w * 0.06, top: h * 0.32, width: w * 0.88, height: h * 0.3,
        borderWidth: strokeWidth, borderColor: color, borderRadius: 4,
      }} />
      <Segment x1={w * 0.22} y1={h * 0.32} x2={w * 0.34} y2={h * 0.12} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.34} y1={h * 0.12} x2={w * 0.66} y2={h * 0.12} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.66} y1={h * 0.12} x2={w * 0.78} y2={h * 0.32} color={color} thickness={strokeWidth} />
      <View style={{ position: 'absolute', left: w * 0.14, top: h * 0.66, width: w * 0.18, height: w * 0.18, borderRadius: w * 0.09, borderWidth: strokeWidth, borderColor: color }} />
      <View style={{ position: 'absolute', left: w * 0.68, top: h * 0.66, width: w * 0.18, height: w * 0.18, borderRadius: w * 0.09, borderWidth: strokeWidth, borderColor: color }} />
    </View>
  );
}

export function CrossIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{ width: size, height: size, borderRadius: size / 2, borderWidth: strokeWidth, borderColor: color, alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ position: 'absolute', width: size * 0.42, height: strokeWidth, backgroundColor: color }} />
      <View style={{ position: 'absolute', width: strokeWidth, height: size * 0.42, backgroundColor: color }} />
    </View>
  );
}

export function PhoneIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{
      width: size * 0.6, height: size, borderWidth: strokeWidth, borderColor: color, borderRadius: 4,
      alignItems: 'center', justifyContent: 'flex-end', paddingBottom: 2,
    }}>
      <View style={{ width: size * 0.16, height: strokeWidth, backgroundColor: color, borderRadius: 1 }} />
    </View>
  );
}

export function UtensilsIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h, flexDirection: 'row', justifyContent: 'space-between' }}>
      <View style={{ width: strokeWidth, height: h * 0.85, backgroundColor: color, borderRadius: 1 }} />
      <View style={{ width: strokeWidth, height: h * 0.85, backgroundColor: color, borderRadius: 1, transform: [{ rotate: '18deg' }] }} />
    </View>
  );
}

export function BagIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{
        position: 'absolute', left: w * 0.12, top: h * 0.32, width: w * 0.76, height: h * 0.58,
        borderWidth: strokeWidth, borderColor: color, borderRadius: 3,
      }} />
      <View style={{
        position: 'absolute', left: w * 0.3, top: h * 0.1, width: w * 0.4, height: h * 0.3,
        borderWidth: strokeWidth, borderColor: color, borderBottomWidth: 0,
        borderTopLeftRadius: w * 0.2, borderTopRightRadius: w * 0.2,
      }} />
    </View>
  );
}

export function SparkleIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size, cx = w / 2, cy = h / 2;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{ position: 'absolute', left: 0, top: cy - strokeWidth / 2, width: w, height: strokeWidth, backgroundColor: color, transform: [{ rotate: '0deg' }] }} />
      <View style={{ position: 'absolute', left: cx - strokeWidth / 2, top: 0, width: strokeWidth, height: h, backgroundColor: color }} />
      <View style={{
        position: 'absolute', left: cx - (w * 0.7) / 2, top: cy - strokeWidth / 2, width: w * 0.7, height: strokeWidth,
        backgroundColor: color, transform: [{ rotate: '45deg' }],
      }} />
      <View style={{
        position: 'absolute', left: cx - (w * 0.7) / 2, top: cy - strokeWidth / 2, width: w * 0.7, height: strokeWidth,
        backgroundColor: color, transform: [{ rotate: '-45deg' }],
      }} />
    </View>
  );
}

export function BookIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h, flexDirection: 'row' }}>
      <View style={{
        width: w * 0.48, height: h * 0.78, marginTop: h * 0.1,
        borderWidth: strokeWidth, borderColor: color, borderRightWidth: 0,
        borderTopLeftRadius: 3, borderBottomLeftRadius: 3,
      }} />
      <View style={{
        width: w * 0.48, height: h * 0.78, marginTop: h * 0.1,
        borderWidth: strokeWidth, borderColor: color,
        borderTopRightRadius: 3, borderBottomRightRadius: 3,
      }} />
    </View>
  );
}

export function BoxIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  return (
    <View style={{ width: size, height: size, borderWidth: strokeWidth, borderColor: color, borderRadius: 4 }}>
      <View style={{ height: size * 0.32, borderBottomWidth: strokeWidth, borderColor: color }} />
    </View>
  );
}

export function BriefcaseIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{
        position: 'absolute', left: w * 0.06, top: h * 0.32, width: w * 0.88, height: h * 0.58,
        borderWidth: strokeWidth, borderColor: color, borderRadius: 3,
      }} />
      <View style={{
        position: 'absolute', left: w * 0.32, top: h * 0.12, width: w * 0.36, height: h * 0.24,
        borderWidth: strokeWidth, borderColor: color, borderBottomWidth: 0, borderRadius: 2,
      }} />
      <View style={{ position: 'absolute', left: 0, top: h * 0.56, width: w, height: strokeWidth, backgroundColor: color }} />
    </View>
  );
}

export function LaptopIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h, alignItems: 'center' }}>
      <View style={{
        width: w * 0.78, height: h * 0.52,
        borderWidth: strokeWidth, borderColor: color, borderRadius: 3,
      }} />
      <View style={{ width: w, height: strokeWidth * 1.4, backgroundColor: color, marginTop: 3, borderRadius: 2 }} />
    </View>
  );
}

export function CoinIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{
      width: size, height: size, borderRadius: size / 2, borderWidth: strokeWidth, borderColor: color,
      alignItems: 'center', justifyContent: 'center',
    }}>
      <View style={{ width: size * 0.4, height: strokeWidth, backgroundColor: color }} />
    </View>
  );
}
FILEEOF

mkdir -p "$(dirname "app/(app)/configuracoes.tsx")"
cat > "app/(app)/configuracoes.tsx" << 'FILEEOF'
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
FILEEOF

mkdir -p "$(dirname "app/(app)/_layout.tsx")"
cat > "app/(app)/_layout.tsx" << 'FILEEOF'
import React from 'react';
import { Stack } from 'expo-router';

export default function AppLayout() {
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(tabs)" />
      <Stack.Screen name="adicionar" options={{ presentation: 'modal' }} />
      <Stack.Screen name="configuracoes" options={{ presentation: 'modal' }} />
    </Stack>
  );
}
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/index.tsx")"
cat > "app/(app)/(tabs)/index.tsx" << 'FILEEOF'
/**
 * app/(app)/(tabs)/index.tsx  →  Summary / Dashboard tab
 */

import React, { useMemo, useState, useCallback } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect, useRouter } from 'expo-router';
import { useAuth }         from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget }       from '../../../src/hooks/useBudget';
import { useCategories }   from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';
import { BellIcon, CalendarIcon, SettingsIcon } from '../../../src/components/Icons';
import { CategoryIcon } from '../../../src/components/CategoryIcon';

const now = new Date();

export default function SummaryScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();
  const router = useRouter();

  const [viewYear, setViewYear] = useState(now.getFullYear());
  const [viewMonth, setViewMonth] = useState(now.getMonth());
  const isCurrentMonth = viewYear === now.getFullYear() && viewMonth === now.getMonth();

  const userId = user?.id ?? '';
  const monthYear = `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}`;

  const { transactions, loading: txLoading, refresh: refreshTx } = useTransactions({ userId, year: viewYear, month: viewMonth });
  const { budget, loading: budLoading, refresh: refreshBudget } = useBudget(userId, monthYear);
  const { categories, loading: catLoading, refresh: refreshCategories } = useCategories(userId);

  useFocusEffect(
    useCallback(() => {
      if (!userId) return;
      refreshTx();
      refreshBudget();
      refreshCategories();
    }, [userId, refreshTx, refreshBudget, refreshCategories])
  );

  const loading = txLoading || budLoading || catLoading;

  const { totalIncome, totalExpense, remaining, savingsRate } = useMemo(() => {
    const totalIncome = transactions.filter(t => t.type === 'income').reduce((s, t) => s + t.amount, 0);
    const totalExpense = transactions.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0);
    const remaining = totalIncome - totalExpense;
    const savingsRate = totalIncome > 0 ? Math.max(0, Math.round((remaining / totalIncome) * 100)) : 0;
    return { totalIncome, totalExpense, remaining, savingsRate };
  }, [transactions]);

  const totalBudget = Object.values(budget).reduce((s, v) => s + v, 0);

  const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
  const thirdKpi = isCurrentMonth
    ? {
        label: 'Limite/dia',
        value: fCHF(Math.max(0, remaining) / Math.max(1, daysInMonth - now.getDate()), 0),
      }
    : {
        label: 'Média/dia',
        value: fCHF(totalExpense / daysInMonth, 0),
      };

  if (!user || loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.gold} />
      </View>
    );
  }

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 100 }}>
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <View style={s.headerTop}>
          <Text style={s.greeting}>Bom dia, {user.profile?.display_name ?? 'Ana'}</Text>
          <View style={{ flexDirection: 'row', gap: 8 }}>
            <View style={s.bellBtn}>
              <BellIcon size={16} color={theme.gold} />
            </View>
            <TouchableOpacity style={s.bellBtn} onPress={() => router.push('/(app)/configuracoes')}>
              <SettingsIcon size={16} color={theme.gold} />
            </TouchableOpacity>
          </View>
        </View>

        <View style={s.monthRow}>
          <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} />
          <TouchableOpacity
            style={s.calendarBtn}
            onPress={() => { setViewYear(now.getFullYear()); setViewMonth(now.getMonth()); }}
          >
            <CalendarIcon size={16} color={theme.gold} />
          </TouchableOpacity>
        </View>

        <Text style={s.balLabel}>SALDO DISPONÍVEL</Text>
        <Text style={s.balance}>{fCHF(remaining)}</Text>

        <View style={s.barBg}>
          <View style={[s.barFill, {
            width: `${Math.min(100, Math.round((totalExpense / (totalBudget || 1)) * 100))}%`,
          }]} />
        </View>

        <View style={s.barRow}>
          <Text style={s.barText}>Gasto: {fCHF(totalExpense, 0)}</Text>
          <Text style={s.barText}>Orçamento: {fCHF(totalBudget, 0)}</Text>
        </View>
      </View>

      {/* ── KPIs ── */}
      <View style={s.kpiRow}>
        {[
          { l: 'Receitas', v: fCHF(totalIncome, 0), c: theme.income },
          { l: 'Despesas', v: fCHF(totalExpense, 0), c: theme.expense },
          { l: thirdKpi.label, v: thirdKpi.value, c: '#7DD3FC' },
        ].map(k => (
          <View key={k.l} style={s.kpiCard}>
            <Text style={s.kpiLabel}>{k.l}</Text>
            <Text style={[s.kpiValue, { color: k.c }]}>{k.v}</Text>
          </View>
        ))}
      </View>

      {/* ── Recent transactions ── */}
      <Text style={s.sectionTitle}>
        {isCurrentMonth ? 'Últimas transações' : `Transações de ${MONTHS_FULL[viewMonth]}`}
      </Text>
      {transactions.length === 0 && (
        <View style={s.emptyBox}>
          <Text style={s.emptyText}>Nenhuma transação neste mês.</Text>
        </View>
      )}
      {transactions.slice(0, 8).map(tx => {
        const cat = categories.find(c => c.slug === tx.cat_id) ?? categories[categories.length - 1];
        return (
          <View key={tx.id} style={s.txRow}>
            <View style={[s.txIcon, { backgroundColor: cat?.bg ?? '#233150' }]}>
              <CategoryIcon slug={cat?.slug ?? 'other'} size={18} color={cat?.color ?? theme.textSec} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={s.txDesc}>{tx.description}</Text>
              <Text style={s.txMeta}>{cat?.label} · {tx.date.slice(8)}/{tx.date.slice(5, 7)}</Text>
            </View>
            <Text style={[s.txAmount, { color: tx.type === 'income' ? theme.income : theme.expense }]}>
              {tx.type === 'income' ? '+' : '-'}{fCHF(tx.amount)}
            </Text>
          </View>
        );
      })}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { padding: 20, paddingBottom: 22 },
  headerTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18 },
  greeting: { fontSize: 17, fontWeight: '700', color: theme.gold, letterSpacing: -0.2 },
  bellBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center' },
  bellIcon: { fontSize: 15 },
  monthRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 22 },
  calendarBtn: { width: 36, height: 36, borderRadius: 10, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: theme.border },
  calendarIcon: { fontSize: 15 },
  balLabel: { fontSize: 11, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.8, marginBottom: 6 },
  balance: { fontSize: 32, fontWeight: '700', color: theme.white, letterSpacing: -0.5, marginBottom: 16 },
  barBg: { height: 5, backgroundColor: 'rgba(255,255,255,.1)', borderRadius: 3, marginBottom: 8 },
  barFill: { height: 5, borderRadius: 3, backgroundColor: theme.gold },
  barRow: { flexDirection: 'row', justifyContent: 'space-between' },
  barText: { fontSize: 11, color: theme.textSec },
  kpiRow: { flexDirection: 'row', gap: 8, padding: 14 },
  kpiCard: { flex: 1, backgroundColor: theme.surface, borderRadius: 14, padding: 12, alignItems: 'center', borderWidth: 1, borderColor: theme.border },
  kpiLabel: { fontSize: 9, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 },
  kpiValue: { fontSize: 15, fontWeight: '800', letterSpacing: -0.4 },
  sectionTitle: { fontSize: 15, fontWeight: '700', color: theme.white, marginHorizontal: 16, marginTop: 8, marginBottom: 12, letterSpacing: -0.2 },
  emptyBox: { marginHorizontal: 16, padding: 24, backgroundColor: theme.surface, borderRadius: 14, borderWidth: 1, borderColor: theme.border, alignItems: 'center' },
  emptyText: { color: theme.textSec, fontSize: 13 },
  txRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginHorizontal: 16, marginBottom: 8, padding: 12, borderRadius: 12, backgroundColor: theme.surface, borderWidth: 1, borderColor: theme.border },
  txIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  txDesc: { fontSize: 14, fontWeight: '600', color: theme.white, letterSpacing: -0.1 },
  txMeta: { fontSize: 11, color: theme.textSec, marginTop: 2 },
  txAmount: { fontSize: 15, fontWeight: '800', letterSpacing: -0.3 },
});
FILEEOF

npx tsc --noEmit
echo "TypeScript OK. Fazendo commit..."
git add -A
git commit -m "Add Account Settings screen (password change, subscription status, restore purchases, sign out, delete account)"
git push
echo "Pronto! Recarrega o app (tecla r). Toca no icone de engrenagem no topo do Resumo pra abrir."
