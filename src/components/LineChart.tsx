import React, { useState } from 'react';
import { View, Text, StyleSheet, LayoutChangeEvent, ScrollView } from 'react-native';
import { theme } from '../theme';

export interface LineChartPoint {
  label: string;
  value: number;
}

interface LineChartProps {
  data: LineChartPoint[];
  height?: number;
  color?: string;
  dotBorderColor?: string;
  formatValue?: (v: number) => string;
  /** If true, the chart scrolls horizontally instead of squeezing all points in. */
  scrollable?: boolean;
  minPointSpacing?: number;
  axisLabelColor?: string;
  gridColor?: string;
}

const DOT_RADIUS = 4;
const LINE_THICKNESS = 2;
const Y_AXIS_WIDTH = 42;

/** Picks a "nice" step size (1, 2, 2.5, 5 × 10^n) for axis gridlines. */
function niceStep(roughStep: number): number {
  if (roughStep <= 0) return 1;
  const exp = Math.floor(Math.log10(roughStep));
  const base = roughStep / Math.pow(10, exp);
  let niceBase: number;
  if (base <= 1) niceBase = 1;
  else if (base <= 2) niceBase = 2;
  else if (base <= 5) niceBase = 5;
  else niceBase = 10;
  return niceBase * Math.pow(10, exp);
}

function formatCompact(v: number): string {
  const abs = Math.abs(v);
  if (abs >= 1000) return `${Math.round(v / 1000)}k`;
  return String(Math.round(v));
}

export function LineChart({
  data,
  height = 180,
  color = theme.gold,
  dotBorderColor = theme.white,
  formatValue,
  scrollable = false,
  minPointSpacing = 44,
  axisLabelColor = theme.textTer,
  gridColor = 'rgba(0,0,0,0.08)',
}: LineChartProps) {
  const [measuredWidth, setMeasuredWidth] = useState(0);

  const onLayout = (e: LayoutChangeEvent) => {
    setMeasuredWidth(e.nativeEvent.layout.width);
  };

  if (data.length === 0) return null;

  const plotAreaWidth = Math.max(0, measuredWidth - Y_AXIS_WIDTH);
  const contentWidth = scrollable
    ? Math.max(plotAreaWidth, data.length * minPointSpacing)
    : plotAreaWidth;

  const chartH = height;
  const padding = 16;

  const values = data.map(d => d.value);
  const rawMax = Math.max(...values, 0);
  const step = niceStep(rawMax / 4);
  const axisMax = Math.ceil(rawMax / step) * step || step;
  const gridValues = [0, 1, 2, 3, 4].map(i => (axisMax / 4) * i).reverse();

  const points = data.map((d, i) => {
    const x = data.length === 1
      ? contentWidth / 2
      : padding + (i / (data.length - 1)) * (contentWidth - padding * 2);
    const y = chartH - padding - (d.value / (axisMax || 1)) * (chartH - padding * 2);
    return { x, y, ...d };
  });

  const segments = points.slice(1).map((p2, i) => {
    const p1 = points[i];
    const dx = p2.x - p1.x;
    const dy = p2.y - p1.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    const angle = Math.atan2(dy, dx) * (180 / Math.PI);
    const midX = (p1.x + p2.x) / 2;
    const midY = (p1.y + p2.y) / 2;
    return {
      key: `seg-${i}`,
      left: midX - dist / 2,
      top: midY - LINE_THICKNESS / 2,
      width: dist,
      angle,
    };
  });

  const labelStep = Math.max(1, Math.ceil(data.length / 8));

  const plot = (
    <View style={{ width: contentWidth || '100%' }}>
      <View style={{ width: contentWidth || '100%', height: chartH }}>
        {/* Gridlines */}
        {gridValues.map((v, i) => {
          const y = chartH - padding - (v / (axisMax || 1)) * (chartH - padding * 2);
          return (
            <View
              key={`grid-${i}`}
              style={{
                position: 'absolute', left: 0, top: y, width: contentWidth,
                height: StyleSheet.hairlineWidth, backgroundColor: gridColor,
              }}
            />
          );
        })}

        {segments.map(seg => (
          <View
            key={seg.key}
            style={{
              position: 'absolute',
              left: seg.left,
              top: seg.top,
              width: seg.width,
              height: LINE_THICKNESS,
              backgroundColor: color,
              borderRadius: LINE_THICKNESS / 2,
              transform: [{ rotate: `${seg.angle}deg` }],
            }}
          />
        ))}
        {points.map((p, i) => (
          <View
            key={`dot-${i}`}
            style={{
              position: 'absolute',
              left: p.x - DOT_RADIUS,
              top: p.y - DOT_RADIUS,
              width: DOT_RADIUS * 2,
              height: DOT_RADIUS * 2,
              borderRadius: DOT_RADIUS,
              backgroundColor: color,
              borderWidth: 2,
              borderColor: dotBorderColor,
            }}
          />
        ))}
      </View>

      <View style={{ width: contentWidth || '100%', height: 18 }}>
        {points.map((p, i) => (
          <View key={`lbl-${i}`} style={{ position: 'absolute', left: p.x - 20, width: 40, alignItems: 'center' }}>
            {i % labelStep === 0 && (
              <Text style={[s.axisLabel, { color: axisLabelColor }]} numberOfLines={1}>{p.label}</Text>
            )}
          </View>
        ))}
      </View>
    </View>
  );

  return (
    <View onLayout={onLayout} style={{ flexDirection: 'row' }}>
      {/* Y axis labels */}
      <View style={{ width: Y_AXIS_WIDTH, height: chartH }}>
        {gridValues.map((v, i) => {
          const y = chartH - padding - (v / (axisMax || 1)) * (chartH - padding * 2);
          return (
            <Text
              key={`ylbl-${i}`}
              style={[s.yAxisLabel, { color: axisLabelColor, top: y - 6 }]}
            >
              {formatValue ? formatValue(v) : formatCompact(v)}
            </Text>
          );
        })}
      </View>

      {measuredWidth > 0 && (
        scrollable ? (
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            {plot}
          </ScrollView>
        ) : (
          plot
        )
      )}
    </View>
  );
}

const s = StyleSheet.create({
  axisLabel: { fontSize: 9, marginTop: 4 },
  yAxisLabel: { position: 'absolute', fontSize: 10, fontWeight: '600', right: 8 },
});
