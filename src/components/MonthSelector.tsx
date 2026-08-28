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
