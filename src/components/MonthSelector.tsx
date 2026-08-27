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
