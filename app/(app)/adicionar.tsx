import React, { useState, useMemo } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TextInput,
  TouchableOpacity, KeyboardAvoidingView, Platform, Alert,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { useAuth } from '../../src/context/AuthContext';
import { useTransactions } from '../../src/hooks/useTransactions';
import { useCategories } from '../../src/hooks/useBudget';
import { theme } from '../../src/theme';
import { DatePickerField } from '../../src/components/DatePickerField';
import { CategoryIcon } from '../../src/components/CategoryIcon';
import type { Transaction } from '../../src/types';

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

  // If a transaction was passed in (tapping a row to edit), we're in edit mode.
  const { transaction: transactionParam } = useLocalSearchParams<{ transaction?: string }>();
  const editingTx: Transaction | null = useMemo(() => {
    if (!transactionParam) return null;
    try { return JSON.parse(transactionParam) as Transaction; } catch { return null; }
  }, [transactionParam]);
  const isEditing = !!editingTx;

  const { categories } = useCategories(userId);
  const { addTransaction, updateTransaction, deleteTransaction } = useTransactions({
    userId, year: now.getFullYear(), month: now.getMonth(),
  });

  const [type, setType] = useState<'expense' | 'income'>(editingTx?.type ?? 'expense');
  const [description, setDescription] = useState(editingTx?.description ?? '');
  const [amount, setAmount] = useState(editingTx ? String(editingTx.amount) : '');
  const [catId, setCatId] = useState<string | null>(editingTx?.cat_id ?? null);
  const [date, setDate] = useState(editingTx?.date ?? todayISO());
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);

  const filteredCategories = useMemo(
    () => categories.filter(c => c.type === type),
    [categories, type]
  );

  const canSave = description.trim().length > 0 && parseFloat(amount.replace(',', '.')) > 0 && catId;

  const handleSave = async () => {
    if (!canSave) return;
    setSaving(true);

    const payload = {
      description: description.trim(),
      amount: parseFloat(amount.replace(',', '.')),
      cat_id: catId!,
      type,
      date,
      notes: null,
    };

    const result = isEditing
      ? await updateTransaction(editingTx!.id, payload)
      : await addTransaction(payload);

    setSaving(false);

    if (result.ok) {
      router.back();
    } else {
      Alert.alert('Erro ao salvar', result.error ?? 'Não foi possível salvar a transação. Tente novamente.');
    }
  };

  const handleDelete = () => {
    if (!editingTx) return;
    Alert.alert(
      'Apagar transação',
      `Tem certeza que deseja apagar "${editingTx.description}"?`,
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Apagar',
          style: 'destructive',
          onPress: async () => {
            setDeleting(true);
            const result = await deleteTransaction(editingTx.id);
            setDeleting(false);
            if (result.ok) {
              router.back();
            } else {
              Alert.alert('Erro', result.error ?? 'Não foi possível apagar a transação.');
            }
          },
        },
      ]
    );
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
          <Text style={s.title}>{isEditing ? 'Editar transação' : 'Nova transação'}</Text>
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
          <Text style={s.saveBtnText}>
            {saving ? 'Salvando…' : isEditing ? 'Salvar alterações' : 'Salvar transação'}
          </Text>
        </TouchableOpacity>

        {isEditing && (
          <TouchableOpacity
            style={[s.deleteBtn, deleting && { opacity: 0.5 }]}
            onPress={handleDelete}
            disabled={deleting}
          >
            <Text style={s.deleteBtnText}>{deleting ? 'Apagando…' : 'Apagar transação'}</Text>
          </TouchableOpacity>
        )}
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
  deleteBtn: {
    marginTop: 12, borderRadius: 12, paddingVertical: 15, alignItems: 'center',
    borderWidth: 1, borderColor: theme.danger,
  },
  deleteBtnText: { color: theme.danger, fontSize: 15, fontWeight: '700' },
});
