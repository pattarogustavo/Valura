#!/bin/bash
set -e
echo "Aplicando nova identidade visual (tema escuro/dourado)..."
mkdir -p src/components

mkdir -p "$(dirname "src/theme.ts")"
cat > "src/theme.ts" << 'FILEEOF'
// ─── SHARED DESIGN TOKENS — dark navy / gold identity ─────────────────────────

export const theme = {
  bg:           '#0B1220', // page background — deep navy
  surface:      '#151F35', // card background
  surfaceAlt:   '#1B2A47', // slightly lighter surface (highlighted rows)
  border:       'rgba(255,255,255,0.08)',

  gold:         '#C9A15B', // primary accent
  goldDark:     '#A9843F',
  goldSoft:     'rgba(201,161,91,0.15)',

  // Kept for backwards-compat with any code referencing `brand`
  brand:        '#C9A15B',
  brandDark:    '#A9843F',

  text:         '#FFFFFF',
  textSec:      '#94A3B8',
  textTer:      '#5B6B85',

  white:        '#FFFFFF',
  inputBg:      '#F5F7FA',
  inputText:    '#0B1220',

  income:       '#4ADE80',
  expense:      '#F87171',
  good:         '#4ADE80',
  warn:         '#FBBF24',
  danger:       '#F87171',
};

export const fCHF = (n: number, d = 2) =>
  'CHF ' + Number(n || 0).toLocaleString('pt-PT', { minimumFractionDigits: d, maximumFractionDigits: d });

export const MONTHS_FULL = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

export const MONTHS_SHORT = [
  'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
];
FILEEOF

mkdir -p "$(dirname "src/components/MonthSelector.tsx")"
cat > "src/components/MonthSelector.tsx" << 'FILEEOF'
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { theme, MONTHS_FULL } from '../theme';

interface MonthSelectorProps {
  year: number;
  month: number; // 0-indexed
  onChange: (year: number, month: number) => void;
}

export function MonthSelector({ year, month, onChange }: MonthSelectorProps) {
  const now = new Date();
  const isCurrentMonth = year === now.getFullYear() && month === now.getMonth();

  const goPrev = () => {
    if (month === 0) onChange(year - 1, 11);
    else onChange(year, month - 1);
  };

  const goNext = () => {
    if (isCurrentMonth) return; // don't allow navigating into the future
    if (month === 11) onChange(year + 1, 0);
    else onChange(year, month + 1);
  };

  return (
    <View style={s.row}>
      <TouchableOpacity onPress={goPrev} style={s.arrowBtn} hitSlop={8}>
        <Text style={s.arrow}>‹</Text>
      </TouchableOpacity>

      <Text style={s.label}>
        {MONTHS_FULL[month]} {year}
      </Text>

      <TouchableOpacity
        onPress={goNext}
        style={s.arrowBtn}
        hitSlop={8}
        disabled={isCurrentMonth}
      >
        <Text style={[s.arrow, isCurrentMonth && s.arrowDisabled]}>›</Text>
      </TouchableOpacity>
    </View>
  );
}

const s = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  arrowBtn: { padding: 4 },
  arrow: { fontSize: 22, fontWeight: '700', color: theme.white },
  arrowDisabled: { opacity: 0.3 },
  label: { fontSize: 14, fontWeight: '600', color: 'rgba(255,255,255,.85)', minWidth: 120, textAlign: 'center' },
});
FILEEOF

mkdir -p "$(dirname "src/components/DatePickerField.tsx")"
cat > "src/components/DatePickerField.tsx" << 'FILEEOF'
import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Modal, Pressable } from 'react-native';
import { theme, MONTHS_FULL } from '../theme';

interface DatePickerFieldProps {
  value: string; // 'YYYY-MM-DD'
  onChange: (date: string) => void;
}

const WEEKDAYS = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

function toISODate(y: number, m: number, d: number): string {
  return `${y}-${String(m + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

function parseISODate(iso: string): { y: number; m: number; d: number } {
  const [y, m, d] = iso.split('-').map(Number);
  return { y, m: m - 1, d };
}

function formatDisplay(iso: string): string {
  const { y, m, d } = parseISODate(iso);
  return `${String(d).padStart(2, '0')} de ${MONTHS_FULL[m]} de ${y}`;
}

export function DatePickerField({ value, onChange }: DatePickerFieldProps) {
  const [open, setOpen] = useState(false);
  const selected = parseISODate(value);
  const [viewYear, setViewYear] = useState(selected.y);
  const [viewMonth, setViewMonth] = useState(selected.m);

  const openPicker = () => {
    setViewYear(selected.y);
    setViewMonth(selected.m);
    setOpen(true);
  };

  const firstWeekday = new Date(viewYear, viewMonth, 1).getDay();
  const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();

  const cells: (number | null)[] = [];
  for (let i = 0; i < firstWeekday; i++) cells.push(null);
  for (let d = 1; d <= daysInMonth; d++) cells.push(d);

  const goPrevMonth = () => {
    if (viewMonth === 0) { setViewYear(y => y - 1); setViewMonth(11); }
    else setViewMonth(m => m - 1);
  };
  const goNextMonth = () => {
    if (viewMonth === 11) { setViewYear(y => y + 1); setViewMonth(0); }
    else setViewMonth(m => m + 1);
  };

  const pickDay = (d: number) => {
    onChange(toISODate(viewYear, viewMonth, d));
    setOpen(false);
  };

  return (
    <>
      <TouchableOpacity style={s.field} onPress={openPicker}>
        <Text style={s.fieldText}>{formatDisplay(value)}</Text>
        <Text style={s.fieldIcon}>📅</Text>
      </TouchableOpacity>

      <Modal visible={open} transparent animationType="fade" onRequestClose={() => setOpen(false)}>
        <Pressable style={s.backdrop} onPress={() => setOpen(false)}>
          <Pressable style={s.calendarBox} onPress={() => {}}>
            <View style={s.calHeader}>
              <TouchableOpacity onPress={goPrevMonth} hitSlop={8}>
                <Text style={s.calArrow}>‹</Text>
              </TouchableOpacity>
              <Text style={s.calTitle}>{MONTHS_FULL[viewMonth]} {viewYear}</Text>
              <TouchableOpacity onPress={goNextMonth} hitSlop={8}>
                <Text style={s.calArrow}>›</Text>
              </TouchableOpacity>
            </View>

            <View style={s.weekRow}>
              {WEEKDAYS.map((w, i) => (
                <Text key={i} style={s.weekLabel}>{w}</Text>
              ))}
            </View>

            <View style={s.grid}>
              {cells.map((d, i) => {
                if (d === null) return <View key={i} style={s.cell} />;
                const isSelected = d === selected.d && viewMonth === selected.m && viewYear === selected.y;
                return (
                  <TouchableOpacity
                    key={i}
                    style={[s.cell, isSelected && s.cellSelected]}
                    onPress={() => pickDay(d)}
                  >
                    <Text style={[s.cellText, isSelected && s.cellTextSelected]}>{d}</Text>
                  </TouchableOpacity>
                );
              })}
            </View>

            <TouchableOpacity style={s.closeBtn} onPress={() => setOpen(false)}>
              <Text style={s.closeBtnText}>Cancelar</Text>
            </TouchableOpacity>
          </Pressable>
        </Pressable>
      </Modal>
    </>
  );
}

const CELL_SIZE = 40;

const s = StyleSheet.create({
  field: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    borderWidth: 1, borderColor: theme.border, borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 12, backgroundColor: theme.inputBg,
  },
  fieldText: { fontSize: 15, color: theme.inputText },
  fieldIcon: { fontSize: 16 },
  backdrop: { flex: 1, backgroundColor: 'rgba(10,25,41,.5)', alignItems: 'center', justifyContent: 'center' },
  calendarBox: {
    width: 320, backgroundColor: theme.white, borderRadius: 16, padding: 16,
  },
  calHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  calArrow: { fontSize: 22, fontWeight: '700', color: theme.text, paddingHorizontal: 8 },
  calTitle: { fontSize: 15, fontWeight: '700', color: theme.text },
  weekRow: { flexDirection: 'row', marginBottom: 4 },
  weekLabel: { width: CELL_SIZE, textAlign: 'center', fontSize: 11, color: theme.textTer, fontWeight: '600' },
  grid: { flexDirection: 'row', flexWrap: 'wrap' },
  cell: { width: CELL_SIZE, height: CELL_SIZE, alignItems: 'center', justifyContent: 'center' },
  cellSelected: { backgroundColor: theme.brand, borderRadius: CELL_SIZE / 2 },
  cellText: { fontSize: 14, color: theme.text },
  cellTextSelected: { color: theme.white, fontWeight: '700' },
  closeBtn: { marginTop: 8, alignItems: 'center', paddingVertical: 10 },
  closeBtnText: { fontSize: 14, color: theme.textTer, fontWeight: '600' },
});
FILEEOF

mkdir -p "$(dirname "src/components/LineChart.tsx")"
cat > "src/components/LineChart.tsx" << 'FILEEOF'
import React, { useState } from 'react';
import { View, Text, StyleSheet, LayoutChangeEvent, ScrollView } from 'react-native';
import { theme } from '../theme';

export interface LineChartPoint {
  label: string;
  value: number;
}

interface LineChartProps {
  data: LineChartPoint[];
  height?: number;
  color?: string;
  dotBorderColor?: string;
  formatValue?: (v: number) => string;
  /** If true, the chart scrolls horizontally instead of squeezing all points in. */
  scrollable?: boolean;
  minPointSpacing?: number;
  axisLabelColor?: string;
  gridColor?: string;
}

const DOT_RADIUS = 4;
const LINE_THICKNESS = 2;
const Y_AXIS_WIDTH = 42;

/** Picks a "nice" step size (1, 2, 2.5, 5 × 10^n) for axis gridlines. */
function niceStep(roughStep: number): number {
  if (roughStep <= 0) return 1;
  const exp = Math.floor(Math.log10(roughStep));
  const base = roughStep / Math.pow(10, exp);
  let niceBase: number;
  if (base <= 1) niceBase = 1;
  else if (base <= 2) niceBase = 2;
  else if (base <= 5) niceBase = 5;
  else niceBase = 10;
  return niceBase * Math.pow(10, exp);
}

function formatCompact(v: number): string {
  const abs = Math.abs(v);
  if (abs >= 1000) return `${Math.round(v / 1000)}k`;
  return String(Math.round(v));
}

export function LineChart({
  data,
  height = 180,
  color = theme.gold,
  dotBorderColor = theme.white,
  formatValue,
  scrollable = false,
  minPointSpacing = 44,
  axisLabelColor = theme.textTer,
  gridColor = 'rgba(0,0,0,0.08)',
}: LineChartProps) {
  const [measuredWidth, setMeasuredWidth] = useState(0);

  const onLayout = (e: LayoutChangeEvent) => {
    setMeasuredWidth(e.nativeEvent.layout.width);
  };

  if (data.length === 0) return null;

  const plotAreaWidth = Math.max(0, measuredWidth - Y_AXIS_WIDTH);
  const contentWidth = scrollable
    ? Math.max(plotAreaWidth, data.length * minPointSpacing)
    : plotAreaWidth;

  const chartH = height;
  const padding = 16;

  const values = data.map(d => d.value);
  const rawMax = Math.max(...values, 0);
  const step = niceStep(rawMax / 4);
  const axisMax = Math.ceil(rawMax / step) * step || step;
  const gridValues = [0, 1, 2, 3, 4].map(i => (axisMax / 4) * i).reverse();

  const points = data.map((d, i) => {
    const x = data.length === 1
      ? contentWidth / 2
      : padding + (i / (data.length - 1)) * (contentWidth - padding * 2);
    const y = chartH - padding - (d.value / (axisMax || 1)) * (chartH - padding * 2);
    return { x, y, ...d };
  });

  const segments = points.slice(1).map((p2, i) => {
    const p1 = points[i];
    const dx = p2.x - p1.x;
    const dy = p2.y - p1.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    const angle = Math.atan2(dy, dx) * (180 / Math.PI);
    const midX = (p1.x + p2.x) / 2;
    const midY = (p1.y + p2.y) / 2;
    return {
      key: `seg-${i}`,
      left: midX - dist / 2,
      top: midY - LINE_THICKNESS / 2,
      width: dist,
      angle,
    };
  });

  const labelStep = Math.max(1, Math.ceil(data.length / 8));

  const plot = (
    <View style={{ width: contentWidth || '100%' }}>
      <View style={{ width: contentWidth || '100%', height: chartH }}>
        {/* Gridlines */}
        {gridValues.map((v, i) => {
          const y = chartH - padding - (v / (axisMax || 1)) * (chartH - padding * 2);
          return (
            <View
              key={`grid-${i}`}
              style={{
                position: 'absolute', left: 0, top: y, width: contentWidth,
                height: StyleSheet.hairlineWidth, backgroundColor: gridColor,
              }}
            />
          );
        })}

        {segments.map(seg => (
          <View
            key={seg.key}
            style={{
              position: 'absolute',
              left: seg.left,
              top: seg.top,
              width: seg.width,
              height: LINE_THICKNESS,
              backgroundColor: color,
              borderRadius: LINE_THICKNESS / 2,
              transform: [{ rotate: `${seg.angle}deg` }],
            }}
          />
        ))}
        {points.map((p, i) => (
          <View
            key={`dot-${i}`}
            style={{
              position: 'absolute',
              left: p.x - DOT_RADIUS,
              top: p.y - DOT_RADIUS,
              width: DOT_RADIUS * 2,
              height: DOT_RADIUS * 2,
              borderRadius: DOT_RADIUS,
              backgroundColor: color,
              borderWidth: 2,
              borderColor: dotBorderColor,
            }}
          />
        ))}
      </View>

      <View style={{ width: contentWidth || '100%', height: 18 }}>
        {points.map((p, i) => (
          <View key={`lbl-${i}`} style={{ position: 'absolute', left: p.x - 20, width: 40, alignItems: 'center' }}>
            {i % labelStep === 0 && (
              <Text style={[s.axisLabel, { color: axisLabelColor }]} numberOfLines={1}>{p.label}</Text>
            )}
          </View>
        ))}
      </View>
    </View>
  );

  return (
    <View onLayout={onLayout} style={{ flexDirection: 'row' }}>
      {/* Y axis labels */}
      <View style={{ width: Y_AXIS_WIDTH, height: chartH }}>
        {gridValues.map((v, i) => {
          const y = chartH - padding - (v / (axisMax || 1)) * (chartH - padding * 2);
          return (
            <Text
              key={`ylbl-${i}`}
              style={[s.yAxisLabel, { color: axisLabelColor, top: y - 6 }]}
            >
              {formatValue ? formatValue(v) : formatCompact(v)}
            </Text>
          );
        })}
      </View>

      {measuredWidth > 0 && (
        scrollable ? (
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            {plot}
          </ScrollView>
        ) : (
          plot
        )
      )}
    </View>
  );
}

const s = StyleSheet.create({
  axisLabel: { fontSize: 9, marginTop: 4 },
  yAxisLabel: { position: 'absolute', fontSize: 10, fontWeight: '600', right: 8 },
});
FILEEOF

mkdir -p "$(dirname "app/_layout.tsx")"
cat > "app/_layout.tsx" << 'FILEEOF'
import React, { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider, useAuth } from '../src/context/AuthContext';
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
        <RootNavigator />
      </AuthProvider>
    </SafeAreaProvider>
  );
}
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/_layout.tsx")"
cat > "app/(app)/(tabs)/_layout.tsx" << 'FILEEOF'
import React from 'react';
import { Tabs, useRouter } from 'expo-router';
import { View, Text, TouchableOpacity, Platform, StyleSheet } from 'react-native';
import { theme } from '../../../src/theme';

function TabIcon({ emoji, focused }: { emoji: string; focused: boolean }) {
  return (
    <Text style={{ fontSize: 22, opacity: focused ? 1 : 0.5 }}>{emoji}</Text>
  );
}

export default function TabsLayout() {
  const router = useRouter();

  return (
    <View style={{ flex: 1 }}>
      <Tabs
        screenOptions={{
          headerShown: false,
          tabBarActiveTintColor: theme.brand,
          tabBarInactiveTintColor: theme.textTer,
          tabBarStyle: {
            backgroundColor: theme.surface,
            borderTopColor: theme.border,
            borderTopWidth: 1,
            height: Platform.OS === 'ios' ? 88 : 64,
            paddingTop: 8,
          },
          tabBarLabelStyle: { fontSize: 11, fontWeight: '600' },
        }}
      >
        <Tabs.Screen
          name="index"
          options={{
            title: 'Resumo',
            tabBarIcon: ({ focused }) => <TabIcon emoji="🏠" focused={focused} />,
          }}
        />
        <Tabs.Screen
          name="analise"
          options={{
            title: 'Análise',
            tabBarIcon: ({ focused }) => <TabIcon emoji="📊" focused={focused} />,
          }}
        />
        <Tabs.Screen
          name="orcamento"
          options={{
            title: 'Orçamento',
            tabBarIcon: ({ focused }) => <TabIcon emoji="🎯" focused={focused} />,
          }}
        />
        <Tabs.Screen
          name="projecoes"
          options={{
            title: 'Projeções',
            tabBarIcon: ({ focused }) => <TabIcon emoji="📈" focused={focused} />,
          }}
        />
      </Tabs>

      {/* Floating action button — opens the "add transaction" modal */}
      <TouchableOpacity
        style={styles.fab}
        activeOpacity={0.85}
        onPress={() => router.push('/(app)/adicionar')}
      >
        <Text style={styles.fabIcon}>+</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  fab: {
    position: 'absolute',
    right: 20,
    bottom: Platform.OS === 'ios' ? 104 : 80,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: theme.brand,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 8,
    elevation: 6,
  },
  fabIcon: {
    fontSize: 30,
    color: theme.white,
    fontWeight: '400',
    marginTop: -2,
  },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/(tabs)/index.tsx")"
cat > "app/(app)/(tabs)/index.tsx" << 'FILEEOF'
/**
 * app/(app)/(tabs)/index.tsx  →  Summary / Dashboard tab
 */

import React, { useMemo, useState, useCallback } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { useAuth }         from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget }       from '../../../src/hooks/useBudget';
import { useCategories }   from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';

const now = new Date();

export default function SummaryScreen() {
  const { user } = useAuth();
  const insets = useSafeAreaInsets();

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
          <View style={s.bellBtn}>
            <Text style={s.bellIcon}>🔔</Text>
          </View>
        </View>

        <View style={s.monthRow}>
          <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} />
          <TouchableOpacity
            style={s.calendarBtn}
            onPress={() => { setViewYear(now.getFullYear()); setViewMonth(now.getMonth()); }}
          >
            <Text style={s.calendarIcon}>📅</Text>
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
              <Text style={{ fontSize: 18 }}>{cat?.icon ?? '📦'}</Text>
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

mkdir -p "$(dirname "app/(app)/(tabs)/analise.tsx")"
cat > "app/(app)/(tabs)/analise.tsx" << 'FILEEOF'
import React, { useMemo, useState, useCallback } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from 'expo-router';
import { useAuth } from '../../../src/context/AuthContext';
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget, useCategories } from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';
import { MonthSelector } from '../../../src/components/MonthSelector';

const now = new Date();

export default function AnaliseScreen() {
  const { user } = useAuth();
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
          icon: cat?.icon ?? '📦',
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
        <Text style={s.title}>Análise</Text>
        <View style={s.monthRow}>
          <MonthSelector year={viewYear} month={viewMonth} onChange={(y, m) => { setViewYear(y); setViewMonth(m); }} />
          <View style={s.calendarBtn}>
            <Text style={s.calendarIcon}>📅</Text>
          </View>
        </View>
      </View>

      <View style={s.kpiRow}>
        <View style={s.kpiCard}>
          <Text style={s.kpiLabel}>RECEITAS</Text>
          <Text style={[s.kpiValue, { color: theme.income }]}>{fCHF(totalIncome, 0)}</Text>
        </View>
        <View style={s.kpiCard}>
          <Text style={s.kpiLabel}>DESPESAS</Text>
          <Text style={[s.kpiValue, { color: theme.expense }]}>{fCHF(totalExpense, 0)}</Text>
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
                  <Text style={s.barAmount}>{fCHF(c.amount, 0)}</Text>
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
  header: { padding: 20, paddingBottom: 12, gap: 12 },
  title: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5 },
  monthRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  calendarBtn: { width: 36, height: 36, borderRadius: 10, backgroundColor: theme.surface, alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: theme.border },
  calendarIcon: { fontSize: 15 },
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
import { useTransactions } from '../../../src/hooks/useTransactions';
import { useBudget, useCategories } from '../../../src/hooks/useBudget';
import { theme, fCHF, MONTHS_FULL } from '../../../src/theme';

const now = new Date();
const CY = now.getFullYear();
const CM = now.getMonth();
const monthYear = `${CY}-${String(CM + 1).padStart(2, '0')}`;

export default function OrcamentoScreen() {
  const { user } = useAuth();
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
        <Text style={s.title}>Orçamento</Text>
        <Text style={s.subtitle}>{MONTHS_FULL[CM]} {CY}</Text>
      </View>

      <View style={s.summaryCard}>
        <View style={s.summaryTopRow}>
          <Text style={s.summaryLabel}>TOTAL ORÇADO</Text>
          {totalBudget > 0 && (
            <Text style={[s.summaryPct, totalPct > 100 && s.summaryPctOver]}>{totalPct}%</Text>
          )}
        </View>
        <Text style={s.summaryValue}>{fCHF(totalBudget, 0)}</Text>
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
          Gasto: {fCHF(totalSpent, 0)} de {fCHF(totalBudget, 0)}
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
                    <Text style={{ fontSize: 16 }}>{cat.icon}</Text>
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={s.catLabel}>{cat.label}</Text>
                    <Text style={s.catSpent}>
                      {goal > 0 ? `${fCHF(spent, 0)} de ${fCHF(goal, 0)}` : `${fCHF(spent, 0)} gasto`}
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
import * as TxRepo from '../../../src/repositories/transaction.repository';
import { theme, fCHF, MONTHS_SHORT } from '../../../src/theme';
import { LineChart, LineChartPoint } from '../../../src/components/LineChart';

const INVESTMENT_CATEGORY_SLUG = 'investment';
const MAX_MONTHLY_YEARS = 5;

interface YearProjection {
  year: number;
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
    results.push({ year: y, contributed, value });
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
  const insets = useSafeAreaInsets();
  const profile = user?.profile;
  const investedSoFar = useInvestedSoFar(user?.id ?? '');

  const [otherAssets, setOtherAssets] = useState(String(profile?.net_worth ?? 0));
  const [monthlyContribution, setMonthlyContribution] = useState(
    String(profile?.monthly_income ? Math.round(profile.monthly_income * 0.2) : 500)
  );
  const [annualRate, setAnnualRate] = useState('5');
  const [years, setYears] = useState('10');
  const [view, setView] = useState<'ano' | 'mes'>('ano');

  const effectiveStartingValue = useMemo(() => {
    const other = parseFloat(otherAssets.replace(',', '.')) || 0;
    return other + (investedSoFar ?? 0);
  }, [otherAssets, investedSoFar]);

  const yearsNum = Math.max(1, Math.min(50, parseInt(years, 10) || 1));
  const mc = parseFloat(monthlyContribution.replace(',', '.')) || 0;
  const rate = parseFloat(annualRate.replace(',', '.')) || 0;

  const yearlyResults = useMemo(
    () => projectYearly(effectiveStartingValue, mc, rate, yearsNum),
    [effectiveStartingValue, mc, rate, yearsNum]
  );

  const monthlyMonthsToShow = Math.min(yearsNum, MAX_MONTHLY_YEARS) * 12;
  const monthlyResults = useMemo(
    () => projectMonthly(effectiveStartingValue, mc, rate, monthlyMonthsToShow),
    [effectiveStartingValue, mc, rate, monthlyMonthsToShow]
  );

  const final = yearlyResults[yearlyResults.length - 1];

  const chartData: LineChartPoint[] = view === 'ano'
    ? yearlyResults.map(r => ({ label: `Ano ${r.year}`, value: r.value }))
    : monthlyResults.map(r => ({ label: r.label, value: r.value }));

  return (
    <ScrollView style={s.scroll} contentContainerStyle={{ paddingBottom: 120 }}>
      <View style={[s.header, { paddingTop: insets.top + 16 }]}>
        <Text style={s.title}>Projeções</Text>
        <Text style={s.subtitle}>Simule a evolução do seu patrimônio</Text>
      </View>

      {final && (
        <View style={s.resultCard}>
          <Text style={s.resultLabel}>Patrimônio estimado em {final.year} {final.year === 1 ? 'ano' : 'anos'}</Text>
          <Text style={s.resultValue}>{fCHF(final.value, 0)}</Text>
          <View style={s.resultRow}>
            <Text style={s.resultSub}>Total aportado: {fCHF(final.contributed, 0)}</Text>
            <Text style={[s.resultSub, { color: theme.income }]}>
              Rendimento: {fCHF(final.value - final.contributed, 0)}
            </Text>
          </View>
        </View>
      )}

      <View style={s.investedCard}>
        <Text style={s.investedLabel}>INVESTIDO ATÉ O MOMENTO</Text>
        {investedSoFar === null ? (
          <ActivityIndicator size="small" color={theme.gold} style={{ marginTop: 6 }} />
        ) : (
          <>
            <Text style={s.investedValue}>{fCHF(investedSoFar, 0)}</Text>
            <Text style={s.investedHint}>
              Soma de todas as transações na categoria Investimento — já incluído no patrimônio inicial da simulação abaixo.
            </Text>
          </>
        )}
      </View>

      <View style={s.formCard}>
        <Field label="Outros ativos (CHF)" value={otherAssets} onChangeText={setOtherAssets} />
        <View style={s.totalRow}>
          <Text style={s.totalLabel}>Patrimônio inicial total</Text>
          <Text style={s.totalValue}>{fCHF(effectiveStartingValue, 0)}</Text>
        </View>
        <Field label="Aporte mensal (CHF)" value={monthlyContribution} onChangeText={setMonthlyContribution} />
        <Field label="Rentabilidade anual (%)" value={annualRate} onChangeText={setAnnualRate} />
        <Field label="Período (anos)" value={years} onChangeText={setYears} />
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
  title: { fontSize: 28, fontWeight: '800', color: theme.white, letterSpacing: -0.5 },
  subtitle: { fontSize: 14, color: theme.textSec, marginTop: 2 },
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
  totalRow: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    backgroundColor: theme.goldSoft, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 10,
  },
  totalLabel: { fontSize: 12, color: theme.textSec, fontWeight: '600' },
  totalValue: { fontSize: 14, color: theme.gold, fontWeight: '800' },
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
  monthlyNote: { fontSize: 11, color: theme.textSec, marginHorizontal: 16, marginBottom: 8 },
  chartBox: {
    marginHorizontal: 16, backgroundColor: theme.white, borderRadius: 14,
    padding: 16,
  },
});
FILEEOF

mkdir -p "$(dirname "app/(app)/adicionar.tsx")"
cat > "app/(app)/adicionar.tsx" << 'FILEEOF'
import React, { useState, useMemo } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TextInput,
  TouchableOpacity, KeyboardAvoidingView, Platform, Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';
import { useTransactions } from '../../src/hooks/useTransactions';
import { useCategories } from '../../src/hooks/useBudget';
import { theme } from '../../src/theme';
import { DatePickerField } from '../../src/components/DatePickerField';

const now = new Date();

function todayISO(): string {
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

export default function AdicionarScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { user } = useAuth();
  const userId = user!.id;

  const { categories } = useCategories(userId);
  const { addTransaction } = useTransactions({
    userId, year: now.getFullYear(), month: now.getMonth(),
  });

  const [type, setType] = useState<'expense' | 'income'>('expense');
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState('');
  const [catId, setCatId] = useState<string | null>(null);
  const [date, setDate] = useState(todayISO());
  const [saving, setSaving] = useState(false);

  const filteredCategories = useMemo(
    () => categories.filter(c => c.type === type),
    [categories, type]
  );

  const canSave = description.trim().length > 0 && parseFloat(amount.replace(',', '.')) > 0 && catId;

  const handleSave = async () => {
    if (!canSave) return;
    setSaving(true);
    const result = await addTransaction({
      description: description.trim(),
      amount: parseFloat(amount.replace(',', '.')),
      cat_id: catId!,
      type,
      date,
      notes: null,
    });
    setSaving(false);

    if (result.ok) {
      router.back();
    } else {
      Alert.alert('Erro ao salvar', result.error ?? 'Não foi possível salvar a transação. Tente novamente.');
    }
  };

  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView
        style={s.scroll}
        contentContainerStyle={{ padding: 20, paddingTop: insets.top + 16, paddingBottom: 60 }}
      >
        <View style={s.headerRow}>
          <Text style={s.title}>Nova transação</Text>
          <TouchableOpacity onPress={() => router.back()}>
            <Text style={s.close}>Fechar</Text>
          </TouchableOpacity>
        </View>

        <View style={s.typeToggle}>
          <TouchableOpacity
            style={[s.typeBtn, type === 'expense' && s.typeBtnActiveExpense]}
            onPress={() => { setType('expense'); setCatId(null); }}
          >
            <Text style={[s.typeBtnText, type === 'expense' && s.typeBtnTextActive]}>Despesa</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[s.typeBtn, type === 'income' && s.typeBtnActiveIncome]}
            onPress={() => { setType('income'); setCatId(null); }}
          >
            <Text style={[s.typeBtnText, type === 'income' && s.typeBtnTextActive]}>Receita</Text>
          </TouchableOpacity>
        </View>

        <Text style={s.label}>Descrição</Text>
        <TextInput
          style={s.input}
          value={description}
          onChangeText={setDescription}
          placeholder="Ex: Supermercado"
          placeholderTextColor={theme.textTer}
        />

        <Text style={s.label}>Valor (CHF)</Text>
        <TextInput
          style={s.input}
          value={amount}
          onChangeText={setAmount}
          placeholder="0.00"
          placeholderTextColor={theme.textTer}
          keyboardType="decimal-pad"
        />

        <Text style={s.label}>Data</Text>
        <DatePickerField value={date} onChange={setDate} />

        <Text style={s.label}>Categoria</Text>
        <View style={s.catGrid}>
          {filteredCategories.map(cat => (
            <TouchableOpacity
              key={cat.id}
              style={[
                s.catChip,
                catId === cat.slug && s.catChipActive,
              ]}
              onPress={() => setCatId(cat.slug)}
            >
              <Text style={{ fontSize: 16 }}>{cat.icon}</Text>
              <Text style={[s.catChipLabel, catId === cat.slug && s.catChipLabelActive]} numberOfLines={1}>
                {cat.label}
              </Text>
            </TouchableOpacity>
          ))}
          {filteredCategories.length === 0 && (
            <Text style={s.emptyText}>Nenhuma categoria de {type === 'expense' ? 'despesa' : 'receita'} cadastrada.</Text>
          )}
        </View>

        <TouchableOpacity
          style={[s.saveBtn, !canSave && { opacity: 0.4 }]}
          onPress={handleSave}
          disabled={!canSave || saving}
        >
          <Text style={s.saveBtnText}>{saving ? 'Salvando…' : 'Salvar transação'}</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const s = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: theme.bg },
  headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 },
  title: { fontSize: 20, fontWeight: '800', color: theme.white, letterSpacing: -0.4 },
  close: { fontSize: 14, color: theme.gold, fontWeight: '600' },
  typeToggle: { flexDirection: 'row', gap: 8, marginBottom: 20 },
  typeBtn: {
    flex: 1, paddingVertical: 12, borderRadius: 10, alignItems: 'center',
    backgroundColor: theme.surface, borderWidth: 1, borderColor: theme.border,
  },
  typeBtnActiveExpense: { backgroundColor: 'rgba(248,113,113,0.15)', borderColor: theme.expense },
  typeBtnActiveIncome: { backgroundColor: 'rgba(74,222,128,0.15)', borderColor: theme.income },
  typeBtnText: { fontSize: 14, fontWeight: '700', color: theme.textSec },
  typeBtnTextActive: { color: theme.white },
  label: { fontSize: 12, fontWeight: '600', color: theme.textSec, marginBottom: 6, marginTop: 14 },
  input: {
    borderWidth: 1, borderColor: theme.border, borderRadius: 10,
    paddingHorizontal: 14, paddingVertical: 12, fontSize: 15,
    color: theme.inputText, backgroundColor: theme.inputBg,
  },
  catGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 4 },
  catChip: {
    flexDirection: 'row', alignItems: 'center', gap: 6,
    paddingHorizontal: 12, paddingVertical: 9, borderRadius: 10,
    borderWidth: 1, borderColor: theme.border, backgroundColor: theme.surface, maxWidth: 160,
  },
  catChipActive: { borderColor: theme.gold, backgroundColor: theme.goldSoft },
  catChipLabel: { fontSize: 13, fontWeight: '600', color: theme.textSec },
  catChipLabelActive: { color: theme.white },
  emptyText: { fontSize: 13, color: theme.textSec },
  saveBtn: {
    marginTop: 28, backgroundColor: theme.gold, borderRadius: 12,
    paddingVertical: 15, alignItems: 'center',
  },
  saveBtnText: { color: theme.bg, fontSize: 15, fontWeight: '700' },
});
FILEEOF

npx tsc --noEmit
echo "TypeScript OK. Fazendo commit..."
git add -A
git commit -m "Redesign: dark navy + gold visual identity across all screens"
git push
echo "Pronto! Recarrega o app (tecla r) pra ver o novo visual."
