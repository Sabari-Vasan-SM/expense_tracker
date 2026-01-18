import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/expense.dart';

/// Weekly expense chart widget
class ExpenseChart extends StatefulWidget {
  final Map<DateTime, double> weeklyData;
  final Map<ExpenseCategory, double> categoryData;

  const ExpenseChart({
    super.key,
    required this.weeklyData,
    required this.categoryData,
  });

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedChartIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analytics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Weekly'),
                      icon: Icon(Icons.bar_chart_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Category'),
                      icon: Icon(Icons.pie_chart_rounded, size: 18),
                    ),
                  ],
                  selected: {_selectedChartIndex},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedChartIndex = selection.first;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: WidgetStateProperty.all(
                      theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return _selectedChartIndex == 0
                      ? _buildBarChart(theme)
                      : _buildPieChart(theme);
                },
              ),
            ),
            if (_selectedChartIndex == 1) ...[
              const SizedBox(height: 16),
              _buildCategoryLegend(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(ThemeData theme) {
    final weeklyEntries = widget.weeklyData.entries.toList();
    final maxY = weeklyEntries.fold<double>(
      0,
      (max, entry) => entry.value > max ? entry.value : max,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY == 0 ? 100 : maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${rod.toY.toStringAsFixed(2)}',
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= weeklyEntries.length) {
                  return const SizedBox.shrink();
                }
                final date = weeklyEntries[index].key;
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[date.weekday - 1],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${value.toInt()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY == 0 ? 25 : maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(weeklyEntries.length, (index) {
          final entry = weeklyEntries[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value * _animation.value,
                color: theme.colorScheme.primary,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY == 0 ? 100 : maxY * 1.2,
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme) {
    final categoryEntries = widget.categoryData.entries
        .where((e) => e.value > 0)
        .toList();
    final total = categoryEntries.fold<double>(0, (sum, e) => sum + e.value);

    if (categoryEntries.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (event, response) {},
        ),
        sectionsSpace: 3,
        centerSpaceRadius: 50,
        sections: categoryEntries.map((entry) {
          final percentage = (entry.value / total) * 100;
          return PieChartSectionData(
            value: entry.value * _animation.value,
            title: '${percentage.toStringAsFixed(0)}%',
            color: Color(entry.key.colorValue),
            radius: 45,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryLegend(ThemeData theme) {
    final categoryEntries = widget.categoryData.entries
        .where((e) => e.value > 0)
        .toList();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryEntries.map((entry) {
        final color = Color(entry.key.colorValue);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(entry.key.displayName, style: theme.textTheme.bodySmall),
          ],
        );
      }).toList(),
    );
  }
}
