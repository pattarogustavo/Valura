// ─── SHARED DESIGN TOKENS — dark navy / gold identity ─────────────────────────

export const theme = {
  bg:           '#0B1220', // page background — deep navy
  surface:      '#151F35', // card background
  surfaceAlt:   '#1B2A47', // slightly lighter surface (highlighted rows)
  border:       'rgba(255,255,255,0.08)',

  gold:         '#C9A15B', // primary accent
  goldDark:     '#A9843F',
  goldSoft:     'rgba(201,161,91,0.15)',

  // Kept for backwards-compat with any code referencing `brand`
  brand:        '#C9A15B',
  brandDark:    '#A9843F',

  text:         '#FFFFFF',
  textSec:      '#94A3B8',
  textTer:      '#5B6B85',

  white:        '#FFFFFF',
  inputBg:      '#F5F7FA',
  inputText:    '#0B1220',

  income:       '#4ADE80',
  expense:      '#F87171',
  good:         '#4ADE80',
  warn:         '#FBBF24',
  danger:       '#F87171',
};

export const fCHF = (n: number, d = 2) =>
  'CHF ' + Number(n || 0).toLocaleString('pt-PT', { minimumFractionDigits: d, maximumFractionDigits: d });

export const MONTHS_FULL = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

export const MONTHS_SHORT = [
  'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
];
