import React from 'react';
import {
  HomeIcon, CartIcon, CarIcon, CrossIcon, PhoneIcon, UtensilsIcon,
  BagIcon, SparkleIcon, BookIcon, TrendingUpIcon, BoxIcon,
  BriefcaseIcon, LaptopIcon, CoinIcon,
} from './Icons';

interface CategoryIconProps {
  slug: string;
  size?: number;
  color?: string;
}

const ICON_BY_SLUG: Record<string, React.ComponentType<{ size?: number; color?: string }>> = {
  housing:    HomeIcon,
  food:       CartIcon,
  transport:  CarIcon,
  health:     CrossIcon,
  subs:       PhoneIcon,
  restaurant: UtensilsIcon,
  shopping:   BagIcon,
  leisure:    SparkleIcon,
  education:  BookIcon,
  investment: TrendingUpIcon,
  other:      BoxIcon,
  salary:     BriefcaseIcon,
  freelance:  LaptopIcon,
  other_in:   CoinIcon,
};

/** Renders the line-icon matching a category's slug, falling back to a
 *  generic box icon for any custom/unrecognized category. */
export function CategoryIcon({ slug, size = 18, color = '#FFFFFF' }: CategoryIconProps) {
  const Icon = ICON_BY_SLUG[slug] ?? BoxIcon;
  return <Icon size={size} color={color} />;
}
