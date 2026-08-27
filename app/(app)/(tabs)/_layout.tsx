import React from 'react';
import { Tabs, useRouter } from 'expo-router';
import { View, TouchableOpacity, Platform, StyleSheet } from 'react-native';
import { theme } from '../../../src/theme';
import { HomeIcon, BarChartIcon, TargetIcon, TrendingUpIcon, PlusIcon } from '../../../src/components/Icons';

export default function TabsLayout() {
  const router = useRouter();

  return (
    <View style={{ flex: 1 }}>
      <Tabs
        screenOptions={{
          headerShown: false,
          tabBarActiveTintColor: theme.gold,
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
            tabBarIcon: ({ color }) => <HomeIcon size={22} color={color} />,
          }}
        />
        <Tabs.Screen
          name="analise"
          options={{
            title: 'Análise',
            tabBarIcon: ({ color }) => <BarChartIcon size={22} color={color} />,
          }}
        />
        <Tabs.Screen
          name="orcamento"
          options={{
            title: 'Orçamento',
            tabBarIcon: ({ color }) => <TargetIcon size={22} color={color} />,
          }}
        />
        <Tabs.Screen
          name="projecoes"
          options={{
            title: 'Projeções',
            tabBarIcon: ({ color }) => <TrendingUpIcon size={22} color={color} />,
          }}
        />
      </Tabs>

      {/* Floating action button — opens the "add transaction" modal */}
      <TouchableOpacity
        style={styles.fab}
        activeOpacity={0.85}
        onPress={() => router.push('/(app)/adicionar')}
      >
        <PlusIcon size={24} color={theme.bg} strokeWidth={2.4} />
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
    backgroundColor: theme.gold,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 8,
    elevation: 6,
  },
});
