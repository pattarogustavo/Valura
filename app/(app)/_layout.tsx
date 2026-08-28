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
