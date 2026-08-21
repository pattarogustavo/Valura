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
  formatValue?: (v: number) => string;
  /** If true, the chart scrolls horizontally instead of squeezing all points in. */
  scrollable?: boolean;
  minPointSpacing?: number;
}

const DOT_RADIUS = 4;
const LINE_THICKNESS = 2;

export function LineChart({
  data,
  height = 180,
  color = theme.brand,
  formatValue,
  scrollable = false,
  minPointSpacing = 44,
}: LineChartProps) {
  const [measuredWidth, setMeasuredWidth] = useState(0);

  const onLayout = (e: LayoutChangeEvent) => {
    setMeasuredWidth(e.nativeEvent.layout.width);
  };

  if (data.length === 0) return null;

  const contentWidth = scrollable
    ? Math.max(measuredWidth, data.length * minPointSpacing)
    : measuredWidth;

  const chartH = height;
  const padding = 20;

  const values = data.map(d => d.value);
  const maxVal = Math.max(...values, 0);
  const minVal = Math.min(...values, 0);
  const range = maxVal - minVal || 1;

  const points = data.map((d, i) => {
    const x = data.length === 1
      ? contentWidth / 2
      : padding + (i / (data.length - 1)) * (contentWidth - padding * 2);
    const y = chartH - padding - ((d.value - minVal) / range) * (chartH - padding * 2);
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

  const chartBody = (
    <View style={{ width: contentWidth || '100%', height: chartH }}>
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
            borderColor: theme.white,
          }}
        />
      ))}
    </View>
  );

  // Show a label under every point, or thin them out if there are too many.
  const labelStep = Math.max(1, Math.ceil(data.length / 8));

  const labelsRow = (
    <View style={{ width: contentWidth || '100%', flexDirection: 'row' }}>
      {points.map((p, i) => (
        <View key={`lbl-${i}`} style={{ position: 'absolute', left: p.x - 20, width: 40, alignItems: 'center' }}>
          {i % labelStep === 0 && (
            <Text style={s.axisLabel} numberOfLines={1}>{p.label}</Text>
          )}
        </View>
      ))}
    </View>
  );

  return (
    <View onLayout={onLayout}>
      {measuredWidth > 0 && (
        scrollable ? (
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            <View>
              {chartBody}
              {labelsRow}
            </View>
          </ScrollView>
        ) : (
          <View>
            {chartBody}
            {labelsRow}
          </View>
        )
      )}
      <View style={s.legendRow}>
        <Text style={s.legendMax}>
          Máx: {formatValue ? formatValue(maxVal) : maxVal.toFixed(0)}
        </Text>
      </View>
    </View>
  );
}

const s = StyleSheet.create({
  axisLabel: { fontSize: 9, color: theme.textTer, marginTop: 4 },
  legendRow: { marginTop: 16, alignItems: 'flex-end' },
  legendMax: { fontSize: 11, color: theme.textTer, fontWeight: '600' },
});
