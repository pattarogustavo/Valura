#!/bin/bash
set -e
echo "Aplicando icones de categoria..."
mkdir -p src/components

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

mkdir -p "$(dirname "src/components/CategoryIcon.tsx")"
cat > "src/components/CategoryIcon.tsx" << 'FILEEOF'
import React from 'react';
import {
  HomeIcon, CartIcon, CarIcon, CrossIcon, PhoneIcon, UtensilsIcon,
  BagIcon, SparkleIcon, BookIcon, TrendingUpIcon, BoxIcon,
  BriefcaseIcon, LaptopIcon, CoinIcon,
} from './Icons';

interface CategoryIconProps {
  slug: string;
  size?: number;
  color?: string;
}

const ICON_BY_SLUG: Record<string, React.ComponentType<{ size?: number; color?: string }>> = {
  housing:    HomeIcon,
  food:       CartIcon,
  transport:  CarIcon,
  health:     CrossIcon,
  subs:       PhoneIcon,
  restaurant: UtensilsIcon,
  shopping:   BagIcon,
  leisure:    SparkleIcon,
  education:  BookIcon,
  investment: TrendingUpIcon,
  other:      BoxIcon,
  salary:     BriefcaseIcon,
  freelance:  LaptopIcon,
  other_in:   CoinIcon,
};

/** Renders the line-icon matching a category's slug, falling back to a
 *  generic box icon for any custom/unrecognized category. */
export function CategoryIcon({ slug, size = 18, color = '#FFFFFF' }: CategoryIconProps) {
  const Icon = ICON_BY_SLUG[slug] ?? BoxIcon;
  return <Icon size={size} color={color} />;
}
FILEEOF

mkdir -p "$(dirname "src/components/DatePickerField.tsx")"
cat > "src/components/DatePickerField.tsx" << 'FILEEOF'
import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Modal, Pressable } from 'react-native';
import { theme, MONTHS_FULL } from '../theme';
import { CalendarIcon } from './Icons';

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
        <CalendarIcon size={16} color={theme.textSec} />
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
import { BellIcon, CalendarIcon } from '../../../src/components/Icons';
import { CategoryIcon } from '../../../src/components/CategoryIcon';

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
            <BellIcon size={16} color={theme.gold} />
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
import { CalendarIcon } from '../../../src/components/Icons';

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
            <CalendarIcon size={16} color={theme.gold} />
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
import { CategoryIcon } from '../../../src/components/CategoryIcon';

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
                    <CategoryIcon slug={cat.slug} size={16} color={cat.color} />
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
import { CategoryIcon } from '../../src/components/CategoryIcon';

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
              <CategoryIcon slug={cat.slug} size={16} color={catId === cat.slug ? theme.gold : cat.color} />
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
git commit -m "Replace category emojis with mapped line icons by slug"
git push
echo "Pronto! Recarrega o app (tecla r) pra ver os icones novos."
