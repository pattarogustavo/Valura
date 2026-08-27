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
