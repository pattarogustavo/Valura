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
    paddingHorizontal: 14, paddingVertical: 12,
  },
  fieldText: { fontSize: 15, color: theme.text },
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
