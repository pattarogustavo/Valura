#!/bin/bash
set -e
echo "Aplicando: ocultar valores, tema no login, anos reais nas Projecoes, novo seletor de mes..."
mkdir -p src/components src/context "app/(auth)"

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

export function EyeIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size * 0.64;
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <View
        style={{
          width: w, height: h, borderRadius: h / 2,
          borderWidth: strokeWidth, borderColor: color,
          alignItems: 'center', justifyContent: 'center',
        }}
      >
        <View style={{ width: h * 0.4, height: h * 0.4, borderRadius: h * 0.2, backgroundColor: color }} />
      </View>
    </View>
  );
}

export function EyeOffIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size * 0.64;
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <View
        style={{
          width: w, height: h, borderRadius: h / 2,
          borderWidth: strokeWidth, borderColor: color,
          alignItems: 'center', justifyContent: 'center',
        }}
      >
        <View style={{ width: h * 0.4, height: h * 0.4, borderRadius: h * 0.2, backgroundColor: color }} />
      </View>
      <Segment
        x1={size * 0.1} y1={size * 0.82}
        x2={size * 0.9} y2={size * 0.18}
        color={color} thickness={strokeWidth}
      />
    </View>
  );
}
FILEEOF

mkdir -p "$(dirname "src/components/MonthSelector.tsx")"
cat > "src/components/MonthSelector.tsx" << 'FILEEOF'
import React, { useRef, useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Dimensions } from 'react-native';
import { theme, MONTHS_SHORT } from '../theme';

interface MonthSelectorProps {
  year: number;
  month: number; // 0-indexed
  onChange: (year: number, month: number) => void;
  /** How many months back from the current month to offer. */
  monthsBack?: number;
}

const ITEM_WIDTH = 64;
const SCREEN_WIDTH = Dimensions.get('window').width;

function buildMonthList(monthsBack: number): { year: number; month: number }[] {
  const now = new Date();
  const list: { year: number; month: number }[] = [];
  for (let i = monthsBack; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    list.push({ year: d.getFullYear(), month: d.getMonth() });
  }
  return list;
}

export function MonthSelector({ year, month, onChange, monthsBack = 24 }: MonthSelectorProps) {
  const scrollRef = useRef<ScrollView>(null);
  const months = useRef(buildMonthList(monthsBack)).current;

  const selectedIndex = months.findIndex(m => m.year === year && m.month === month);

  useEffect(() => {
    if (selectedIndex < 0) return;
    // Center the selected pill in the visible strip.
    const x = Math.max(0, selectedIndex * ITEM_WIDTH - SCREEN_WIDTH / 2 + ITEM_WIDTH / 2);
    // Defer to next tick so the ScrollView has laid out.
    const t = setTimeout(() => {
      scrollRef.current?.scrollTo({ x, animated: false });
    }, 0);
    return () => clearTimeout(t);
    // Only re-center on mount — after that, the user's own scroll takes over.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <ScrollView
      ref={scrollRef}
      horizontal
      showsHorizontalScrollIndicator={false}
      contentContainerStyle={s.content}
    >
      {months.map(m => {
        const isSelected = m.year === year && m.month === month;
        return (
          <TouchableOpacity
            key={`${m.year}-${m.month}`}
            style={[s.pill, isSelected && s.pillSelected]}
            onPress={() => onChange(m.year, m.month)}
          >
            <Text style={[s.pillText, isSelected && s.pillTextSelected]}>
              {MONTHS_SHORT[m.month]}/{String(m.year).slice(2)}
            </Text>
          </TouchableOpacity>
        );
      })}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  content: { paddingHorizontal: 8, gap: 6, alignItems: 'center' },
  pill: {
    width: ITEM_WIDTH - 6, paddingVertical: 8, borderRadius: 10,
    alignItems: 'center', justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.06)',
  },
  pillSelected: { backgroundColor: theme.gold },
  pillText: { fontSize: 12, fontWeight: '600', color: theme.textSec },
  pillTextSelected: { color: theme.bg, fontWeight: '800' },
});
FILEEOF

mkdir -p "$(dirname "src/context/PrivacyContext.tsx")"
cat > "src/context/PrivacyContext.tsx" << 'FILEEOF'
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { fCHF as formatCHF } from '../theme';

const STORAGE_KEY = 'valura:hideValues';
const MASK = 'CHF ••••••';

interface PrivacyContextValue {
  hidden: boolean;
  toggle: () => void;
  /** Same signature as fCHF, but returns a mask when privacy mode is on. */
  formatAmount: (n: number, decimals?: number) => string;
}

const PrivacyContext = createContext<PrivacyContextValue | undefined>(undefined);

export function PrivacyProvider({ children }: { children: React.ReactNode }) {
  const [hidden, setHidden] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY).then(v => {
      if (v === '1') setHidden(true);
    });
  }, []);

  const toggle = useCallback(() => {
    setHidden(prev => {
      const next = !prev;
      AsyncStorage.setItem(STORAGE_KEY, next ? '1' : '0').catch(() => {});
      return next;
    });
  }, []);

  const formatAmount = useCallback(
    (n: number, decimals = 2) => (hidden ? MASK : formatCHF(n, decimals)),
    [hidden]
  );

  return (
    <PrivacyContext.Provider value={{ hidden, toggle, formatAmount }}>
      {children}
    </PrivacyContext.Provider>
  );
}

export function usePrivacy(): PrivacyContextValue {
  const ctx = useContext(PrivacyContext);
  if (!ctx) throw new Error('usePrivacy must be used inside <PrivacyProvider>');
  return ctx;
}
FILEEOF

mkdir -p "$(dirname "app/_layout.tsx")"
cat > "app/_layout.tsx" << 'FILEEOF'
import React, { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider, useAuth } from '../src/context/AuthContext';
import { PrivacyProvider } from '../src/context/PrivacyContext';
import { theme } from '../src/theme';

// ─── AUTH GATE ────────────────────────────────────────────────────────────────
function RootNavigator() {
  const { user, loading, initialized } = useAuth();
  const router   = useRouter();
  const segments = useSegments();

  useEffect(() => {
    if (!initialized) return;
    const inAuthGroup = segments[0] === '(auth)';
    if (!user && !inAuthGroup) {
      router.replace('/(auth)/login');
    } else if (user && inAuthGroup) {
      router.replace('/(app)');
    }
  }, [user, initialized, segments]);

  if (!initialized || loading) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg }}>
        <ActivityIndicator color={theme.gold} size="large" />
      </View>
    );
  }

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(auth)" />
      <Stack.Screen name="(app)" />
    </Stack>
  );
}

// ─── ROOT LAYOUT ──────────────────────────────────────────────────────────────
export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <AuthProvider>
        <PrivacyProvider>
          <RootNavigator />
        </PrivacyProvider>
      </AuthProvider>
    </SafeAreaProvider>
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
import { usePrivacy }      from '../../../src/context/PrivacyContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget }       from '../../../src/hooks/useBudget';
import { useCategories }   from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';
import { BellIcon, SettingsIcon, EyeIcon, EyeOffIcon } from '../../../src/components/Icons';
import { CategoryIcon } from '../../../src/components/CategoryIcon';

const now = new Date();

export default function SummaryScreen() {
  const { user } = useAuth();
  const { hidden, toggle, formatAmount } = usePrivacy();
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
        value: formatAmount(Math.max(0, remaining) / Math.max(1, daysInMonth - now.getDate()), 0),
      }
    : {
        label: 'Média/dia',
        value: formatAmount(totalExpense / daysInMonth, 0),
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
            <TouchableOpacity style={s.bellBtn} onPress={toggle}>
              {hidden
                ? <EyeOffIcon size={16} color={theme.gold} />
                : <EyeIcon size={16} color={theme.gold} />}
            </TouchableOpacity>
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
        </View>

        <Text style={s.balLabel}>SALDO DISPONÍVEL</Text>
        <Text style={s.balance}>{formatAmount(remaining)}</Text>

        <View style={s.barBg}>
          <View style={[s.barFill, {
            width: `${Math.min(100, Math.round((totalExpense / (totalBudget || 1)) * 100))}%`,
          }]} />
        </View>

        <View style={s.barRow}>
          <Text style={s.barText}>Gasto: {formatAmount(totalExpense, 0)}</Text>
          <Text style={s.barText}>Orçamento: {formatAmount(totalBudget, 0)}</Text>
        </View>
      </View>

      {/* ── KPIs ── */}
      <View style={s.kpiRow}>
        {[
          { l: 'Receitas', v: formatAmount(totalIncome, 0), c: theme.income },
          { l: 'Despesas', v: formatAmount(totalExpense, 0), c: theme.expense },
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
          <TouchableOpacity
            key={tx.id}
            style={s.txRow}
            activeOpacity={0.7}
            onPress={() => router.push({
              pathname: '/(app)/adicionar',
              params: { transaction: JSON.stringify(tx) },
            })}
          >
            <View style={[s.txIcon, { backgroundColor: cat?.bg ?? '#233150' }]}>
              <CategoryIcon slug={cat?.slug ?? 'other'} size={18} color={cat?.color ?? theme.textSec} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={s.txDesc}>{tx.description}</Text>
              <Text style={s.txMeta}>{cat?.label} · {tx.date.slice(8)}/{tx.date.slice(5, 7)}</Text>
            </View>
            <Text style={[s.txAmount, { color: tx.type === 'income' ? theme.income : theme.expense }]}>
              {tx.type === 'income' ? '+' : '-'}{formatAmount(tx.amount)}
            </Text>
          </TouchableOpacity>
        );
      })}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { paddingTop: 20, paddingBottom: 22 },
  headerTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 18, paddingHorizontal: 20 },
  greeting: { fontSize: 17, fontWeight: '700', color: theme.gold, letterSpacing: -0.2 },
  bellBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center' },
  monthRow: { marginBottom: 22 },
  balLabel: { fontSize: 11, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.8, marginBottom: 6, paddingHorizontal: 20 },
  balance: { fontSize: 32, fontWeight: '700', color: theme.white, letterSpacing: -0.5, marginBottom: 16, paddingHorizontal: 20 },
  barBg: { height: 5, backgroundColor: 'rgba(255,255,255,.1)', borderRadius: 3, marginBottom: 8, marginHorizontal: 20 },
  barFill: { height: 5, borderRadius: 3, backgroundColor: theme.gold },
  barRow: { flexDirection: 'row', justifyContent: 'space-between', paddingHorizontal: 20 },
  barText: { fontSize: 11, color: theme.textSec },
  kpiRow: { flexDirection: 'row', gap: 8, padding: 14, paddingHorizontal: 20 },
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

mkdir -p "$(dirname "app/(app)/(tabs)/analise.tsx")"
cat > "app/(app)/(tabs)/analise.tsx" << 'FILEEOF'
import React, { useMemo, useState, useCallback } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { useAuth } from '../../../src/context/AuthContext';
import { usePrivacy } from '../../../src/context/PrivacyContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget, useCategories } from '../../../src/hooks/useBudget';
import { theme, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';
import { EyeIcon, EyeOffIcon } from '../../../src/components/Icons';

const now = new Date();

export default function AnaliseScreen() {
  const { user } = useAuth();
  const { hidden, toggle, formatAmount } = usePrivacy();
  const insets = useSafeAreaInsets();
  const userId = user?.id ?? '';

  const [viewYear, setViewYear] = useState(now.getFullYear());
  const [viewMonth, setViewMonth] = useState(now.getMonth());
  const monthYear = `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}`;

  const { transactions, loading: txLoading, refresh: refreshTx } = useTransactions({ userId, year: viewYear, month: viewMonth });
  const { categories, loading: catLoading, refresh: refreshCategories } = useCategories(userId);
  const { budget, loading: budLoading, refresh: refreshBudget } = useBudget(userId, monthYear);

  useFocusEffect(
    useCallback(() => {
      if (!userId) return;
      refreshTx();
      refreshCategories();
      refreshBudget();
    }, [userId, refreshTx, refreshCategories, refreshBudget])
  );

  const loading = txLoading || catLoading || budLoading;

  const { byCategory, totalExpense, totalIncome } = useMemo(() => {
    const expenseTxs = transactions.filter(t => t.type === 'expense');
    const totalExpense = expenseTxs.reduce((s, t) => s + t.amount, 0);
    const totalIncome = transactions
      .filter(t => t.type === 'income')
      .reduce((s, t) => s + t.amount, 0);

    const grouped = new Map<string, number>();
    for (const t of expenseTxs) {
      grouped.set(t.cat_id, (grouped.get(t.cat_id) ?? 0) + t.amount);
    }

    const byCategory = Array.from(grouped.entries())
      .map(([catId, amount]) => {
        const cat = categories.find(c => c.slug === catId);
        const goal = budget[catId] ?? 0;
        const budgetPct = goal > 0 ? Math.round((amount / goal) * 100) : null;
        return {
          catId,
          amount,
          label: cat?.label ?? catId,
          color: cat?.color ?? theme.gold,
          pct: totalExpense > 0 ? Math.round((amount / totalExpense) * 100) : 0,
          goal,
          budgetPct,
        };
      })
      .sort((a, b) => b.amount - a.amount);

    return { byCategory, totalExpense, totalIncome };
  }, [transactions, categories, budget]);

  if (!user || loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.gold} />
      </View>
    );
  }

  const maxAmount = byCategory[0]?.amount ?? 1;

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <View style={s.titleRow}>
          <Text style={s.title}>Análise</Text>
          <TouchableOpacity style={s.eyeBtn} onPress={toggle}>
            {hidden
              ? <EyeOffIcon size={16} color={theme.gold} />
              : <EyeIcon size={16} color={theme.gold} />}
          </TouchableOpacity>
        </View>
        <View style={s.monthRow}>
          <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} />
        </View>
      </View>

      <View style={s.kpiRow}>
        <View style={s.kpiCard}>
          <Text style={s.kpiLabel}>RECEITAS</Text>
          <Text style={[s.kpiValue, { color: theme.income }]}>{formatAmount(totalIncome, 0)}</Text>
        </View>
        <View style={s.kpiCard}>
          <Text style={s.kpiLabel}>DESPESAS</Text>
          <Text style={[s.kpiValue, { color: theme.expense }]}>{formatAmount(totalExpense, 0)}</Text>
        </View>
      </View>

      <Text style={s.sectionTitle}>Gastos por categoria</Text>

      {byCategory.length === 0 ? (
        <View style={s.emptyBox}>
          <Text style={s.emptyText}>Nenhuma despesa registrada em {MONTHS_FULL[viewMonth]}.</Text>
        </View>
      ) : (
        <View style={{ paddingHorizontal: 16, gap: 10 }}>
          {byCategory.map(c => {
            const overBudget = c.budgetPct !== null && c.budgetPct > 100;
            return (
              <View key={c.catId} style={s.catCard}>
                <View style={s.barLabelRow}>
                  <Text style={s.barLabel}>{c.label}</Text>
                  <Text style={s.barPct}>{c.pct}%</Text>
                </View>
                <View style={s.barTrack}>
                  <View
                    style={[
                      s.barFill,
                      {
                        width: `${Math.max(4, (c.amount / maxAmount) * 100)}%`,
                        backgroundColor: overBudget ? theme.danger : theme.gold,
                      },
                    ]}
                  />
                </View>
                <View style={s.bottomRow}>
                  <Text style={s.barAmount}>{formatAmount(c.amount, 0)}</Text>
                  {c.budgetPct !== null && (
                    <View style={[s.budgetBadge, overBudget && s.budgetBadgeOver]}>
                      <Text style={[s.budgetBadgeText, overBudget && s.budgetBadgeTextOver]}>
                        {c.budgetPct}% do orçamento
                      </Text>
                    </View>
                  )}
                </View>
              </View>
            );
          })}
        </View>
      )}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { paddingTop: 20, paddingBottom: 12, gap: 12 },
  titleRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 20 },
  title: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5 },
  eyeBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center' },
  monthRow: { },
  kpiRow: { flexDirection: 'row', gap: 8, paddingHorizontal: 16, marginBottom: 8 },
  kpiCard: {
    flex: 1, backgroundColor: theme.surface, borderRadius: 14, padding: 14,
    borderWidth: 1, borderColor: theme.border,
  },
  kpiLabel: { fontSize: 10, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 },
  kpiValue: { fontSize: 18, fontWeight: '800' },
  sectionTitle: {
    fontSize: 15, fontWeight: '700', color: theme.white,
    marginHorizontal: 16, marginTop: 16, marginBottom: 10, letterSpacing: -0.2,
  },
  emptyBox: {
    marginHorizontal: 16, padding: 24, backgroundColor: theme.surface,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, alignItems: 'center',
  },
  emptyText: { color: theme.textSec, fontSize: 13, textAlign: 'center' },
  catCard: {
    backgroundColor: theme.surface, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, gap: 8,
  },
  barLabelRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  barLabel: { fontSize: 14, fontWeight: '700', color: theme.white },
  barPct: { fontSize: 13, color: theme.textSec, fontWeight: '600' },
  barTrack: { height: 6, backgroundColor: 'rgba(255,255,255,.08)', borderRadius: 3, overflow: 'hidden' },
  barFill: { height: 6, borderRadius: 3 },
  bottomRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  barAmount: { fontSize: 12, color: theme.textSec, fontWeight: '600' },
  budgetBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8, backgroundColor: theme.goldSoft },
  budgetBadgeOver: { backgroundColor: 'rgba(248,113,113,0.15)' },
  budgetBadgeText: { fontSize: 10, fontWeight: '700', color: theme.gold },
  budgetBadgeTextOver: { color: theme.danger },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/orcamento.tsx")"
cat > "app/(app)/(tabs)/orcamento.tsx" << 'FILEEOF'
import React, { useMemo, useState, useCallback } from 'react';
import {
  View, Text, ScrollView, ActivityIndicator, StyleSheet,
  TextInput, TouchableOpacity, Keyboard,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { useAuth } from '../../../src/context/AuthContext';
import { usePrivacy } from '../../../src/context/PrivacyContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget, useCategories } from '../../../src/hooks/useBudget';
import { theme, MONTHS_FULL } from '../../../src/theme';
import { CategoryIcon } from '../../../src/components/CategoryIcon';
import { EyeIcon, EyeOffIcon } from '../../../src/components/Icons';

const now = new Date();
const CY = now.getFullYear();
const CM = now.getMonth();
const monthYear = `${CY}-${String(CM + 1).padStart(2, '0')}`;

export default function OrcamentoScreen() {
  const { user } = useAuth();
  const { hidden, toggle, formatAmount } = usePrivacy();
  const insets = useSafeAreaInsets();
  const userId = user!.id;

  const { transactions, loading: txLoading, refresh: refreshTx } = useTransactions({ userId, year: CY, month: CM });
  const { budget, loading: budLoading, updateBudget, refresh: refreshBudget } = useBudget(userId, monthYear);
  const { categories, loading: catLoading, refresh: refreshCategories } = useCategories(userId);

  useFocusEffect(
    useCallback(() => {
      refreshTx();
      refreshBudget();
      refreshCategories();
    }, [refreshTx, refreshBudget, refreshCategories])
  );

  const [editingId, setEditingId] = useState<string | null>(null);
  const [draftValue, setDraftValue] = useState('');

  const loading = txLoading || budLoading || catLoading;

  const spentByCategory = useMemo(() => {
    const map = new Map<string, number>();
    for (const t of transactions.filter(t => t.type === 'expense')) {
      map.set(t.cat_id, (map.get(t.cat_id) ?? 0) + t.amount);
    }
    return map;
  }, [transactions]);

  const expenseCategories = categories.filter(c => c.type === 'expense');

  const totalBudget = Object.values(budget).reduce((s, v) => s + v, 0);
  const totalSpent = Array.from(spentByCategory.values()).reduce((s, v) => s + v, 0);
  const totalPct = totalBudget > 0 ? Math.round((totalSpent / totalBudget) * 100) : 0;

  const startEditing = (catId: string) => {
    setEditingId(catId);
    setDraftValue(budget[catId] ? String(budget[catId]) : '');
  };

  const commitEdit = async (catId: string) => {
    const amount = parseFloat(draftValue.replace(',', '.')) || 0;
    setEditingId(null);
    Keyboard.dismiss();
    await updateBudget({ cat_id: catId, amount, month_year: monthYear });
  };

  if (loading) {
    return (
      <View style={s.center}>
        <ActivityIndicator size="large" color={theme.gold} />
      </View>
    );
  }

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <View style={s.titleRow}>
          <View>
            <Text style={s.title}>Orçamento</Text>
            <Text style={s.subtitle}>{MONTHS_FULL[CM]} {CY}</Text>
          </View>
          <TouchableOpacity style={s.eyeBtn} onPress={toggle}>
            {hidden
              ? <EyeOffIcon size={16} color={theme.gold} />
              : <EyeIcon size={16} color={theme.gold} />}
          </TouchableOpacity>
        </View>
      </View>

      <View style={s.summaryCard}>
        <View style={s.summaryTopRow}>
          <Text style={s.summaryLabel}>TOTAL ORÇADO</Text>
          {totalBudget > 0 && (
            <Text style={[s.summaryPct, totalPct > 100 && s.summaryPctOver]}>{totalPct}%</Text>
          )}
        </View>
        <Text style={s.summaryValue}>{formatAmount(totalBudget, 0)}</Text>
        <View style={s.barTrack}>
          <View
            style={[
              s.barFill,
              {
                width: `${totalBudget > 0 ? Math.min(100, (totalSpent / totalBudget) * 100) : 0}%`,
                backgroundColor: totalSpent > totalBudget && totalBudget > 0 ? theme.danger : theme.gold,
              },
            ]}
          />
        </View>
        <Text style={s.summaryHint}>
          Gasto: {formatAmount(totalSpent, 0)} de {formatAmount(totalBudget, 0)}
        </Text>
      </View>

      <Text style={s.sectionTitle}>Metas por categoria</Text>

      {expenseCategories.length === 0 ? (
        <View style={s.emptyBox}>
          <Text style={s.emptyText}>Nenhuma categoria de despesa cadastrada ainda.</Text>
        </View>
      ) : (
        <View style={{ gap: 10, paddingHorizontal: 16 }}>
          {expenseCategories.map(cat => {
            const spent = spentByCategory.get(cat.slug) ?? 0;
            const goal = budget[cat.slug] ?? 0;
            const pct = goal > 0 ? Math.round((spent / goal) * 100) : 0;
            const barWidthPct = Math.min(100, pct);
            const over = goal > 0 && spent > goal;

            return (
              <View key={cat.id} style={s.catCard}>
                <View style={s.catRow}>
                  <View style={[s.catIconWrap, { backgroundColor: cat.bg }]}>
                    <CategoryIcon slug={cat.slug} size={16} color={cat.color} />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={s.catLabel}>{cat.label}</Text>
                    <Text style={s.catSpent}>
                      {goal > 0 ? `${formatAmount(spent, 0)} de ${formatAmount(goal, 0)}` : `${formatAmount(spent, 0)} gasto`}
                      {goal > 0 && (
                        <Text style={over ? s.catPctOver : s.catPct}> · {pct}%</Text>
                      )}
                    </Text>
                  </View>

                  {editingId === cat.slug ? (
                    <TextInput
                      style={s.input}
                      value={draftValue}
                      onChangeText={setDraftValue}
                      keyboardType="decimal-pad"
                      autoFocus
                      onBlur={() => commitEdit(cat.slug)}
                      onSubmitEditing={() => commitEdit(cat.slug)}
                      placeholder="0"
                      placeholderTextColor={theme.textTer}
                    />
                  ) : (
                    <TouchableOpacity onPress={() => startEditing(cat.slug)}>
                      <Text style={s.editLink}>{goal > 0 ? 'Editar' : 'Definir'}</Text>
                    </TouchableOpacity>
                  )}
                </View>

                {goal > 0 && (
                  <View style={s.catBarTrack}>
                    <View
                      style={[
                        s.catBarFill,
                        { width: `${barWidthPct}%`, backgroundColor: over ? theme.danger : theme.gold },
                      ]}
                    />
                  </View>
                )}
              </View>
            );
          })}
        </View>
      )}
    </ScrollView>
  );
}

const s = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: theme.bg },
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { padding: 20, paddingBottom: 12 },
  titleRow: { flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between' },
  eyeBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5 },
  subtitle: { fontSize: 14, color: theme.textSec, marginTop: 2 },
  summaryCard: {
    marginHorizontal: 16, backgroundColor: theme.surface, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, marginBottom: 8,
  },
  summaryTopRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 4 },
  summaryLabel: { fontSize: 11, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.6 },
  summaryValue: { fontSize: 24, fontWeight: '800', color: theme.white, marginBottom: 12 },
  summaryPct: { fontSize: 15, fontWeight: '800', color: theme.gold },
  summaryPctOver: { color: theme.danger },
  summaryHint: { fontSize: 12, color: theme.textSec, marginTop: 8 },
  barTrack: { height: 6, backgroundColor: 'rgba(255,255,255,.08)', borderRadius: 3, overflow: 'hidden' },
  barFill: { height: 6, borderRadius: 3 },
  sectionTitle: {
    fontSize: 15, fontWeight: '700', color: theme.white,
    marginHorizontal: 16, marginTop: 12, marginBottom: 10, letterSpacing: -0.2,
  },
  emptyBox: {
    marginHorizontal: 16, padding: 24, backgroundColor: theme.surface,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, alignItems: 'center',
  },
  emptyText: { color: theme.textSec, fontSize: 13, textAlign: 'center' },
  catCard: {
    backgroundColor: theme.surface, borderRadius: 14, borderWidth: 1,
    borderColor: theme.border, padding: 12,
  },
  catRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  catIconWrap: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  catLabel: { fontSize: 14, fontWeight: '700', color: theme.white },
  catSpent: { fontSize: 12, color: theme.textSec, marginTop: 2 },
  catPct: { color: theme.textSec, fontWeight: '700' },
  catPctOver: { color: theme.danger, fontWeight: '700' },
  editLink: { fontSize: 13, fontWeight: '700', color: theme.gold },
  input: {
    width: 80, borderWidth: 1, borderColor: theme.gold, borderRadius: 8,
    paddingHorizontal: 8, paddingVertical: 6, fontSize: 14, textAlign: 'right',
    color: theme.inputText, backgroundColor: theme.inputBg,
  },
  catBarTrack: { height: 5, backgroundColor: 'rgba(255,255,255,.08)', borderRadius: 3, overflow: 'hidden', marginTop: 10 },
  catBarFill: { height: 5, borderRadius: 3 },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/projecoes.tsx")"
cat > "app/(app)/(tabs)/projecoes.tsx" << 'FILEEOF'
import React, { useMemo, useState, useEffect, useCallback } from 'react';
import { View, Text, ScrollView, StyleSheet, TextInput, ActivityIndicator, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { useAuth } from '../../../src/context/AuthContext';
import { usePrivacy } from '../../../src/context/PrivacyContext';
import * as TxRepo from '../../../src/repositories/transaction.repository';
import { theme, MONTHS_SHORT } from '../../../src/theme';
import { LineChart, LineChartPoint } from '../../../src/components/LineChart';
import { EyeIcon, EyeOffIcon } from '../../../src/components/Icons';

const INVESTMENT_CATEGORY_SLUG = 'investment';
const MAX_MONTHLY_YEARS = 5;
const CURRENT_YEAR = new Date().getFullYear();

interface YearProjection {
  year: number;         // 1-indexed offset from today (year 1 = next 12 months)
  calendarYear: number; // real calendar year, e.g. 2027
  contributed: number;
  value: number;
}

function projectYearly(
  startingValue: number,
  monthlyContribution: number,
  annualRatePct: number,
  years: number
): YearProjection[] {
  const monthlyRate = annualRatePct / 100 / 12;
  let value = startingValue;
  let contributed = startingValue;
  const results: YearProjection[] = [];

  for (let y = 1; y <= years; y++) {
    for (let m = 0; m < 12; m++) {
      value = value * (1 + monthlyRate) + monthlyContribution;
      contributed += monthlyContribution;
    }
    results.push({ year: y, calendarYear: CURRENT_YEAR + y, contributed, value });
  }
  return results;
}

function projectMonthly(
  startingValue: number,
  monthlyContribution: number,
  annualRatePct: number,
  months: number
): { label: string; value: number }[] {
  const monthlyRate = annualRatePct / 100 / 12;
  let value = startingValue;
  const results: { label: string; value: number }[] = [];
  const base = new Date();

  for (let i = 1; i <= months; i++) {
    value = value * (1 + monthlyRate) + monthlyContribution;
    const d = new Date(base.getFullYear(), base.getMonth() + i, 1);
    results.push({ label: `${MONTHS_SHORT[d.getMonth()]}/${String(d.getFullYear()).slice(2)}`, value });
  }
  return results;
}

function useInvestedSoFar(userId: string) {
  const [invested, setInvested] = useState<number | null>(null);

  const load = useCallback(async () => {
    if (!userId) return;
    const res = await TxRepo.getAllTransactions(userId);
    if (res.ok) {
      const total = res.data
        .filter(t => t.type === 'expense' && t.cat_id === INVESTMENT_CATEGORY_SLUG)
        .reduce((s, t) => s + t.amount, 0);
      setInvested(total);
    } else {
      setInvested(0);
    }
  }, [userId]);

  useEffect(() => { load(); }, [load]);
  useFocusEffect(useCallback(() => { load(); }, [load]));

  return invested;
}

export default function ProjecoesScreen() {
  const { user } = useAuth();
  const { hidden, toggle, formatAmount } = usePrivacy();
  const insets = useSafeAreaInsets();
  const profile = user?.profile;
  const investedSoFar = useInvestedSoFar(user?.id ?? '');

  const [initialPatrimony, setInitialPatrimony] = useState(String(profile?.net_worth ?? 0));
  const [monthlyContribution, setMonthlyContribution] = useState(
    String(profile?.monthly_income ? Math.round(profile.monthly_income * 0.2) : 500)
  );
  const [annualRate, setAnnualRate] = useState('5');
  const [years, setYears] = useState('10');
  const [view, setView] = useState<'ano' | 'mes'>('ano');

  const yearsNum = Math.max(1, Math.min(50, parseInt(years, 10) || 1));

  // Year range filter for the yearly chart — defaults to the full simulated span.
  const [fromYear, setFromYear] = useState(String(CURRENT_YEAR + 1));
  const [toYear, setToYear] = useState(String(CURRENT_YEAR + yearsNum));

  // Keep "Até" in sync when the simulated period shrinks below it.
  useEffect(() => {
    const maxYear = CURRENT_YEAR + yearsNum;
    if (parseInt(toYear, 10) > maxYear) setToYear(String(maxYear));
  }, [yearsNum]); // eslint-disable-line react-hooks/exhaustive-deps

  const effectiveStartingValue = useMemo(() => {
    const other = parseFloat(initialPatrimony.replace(',', '.')) || 0;
    return other + (investedSoFar ?? 0);
  }, [initialPatrimony, investedSoFar]);

  const mc = parseFloat(monthlyContribution.replace(',', '.')) || 0;
  const rate = parseFloat(annualRate.replace(',', '.')) || 0;

  const yearlyResults = useMemo(
    () => projectYearly(effectiveStartingValue, mc, rate, yearsNum),
    [effectiveStartingValue, mc, rate, yearsNum]
  );

  const fromYearNum = parseInt(fromYear, 10) || CURRENT_YEAR + 1;
  const toYearNum = parseInt(toYear, 10) || CURRENT_YEAR + yearsNum;

  const filteredYearlyResults = useMemo(
    () => yearlyResults.filter(r => r.calendarYear >= fromYearNum && r.calendarYear <= toYearNum),
    [yearlyResults, fromYearNum, toYearNum]
  );

  const monthlyMonthsToShow = Math.min(yearsNum, MAX_MONTHLY_YEARS) * 12;
  const monthlyResults = useMemo(
    () => projectMonthly(effectiveStartingValue, mc, rate, monthlyMonthsToShow),
    [effectiveStartingValue, mc, rate, monthlyMonthsToShow]
  );

  // The result card reflects the end of the selected year range (or the
  // full period if no filter narrows it).
  const final = filteredYearlyResults[filteredYearlyResults.length - 1] ?? yearlyResults[yearlyResults.length - 1];

  const chartData: LineChartPoint[] = view === 'ano'
    ? filteredYearlyResults.map(r => ({ label: String(r.calendarYear), value: r.value }))
    : monthlyResults.map(r => ({ label: r.label, value: r.value }));

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <View style={s.titleRow}>
          <View>
            <Text style={s.title}>Projeções</Text>
            <Text style={s.subtitle}>Simule a evolução do seu patrimônio</Text>
          </View>
          <TouchableOpacity style={s.eyeBtn} onPress={toggle}>
            {hidden
              ? <EyeOffIcon size={16} color={theme.gold} />
              : <EyeIcon size={16} color={theme.gold} />}
          </TouchableOpacity>
        </View>
      </View>

      {final && (
        <View style={s.resultCard}>
          <Text style={s.resultLabel}>Patrimônio estimado em {final.calendarYear}</Text>
          <Text style={s.resultValue}>{formatAmount(final.value, 0)}</Text>
          <View style={s.resultRow}>
            <Text style={s.resultSub}>Total aportado: {formatAmount(final.contributed, 0)}</Text>
            <Text style={[s.resultSub, { color: theme.income }]}>
              Rendimento: {formatAmount(final.value - final.contributed, 0)}
            </Text>
          </View>
        </View>
      )}

      <View style={s.investedCard}>
        <Text style={s.investedLabel}>VALOR INVESTIDO</Text>
        {investedSoFar === null ? (
          <ActivityIndicator size="small" color={theme.gold} style={{ marginTop: 6 }} />
        ) : (
          <>
            <Text style={s.investedValue}>{formatAmount(investedSoFar, 0)}</Text>
            <Text style={s.investedHint}>
              Soma de todas as transações na categoria Investimento.
            </Text>
          </>
        )}
      </View>

      <View style={s.formCard}>
        <Field label="Patrimônio inicial (CHF)" value={initialPatrimony} onChangeText={setInitialPatrimony} />
        <Field label="Aporte mensal (CHF)" value={monthlyContribution} onChangeText={setMonthlyContribution} />
        <Field label="Rentabilidade anual (%)" value={annualRate} onChangeText={setAnnualRate} />
        <Field label="Período (anos)" value={years} onChangeText={setYears} />
        <Text style={s.formHint}>
          A simulação soma Patrimônio inicial + Valor investido como ponto de partida: {formatAmount(effectiveStartingValue, 0)}.
        </Text>
      </View>

      <View style={s.sectionHeaderRow}>
        <Text style={s.sectionTitle}>Evolução</Text>
        <View style={s.toggle}>
          <TouchableOpacity
            style={[s.toggleBtn, view === 'mes' && s.toggleBtnActive]}
            onPress={() => setView('mes')}
          >
            <Text style={[s.toggleText, view === 'mes' && s.toggleTextActive]}>Mês</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[s.toggleBtn, view === 'ano' && s.toggleBtnActive]}
            onPress={() => setView('ano')}
          >
            <Text style={[s.toggleText, view === 'ano' && s.toggleTextActive]}>Ano</Text>
          </TouchableOpacity>
        </View>
      </View>

      {view === 'ano' && (
        <View style={s.yearFilterRow}>
          <Text style={s.yearFilterLabel}>De:</Text>
          <TextInput
            style={s.yearFilterInput}
            value={fromYear}
            onChangeText={setFromYear}
            keyboardType="number-pad"
            maxLength={4}
          />
          <Text style={s.yearFilterLabel}>Até:</Text>
          <TextInput
            style={s.yearFilterInput}
            value={toYear}
            onChangeText={setToYear}
            keyboardType="number-pad"
            maxLength={4}
          />
        </View>
      )}

      {view === 'mes' && yearsNum > MAX_MONTHLY_YEARS && (
        <Text style={s.monthlyNote}>
          Mostrando os primeiros {MAX_MONTHLY_YEARS} anos em detalhe mensal.
        </Text>
      )}

      <View style={s.chartBox}>
        <LineChart
          data={chartData}
          height={180}
          color={theme.gold}
          dotBorderColor={theme.white}
          scrollable={view === 'mes'}
          minPointSpacing={40}
          axisLabelColor="#94A3B8"
          gridColor="rgba(11,18,32,0.08)"
        />
      </View>
    </ScrollView>
  );
}

function Field({
  label, value, onChangeText,
}: { label: string; value: string; onChangeText: (v: string) => void }) {
  return (
    <View style={s.fieldRow}>
      <Text style={s.fieldLabel}>{label}</Text>
      <TextInput
        style={s.fieldInput}
        value={value}
        onChangeText={onChangeText}
        keyboardType="decimal-pad"
      />
    </View>
  );
}

const s = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: theme.bg },
  header: { padding: 20, paddingBottom: 12 },
  titleRow: { flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between' },
  title: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5 },
  subtitle: { fontSize: 14, color: theme.textSec, marginTop: 2 },
  eyeBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center' },
  resultCard: {
    marginHorizontal: 16, backgroundColor: theme.surface,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, padding: 18,
  },
  resultLabel: { fontSize: 12, color: theme.textSec, marginBottom: 4 },
  resultValue: { fontSize: 26, fontWeight: '800', color: theme.white, letterSpacing: -0.5, marginBottom: 10 },
  resultRow: { flexDirection: 'row', justifyContent: 'space-between' },
  resultSub: { fontSize: 12, color: theme.textSec, fontWeight: '600' },
  investedCard: {
    marginHorizontal: 16, marginTop: 10, backgroundColor: theme.surface,
    borderRadius: 14, borderWidth: 1, borderColor: theme.border, padding: 16,
  },
  investedLabel: { fontSize: 11, color: theme.textSec, textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 6 },
  investedValue: { fontSize: 22, fontWeight: '800', color: theme.white },
  investedHint: { fontSize: 11, color: theme.textSec, marginTop: 6, lineHeight: 16 },
  formCard: {
    marginHorizontal: 16, marginTop: 12, backgroundColor: theme.surface, borderRadius: 14,
    borderWidth: 1, borderColor: theme.border, padding: 16, gap: 12,
  },
  fieldRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  fieldLabel: { fontSize: 13, color: theme.textSec, flex: 1 },
  fieldInput: {
    width: 110, borderWidth: 1, borderColor: theme.border, borderRadius: 8,
    paddingHorizontal: 10, paddingVertical: 8, fontSize: 14, textAlign: 'right',
    color: theme.inputText, backgroundColor: theme.inputBg,
  },
  formHint: { fontSize: 11, color: theme.textSec, marginTop: 2, lineHeight: 16 },
  sectionHeaderRow: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    marginHorizontal: 16, marginTop: 18, marginBottom: 10,
  },
  sectionTitle: { fontSize: 15, fontWeight: '700', color: theme.white, letterSpacing: -0.2 },
  toggle: { flexDirection: 'row', backgroundColor: theme.surface, borderRadius: 8, padding: 2, borderWidth: 1, borderColor: theme.border },
  toggleBtn: { paddingHorizontal: 14, paddingVertical: 6, borderRadius: 6 },
  toggleBtnActive: { backgroundColor: theme.gold },
  toggleText: { fontSize: 12, fontWeight: '600', color: theme.textSec },
  toggleTextActive: { color: theme.bg },
  yearFilterRow: {
    flexDirection: 'row', alignItems: 'center', gap: 8,
    marginHorizontal: 16, marginBottom: 10,
  },
  yearFilterLabel: { fontSize: 12, color: theme.textSec, fontWeight: '600' },
  yearFilterInput: {
    width: 66, borderWidth: 1, borderColor: theme.border, borderRadius: 8,
    paddingHorizontal: 8, paddingVertical: 6, fontSize: 13, textAlign: 'center',
    color: theme.inputText, backgroundColor: theme.inputBg,
  },
  monthlyNote: { fontSize: 11, color: theme.textSec, marginHorizontal: 16, marginBottom: 8 },
  chartBox: {
    marginHorizontal: 16, backgroundColor: theme.white, borderRadius: 14,
    padding: 16,
  },
});
FILEEOF

mkdir -p "$(dirname "src/screens/auth/LoginScreen.tsx")"
cat > "src/screens/auth/LoginScreen.tsx" << 'FILEEOF'
import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity,
  StyleSheet, KeyboardAvoidingView, Platform,
  ScrollView, ActivityIndicator,
} from 'react-native';
import * as AppleAuthentication from 'expo-apple-authentication';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useAuth } from '../../context/AuthContext';
import { theme } from '../../theme';
import { EyeIcon, EyeOffIcon } from '../../components/Icons';

export default function LoginScreen() {
  const { signInWithEmail, signInWithApple, loading } = useAuth();
  const router = useRouter();
  const insets = useSafeAreaInsets();

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
        contentContainerStyle={[styles.scroll, { paddingTop: insets.top + 40 }]}
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
            placeholderTextColor={theme.textTer}
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
              style={[styles.input, { flex: 1, borderWidth: 0, backgroundColor: 'transparent' }]}
              value={password}
              onChangeText={setPassword}
              placeholder="••••••••"
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

        {/* Sign in button */}
        <TouchableOpacity
          style={[styles.primaryBtn, loading && styles.btnDisabled]}
          onPress={handleEmail}
          disabled={loading}
          activeOpacity={0.85}
        >
          {loading
            ? <ActivityIndicator color={theme.bg} />
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
          buttonStyle={AppleAuthentication.AppleAuthenticationButtonStyle.WHITE}
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
  root:           { flex: 1, backgroundColor: theme.bg },
  scroll:         { flexGrow: 1, paddingHorizontal: 24, paddingBottom: 40 },
  header:         { alignItems: 'center', paddingBottom: 40 },
  logoCircle:     { width: 72, height: 72, borderRadius: 36, backgroundColor: theme.gold, alignItems: 'center', justifyContent: 'center', marginBottom: 16 },
  logoText:       { fontSize: 32, fontWeight: '800', color: theme.bg },
  appName:        { fontSize: 30, fontWeight: '800', color: theme.white, letterSpacing: -0.5, marginBottom: 6 },
  tagline:        { fontSize: 14, color: theme.textSec, fontWeight: '400' },
  errorBox:       { backgroundColor: 'rgba(248,113,113,0.12)', borderRadius: 10, padding: 12, marginBottom: 16 },
  errorText:      { color: theme.danger, fontSize: 13, fontWeight: '500' },
  field:          { marginBottom: 16 },
  label:          { fontSize: 13, fontWeight: '500', color: theme.textSec, marginBottom: 6 },
  labelRow:       { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 },
  forgotLink:     { fontSize: 13, color: theme.gold, fontWeight: '600' },
  input:          { borderWidth: 1, borderColor: theme.border, borderRadius: 10, paddingHorizontal: 14, paddingVertical: 12, fontSize: 15, color: theme.inputText, backgroundColor: theme.inputBg },
  passwordWrap:   { flexDirection: 'row', alignItems: 'center', borderWidth: 1, borderColor: theme.border, borderRadius: 10, overflow: 'hidden', backgroundColor: theme.inputBg },
  eyeBtn:         { paddingHorizontal: 12, paddingVertical: 12 },
  primaryBtn:     { backgroundColor: theme.gold, borderRadius: 12, paddingVertical: 14, alignItems: 'center', marginTop: 8 },
  primaryBtnText: { fontSize: 16, fontWeight: '700', color: theme.bg, letterSpacing: -0.2 },
  btnDisabled:    { opacity: 0.6 },
  divider:        { flexDirection: 'row', alignItems: 'center', marginVertical: 24, gap: 10 },
  dividerLine:    { flex: 1, height: 1, backgroundColor: theme.border },
  dividerText:    { fontSize: 12, color: theme.textTer, fontWeight: '400' },
  appleBtn:       { width: '100%', height: 50, marginBottom: 12 },
  registerRow:    { flexDirection: 'row', justifyContent: 'center', marginTop: 16 },
  registerText:   { fontSize: 14, color: theme.textSec },
  registerLink:   { fontSize: 14, color: theme.gold, fontWeight: '600' },
});
FILEEOF

mkdir -p "$(dirname "app/(auth)/register.tsx")"
cat > "app/(auth)/register.tsx" << 'FILEEOF'
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
FILEEOF

mkdir -p "$(dirname "app/(auth)/forgot-password.tsx")"
cat > "app/(auth)/forgot-password.tsx" << 'FILEEOF'
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
FILEEOF

mkdir -p "$(dirname "app/(auth)/reset-password.tsx")"
cat > "app/(auth)/reset-password.tsx" << 'FILEEOF'
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
FILEEOF

npx tsc --noEmit
echo "Confirmando ausencia de imports nativos novos..."
if grep -rlE "from 'react-native-gesture-handler'|from 'react-native-purchases'" app/ src/ 2>/dev/null; then
  echo "AVISO: import nativo encontrado, revisar"
else
  echo "OK: seguro para o binario ja instalado"
fi

git add -A
git commit -m "Add privacy toggle (hide values), dark theme for all auth screens, real years + De/Ate filter in Projecoes, scrollable month strip selector"
git push

echo ""
echo "Pronto! Roda:"
echo "  npx expo start --dev-client --tunnel --clear"
echo "(ou o metodo de porta publica do Codespace, se o tunel continuar instavel)"
