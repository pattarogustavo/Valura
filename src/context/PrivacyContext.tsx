import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { fCHF as formatCHF } from '../theme';

const STORAGE_KEY = 'valura:hideValues';
const MASK = 'CHF ••••••';

interface PrivacyContextValue {
  hidden: boolean;
  toggle: () => void;
  /** Same signature as fCHF, but returns a mask when privacy mode is on. */
  formatAmount: (n: number, decimals?: number) => string;
}

const PrivacyContext = createContext<PrivacyContextValue | undefined>(undefined);

export function PrivacyProvider({ children }: { children: React.ReactNode }) {
  const [hidden, setHidden] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY).then(v => {
      if (v === '1') setHidden(true);
    });
  }, []);

  const toggle = useCallback(() => {
    setHidden(prev => {
      const next = !prev;
      AsyncStorage.setItem(STORAGE_KEY, next ? '1' : '0').catch(() => {});
      return next;
    });
  }, []);

  const formatAmount = useCallback(
    (n: number, decimals = 2) => (hidden ? MASK : formatCHF(n, decimals)),
    [hidden]
  );

  return (
    <PrivacyContext.Provider value={{ hidden, toggle, formatAmount }}>
      {children}
    </PrivacyContext.Provider>
  );
}

export function usePrivacy(): PrivacyContextValue {
  const ctx = useContext(PrivacyContext);
  if (!ctx) throw new Error('usePrivacy must be used inside <PrivacyProvider>');
  return ctx;
}
