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
