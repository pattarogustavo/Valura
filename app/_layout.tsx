import React, { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { ActivityIndicator, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider, useAuth } from '../src/context/AuthContext';
import { PrivacyProvider } from '../src/context/PrivacyContext';
import { theme } from '../src/theme';
import { configureSDK } from '../src/services/subscription.service';

// ─── AUTH GATE ────────────────────────────────────────────────────────────────
function RootNavigator() {
  const { user, loading, initialized } = useAuth();
  const router   = useRouter();
  const segments = useSegments();

  // IMPORTANT: configureSDK() used to run at module load time (before this
  // component ever mounted, before the native bridge/app delegate had
  // necessarily finished setting up). That matched a crash pattern we've
  // hit before with other native modules — calling into native code too
  // early crashes the whole app with no JS-catchable error. Now it only
  // runs once the app has actually mounted, and configureSDK() itself is
  // wrapped in try/catch so a RevenueCat issue (bad key, missing
  // capability, etc.) degrades gracefully instead of crashing.
  useEffect(() => {
    configureSDK();
  }, []);

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
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <AuthProvider>
          <PrivacyProvider>
            <RootNavigator />
          </PrivacyProvider>
        </AuthProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
