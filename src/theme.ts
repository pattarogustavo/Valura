// ─── SHARED DESIGN TOKENS ───────────────────────────────────────────────────
// Matches the palette already used in app/(app)/index.tsx (Resumo screen).

export const theme = {
  brand:        '#1756F5',
  brandDark:    '#1248C8',
  text:         '#0A1929',
  textSec:      '#3D5168',
  textTer:      '#8097B1',
  border:       '#D8E4F0',
  white:        '#FFFFFF',
  bg:           '#F2F6FA',
  income:       '#00B374',
  expense:      '#E53935',
  good:         '#00E5A0',
  warn:         '#FFCC32',
  danger:       '#FF5252',
};

export const fCHF = (n: number, d = 2) =>
  'CHF ' + Number(n || 0).toLocaleString('pt-PT', { minimumFractionDigits: d, maximumFractionDigits: d });

export const MONTHS_FULL = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];
