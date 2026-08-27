import React from 'react';
import { View } from 'react-native';

interface IconProps {
  size?: number;
  color?: string;
  strokeWidth?: number;
}

/** Draws a straight line between two points using the same center-rotation
 *  technique as LineChart, which works reliably across RN versions. */
function Segment({
  x1, y1, x2, y2, color, thickness,
}: { x1: number; y1: number; x2: number; y2: number; color: string; thickness: number }) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const dist = Math.sqrt(dx * dx + dy * dy);
  const angle = Math.atan2(dy, dx) * (180 / Math.PI);
  const midX = (x1 + x2) / 2;
  const midY = (y1 + y2) / 2;
  return (
    <View
      style={{
        position: 'absolute',
        left: midX - dist / 2,
        top: midY - thickness / 2,
        width: dist,
        height: thickness,
        backgroundColor: color,
        borderRadius: thickness / 2,
        transform: [{ rotate: `${angle}deg` }],
      }}
    />
  );
}

export function BellIcon({ size = 20, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{ width: size, height: size, alignItems: 'center' }}>
      <View
        style={{
          width: size * 0.62,
          height: size * 0.5,
          borderWidth: strokeWidth,
          borderColor: color,
          borderBottomWidth: 0,
          borderTopLeftRadius: size * 0.31,
          borderTopRightRadius: size * 0.31,
        }}
      />
      <View style={{ width: size * 0.8, height: strokeWidth, backgroundColor: color, borderRadius: 1 }} />
      <View
        style={{
          width: size * 0.16,
          height: size * 0.16,
          borderRadius: size * 0.08,
          backgroundColor: color,
          marginTop: size * 0.06,
        }}
      />
    </View>
  );
}

export function CalendarIcon({ size = 20, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{ width: size, height: size }}>
      <View
        style={{
          width: size,
          height: size * 0.85,
          marginTop: size * 0.15,
          borderWidth: strokeWidth,
          borderColor: color,
          borderRadius: 3,
        }}
      >
        <View style={{ height: size * 0.22, borderBottomWidth: strokeWidth, borderColor: color }} />
      </View>
      <View style={{ position: 'absolute', top: 0, left: size * 0.22, width: strokeWidth, height: size * 0.28, backgroundColor: color }} />
      <View style={{ position: 'absolute', top: 0, right: size * 0.22, width: strokeWidth, height: size * 0.28, backgroundColor: color }} />
    </View>
  );
}

export function HomeIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <Segment x1={w * 0.08} y1={h * 0.5} x2={w * 0.5} y2={h * 0.08} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.5} y1={h * 0.08} x2={w * 0.92} y2={h * 0.5} color={color} thickness={strokeWidth} />
      <View
        style={{
          position: 'absolute', left: w * 0.2, top: h * 0.42, width: w * 0.6, height: h * 0.5,
          borderWidth: strokeWidth, borderColor: color, borderTopWidth: 0,
        }}
      />
    </View>
  );
}

export function BarChartIcon({ size = 22, color = '#FFFFFF' }: IconProps) {
  return (
    <View style={{ width: size, height: size, flexDirection: 'row', alignItems: 'flex-end', gap: size * 0.12 }}>
      <View style={{ width: size * 0.2, height: size * 0.45, backgroundColor: color, borderRadius: 1 }} />
      <View style={{ width: size * 0.2, height: size * 0.7, backgroundColor: color, borderRadius: 1 }} />
      <View style={{ width: size * 0.2, height: size * 0.95, backgroundColor: color, borderRadius: 1 }} />
    </View>
  );
}

export function TargetIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View
      style={{
        width: size, height: size, borderRadius: size / 2,
        borderWidth: strokeWidth, borderColor: color,
        alignItems: 'center', justifyContent: 'center',
      }}
    >
      <View
        style={{
          width: size * 0.6, height: size * 0.6, borderRadius: size * 0.3,
          borderWidth: strokeWidth, borderColor: color,
          alignItems: 'center', justifyContent: 'center',
        }}
      >
        <View style={{ width: size * 0.24, height: size * 0.24, borderRadius: size * 0.12, backgroundColor: color }} />
      </View>
    </View>
  );
}

export function TrendingUpIcon({ size = 22, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size;
  const p1 = { x: w * 0.06, y: h * 0.78 };
  const p2 = { x: w * 0.4, y: h * 0.46 };
  const p3 = { x: w * 0.62, y: h * 0.62 };
  const p4 = { x: w * 0.95, y: h * 0.18 };
  return (
    <View style={{ width: w, height: h }}>
      <Segment x1={p1.x} y1={p1.y} x2={p2.x} y2={p2.y} color={color} thickness={strokeWidth} />
      <Segment x1={p2.x} y1={p2.y} x2={p3.x} y2={p3.y} color={color} thickness={strokeWidth} />
      <Segment x1={p3.x} y1={p3.y} x2={p4.x} y2={p4.y} color={color} thickness={strokeWidth} />
      {/* arrow head at the top-right end */}
      <Segment x1={p4.x} y1={p4.y} x2={p4.x - w * 0.22} y2={p4.y} color={color} thickness={strokeWidth} />
      <Segment x1={p4.x} y1={p4.y} x2={p4.x} y2={p4.y + h * 0.22} color={color} thickness={strokeWidth} />
    </View>
  );
}

export function PlusIcon({ size = 24, color = '#FFFFFF', strokeWidth = 2.2 }: IconProps) {
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ position: 'absolute', width: size * 0.7, height: strokeWidth, backgroundColor: color, borderRadius: 2 }} />
      <View style={{ position: 'absolute', width: strokeWidth, height: size * 0.7, backgroundColor: color, borderRadius: 2 }} />
    </View>
  );
}

// ─── Category icons ────────────────────────────────────────────────────────────

export function CartIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{
        position: 'absolute', left: w * 0.18, top: h * 0.28, width: w * 0.68, height: h * 0.4,
        borderWidth: strokeWidth, borderColor: color, borderTopWidth: 0,
      }} />
      <Segment x1={w * 0.1} y1={h * 0.15} x2={w * 0.22} y2={h * 0.15} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.22} y1={h * 0.15} x2={w * 0.32} y2={h * 0.68} color={color} thickness={strokeWidth} />
      <View style={{ position: 'absolute', left: w * 0.28, top: h * 0.82, width: w * 0.12, height: w * 0.12, borderRadius: w * 0.06, backgroundColor: color }} />
      <View style={{ position: 'absolute', left: w * 0.62, top: h * 0.82, width: w * 0.12, height: w * 0.12, borderRadius: w * 0.06, backgroundColor: color }} />
    </View>
  );
}

export function CarIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{
        position: 'absolute', left: w * 0.06, top: h * 0.32, width: w * 0.88, height: h * 0.3,
        borderWidth: strokeWidth, borderColor: color, borderRadius: 4,
      }} />
      <Segment x1={w * 0.22} y1={h * 0.32} x2={w * 0.34} y2={h * 0.12} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.34} y1={h * 0.12} x2={w * 0.66} y2={h * 0.12} color={color} thickness={strokeWidth} />
      <Segment x1={w * 0.66} y1={h * 0.12} x2={w * 0.78} y2={h * 0.32} color={color} thickness={strokeWidth} />
      <View style={{ position: 'absolute', left: w * 0.14, top: h * 0.66, width: w * 0.18, height: w * 0.18, borderRadius: w * 0.09, borderWidth: strokeWidth, borderColor: color }} />
      <View style={{ position: 'absolute', left: w * 0.68, top: h * 0.66, width: w * 0.18, height: w * 0.18, borderRadius: w * 0.09, borderWidth: strokeWidth, borderColor: color }} />
    </View>
  );
}

export function CrossIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{ width: size, height: size, borderRadius: size / 2, borderWidth: strokeWidth, borderColor: color, alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ position: 'absolute', width: size * 0.42, height: strokeWidth, backgroundColor: color }} />
      <View style={{ position: 'absolute', width: strokeWidth, height: size * 0.42, backgroundColor: color }} />
    </View>
  );
}

export function PhoneIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{
      width: size * 0.6, height: size, borderWidth: strokeWidth, borderColor: color, borderRadius: 4,
      alignItems: 'center', justifyContent: 'flex-end', paddingBottom: 2,
    }}>
      <View style={{ width: size * 0.16, height: strokeWidth, backgroundColor: color, borderRadius: 1 }} />
    </View>
  );
}

export function UtensilsIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h, flexDirection: 'row', justifyContent: 'space-between' }}>
      <View style={{ width: strokeWidth, height: h * 0.85, backgroundColor: color, borderRadius: 1 }} />
      <View style={{ width: strokeWidth, height: h * 0.85, backgroundColor: color, borderRadius: 1, transform: [{ rotate: '18deg' }] }} />
    </View>
  );
}

export function BagIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{
        position: 'absolute', left: w * 0.12, top: h * 0.32, width: w * 0.76, height: h * 0.58,
        borderWidth: strokeWidth, borderColor: color, borderRadius: 3,
      }} />
      <View style={{
        position: 'absolute', left: w * 0.3, top: h * 0.1, width: w * 0.4, height: h * 0.3,
        borderWidth: strokeWidth, borderColor: color, borderBottomWidth: 0,
        borderTopLeftRadius: w * 0.2, borderTopRightRadius: w * 0.2,
      }} />
    </View>
  );
}

export function SparkleIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  const w = size, h = size, cx = w / 2, cy = h / 2;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{ position: 'absolute', left: 0, top: cy - strokeWidth / 2, width: w, height: strokeWidth, backgroundColor: color, transform: [{ rotate: '0deg' }] }} />
      <View style={{ position: 'absolute', left: cx - strokeWidth / 2, top: 0, width: strokeWidth, height: h, backgroundColor: color }} />
      <View style={{
        position: 'absolute', left: cx - (w * 0.7) / 2, top: cy - strokeWidth / 2, width: w * 0.7, height: strokeWidth,
        backgroundColor: color, transform: [{ rotate: '45deg' }],
      }} />
      <View style={{
        position: 'absolute', left: cx - (w * 0.7) / 2, top: cy - strokeWidth / 2, width: w * 0.7, height: strokeWidth,
        backgroundColor: color, transform: [{ rotate: '-45deg' }],
      }} />
    </View>
  );
}

export function BookIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h, flexDirection: 'row' }}>
      <View style={{
        width: w * 0.48, height: h * 0.78, marginTop: h * 0.1,
        borderWidth: strokeWidth, borderColor: color, borderRightWidth: 0,
        borderTopLeftRadius: 3, borderBottomLeftRadius: 3,
      }} />
      <View style={{
        width: w * 0.48, height: h * 0.78, marginTop: h * 0.1,
        borderWidth: strokeWidth, borderColor: color,
        borderTopRightRadius: 3, borderBottomRightRadius: 3,
      }} />
    </View>
  );
}

export function BoxIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  return (
    <View style={{ width: size, height: size, borderWidth: strokeWidth, borderColor: color, borderRadius: 4 }}>
      <View style={{ height: size * 0.32, borderBottomWidth: strokeWidth, borderColor: color }} />
    </View>
  );
}

export function BriefcaseIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h }}>
      <View style={{
        position: 'absolute', left: w * 0.06, top: h * 0.32, width: w * 0.88, height: h * 0.58,
        borderWidth: strokeWidth, borderColor: color, borderRadius: 3,
      }} />
      <View style={{
        position: 'absolute', left: w * 0.32, top: h * 0.12, width: w * 0.36, height: h * 0.24,
        borderWidth: strokeWidth, borderColor: color, borderBottomWidth: 0, borderRadius: 2,
      }} />
      <View style={{ position: 'absolute', left: 0, top: h * 0.56, width: w, height: strokeWidth, backgroundColor: color }} />
    </View>
  );
}

export function LaptopIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.5 }: IconProps) {
  const w = size, h = size;
  return (
    <View style={{ width: w, height: h, alignItems: 'center' }}>
      <View style={{
        width: w * 0.78, height: h * 0.52,
        borderWidth: strokeWidth, borderColor: color, borderRadius: 3,
      }} />
      <View style={{ width: w, height: strokeWidth * 1.4, backgroundColor: color, marginTop: 3, borderRadius: 2 }} />
    </View>
  );
}

export function CoinIcon({ size = 18, color = '#FFFFFF', strokeWidth = 1.6 }: IconProps) {
  return (
    <View style={{
      width: size, height: size, borderRadius: size / 2, borderWidth: strokeWidth, borderColor: color,
      alignItems: 'center', justifyContent: 'center',
    }}>
      <View style={{ width: size * 0.4, height: strokeWidth, backgroundColor: color }} />
    </View>
  );
}
