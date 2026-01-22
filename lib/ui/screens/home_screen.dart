import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../models/expense.dart';
import '../../services/expense_storage_service.dart';
import '../../services/export_service.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_bottom_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/about_dialog.dart';
import '../widgets/expenses_detail_dialog.dart';
import '../widgets/all_expenses_dialog.dart';

/// Main home screen with expense list and summary
class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ExpenseStorageService _storageService = ExpenseStorageService();
  List<Expense> _expenses = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  // Animation controllers for list items
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      await _storageService.init();
      _loadExpenses();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing storage: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _loadExpenses() {
    setState(() {
      _expenses = _storageService.getAllExpenses();
      _isLoading = false;
      _listKey = GlobalKey<AnimatedListState>();
    });
  }

  Future<void> _addExpense(
    String title,
    double amount,
    ExpenseCategory category,
    DateTime date,
    PaymentMethod paymentMethod,
  ) async {
    await _storageService.addExpense(
      title: title,
      amount: amount,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
    );

    // Reload all expenses to maintain proper date sorting
    _loadExpenses();
  }

  Future<void> _updateExpense(
    Expense expense,
    String title,
    double amount,
    ExpenseCategory category,
    DateTime date,
    PaymentMethod paymentMethod,
  ) async {
    final updatedExpense = expense.copyWith(
      title: title,
      amount: amount,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
    );

    await _storageService.updateExpense(updatedExpense);
    _loadExpenses();
  }

  Future<void> _deleteExpense(int index) async {
    final expense = _expenses[index];

    setState(() {
      _expenses.removeAt(index);
    });

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(expense, animation),
      duration: const Duration(milliseconds: 300),
    );

    await _storageService.deleteExpense(expense.id);
  }

  Widget _buildRemovedItem(Expense expense, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1, 0),
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInCubic)),
      child: FadeTransition(
        opacity: animation,
        child: ExpenseCard(expense: expense, onTap: () {}, onDelete: () {}),
      ),
    );
  }

  void _showExpenseSheet({Expense? expense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return ExpenseBottomSheet(
          expense: expense,
          onSave: (title, amount, category, date, paymentMethod) {
            if (expense == null) {
              _addExpense(title, amount, category, date, paymentMethod);
            } else {
              _updateExpense(
                expense,
                title,
                amount,
                category,
                date,
                paymentMethod,
              );
            }
          },
        );
      },
    );
  }

  void _showExpensesDetail(String title, List<Expense> expenses) {
    final total = _storageService.calculateTotal(expenses);
    showDialog(
      context: context,
      builder: (context) =>
          ExpensesDetailDialog(title: title, expenses: expenses, total: total),
    );
  }

  List<Expense> _getTodayExpenses() {
    final today = DateTime.now();
    return _expenses.where((e) {
      return e.date.year == today.year &&
          e.date.month == today.month &&
          e.date.day == today.day;
    }).toList();
  }

  List<Expense> _getWeekExpenses() {
    return _storageService.getExpensesForCurrentWeek();
  }

  List<Expense> _getMonthExpenses() {
    final now = DateTime.now();
    return _storageService.getExpensesForMonth(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: theme.colorScheme.primary,
                size: 50,
              ),
            )
          : _buildBody(theme),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showExpenseSheet(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Expense'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _selectedIndex == 0
          ? _buildExpensesList(theme)
          : _buildAnalytics(theme),
    );
  }

  Widget _buildExpensesList(ThemeData theme) {
    return CustomScrollView(
      key: const ValueKey('expenses'),
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8),
              child: IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                tooltip: 'More options',
                onPressed: () => _showOptionsMenu(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AboutDeveloperDialog(),
                  );
                },
                icon: Icon(
                  Icons.account_circle_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'About Developer',
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Expenses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          ),
        ),
        if (_expenses.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EmptyState(
                title: 'No expenses yet',
                subtitle:
                    'Start tracking your expenses by adding your first one.',
                onAction: () => _showExpenseSheet(),
                actionLabel: 'Add Expense',
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Today',
                      amount: _storageService.getTodayTotal(),
                      icon: Icons.today_rounded,
                      color: theme.colorScheme.tertiary,
                      onTap: () =>
                          _showExpensesDetail('Today', _getTodayExpenses()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'This Month',
                      amount: _storageService.getCurrentMonthTotal(),
                      icon: Icons.calendar_month_rounded,
                      color: theme.colorScheme.primary,
                      onTap: () => _showExpensesDetail(
                        'This Month',
                        _getMonthExpenses(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverAnimatedList(
              key: _listKey,
              initialItemCount: _expenses.length,
              itemBuilder: (context, index, animation) {
                if (index >= _expenses.length) return const SizedBox.shrink();
                final expense = _expenses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ExpenseCard(
                    expense: expense,
                    animation: animation,
                    onTap: () => _showExpenseSheet(expense: expense),
                    onDelete: () => _showDeleteConfirmation(index),
                  ),
                );
              },
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ],
    );
  }

  Widget _buildAnalytics(ThemeData theme) {
    final now = DateTime.now();
    final weeklyData = _storageService.getWeeklyTotals();
    final categoryData = _storageService.getCategoryTotalsForMonth(
      now.year,
      now.month,
    );

    return CustomScrollView(
      key: const ValueKey('analytics'),
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8),
              child: IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                tooltip: 'More options',
                onPressed: () => _showOptionsMenu(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AboutDeveloperDialog(),
                  );
                },
                icon: Icon(
                  Icons.account_circle_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'About Developer',
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Analytics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'This Week',
                    amount: _storageService.calculateTotal(
                      _storageService.getExpensesForCurrentWeek(),
                    ),
                    icon: Icons.date_range_rounded,
                    color: theme.colorScheme.secondary,
                    onTap: () =>
                        _showExpensesDetail('This Week', _getWeekExpenses()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'This Month',
                    amount: _storageService.getCurrentMonthTotal(),
                    icon: Icons.calendar_month_rounded,
                    color: theme.colorScheme.primary,
                    onTap: () =>
                        _showExpensesDetail('This Month', _getMonthExpenses()),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Compact trend tile
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTrendTile(theme, weeklyData),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(top: 12)),
        // Category breakdown first
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...ExpenseCategory.values.map((category) {
                      final amount = categoryData[category] ?? 0;
                      final total = categoryData.values.fold<double>(
                        0,
                        (sum, val) => sum + val,
                      );
                      final percentage = total > 0 ? (amount / total) : 0.0;
                      final color = Color(category.colorValue);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  category.iconData,
                                  size: 24,
                                  color: Color(category.colorValue),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category.displayName,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  '₹${amount.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: percentage),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: color.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation(color),
                                  borderRadius: BorderRadius.circular(4),
                                  minHeight: 8,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    // View All Expenses Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AllExpensesDialog(expenses: _expenses),
                          );
                        },
                        icon: const Icon(Icons.list_rounded),
                        label: const Text('View All Expenses'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(top: 12)),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: ExpenseChart(
              weeklyData: weeklyData,
              categoryData: categoryData,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildTrendTile(ThemeData theme, Map<DateTime, double> weeklyData) {
    final entries = weeklyData.entries.toList();
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
    }
    final maxY = entries
        .map((e) => e.value)
        .fold<double>(0, (m, v) => v > m ? v : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Weekly Trend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.show_chart_rounded,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY == 0 ? 25 : maxY / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant.withOpacity(
                          0.3,
                        ),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final date = entries[index].key;
                          final days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              days[date.weekday - 1],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontSize: 10,
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
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.15),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY == 0 ? 100 : maxY * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExpense(index);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Options',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final hasExpenses = _expenses.isNotEmpty;
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.share_rounded),
                          title: const Text('Share'),
                          subtitle: hasExpenses
                              ? null
                              : const Text('Add an expense to enable sharing'),
                          enabled: hasExpenses,
                          onTap: !hasExpenses
                              ? null
                              : () async {
                                  Navigator.pop(context);
                                  await ExportService.shareExpenses(_expenses);
                                },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.download_rounded),
                          title: const Text('Download PDF'),
                          subtitle: hasExpenses
                              ? null
                              : const Text('Add an expense to enable export'),
                          enabled: hasExpenses,
                          onTap: !hasExpenses
                              ? null
                              : () async {
                                  Navigator.pop(context);
                                  final path =
                                      await ExportService.downloadExpensePDF(
                                        _expenses,
                                      );
                                  if (!mounted) return;
                                  final message = path != null
                                      ? 'PDF saved/share sheet opened'
                                      : 'Failed to save PDF';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_6_rounded),
                      const SizedBox(width: 12),
                      const Text('Theme'),
                      const Spacer(),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode, size: 16),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode, size: 16),
                          ),
                        ],
                        selected: {widget.currentThemeMode},
                        onSelectionChanged: (Set<ThemeMode> newSelection) {
                          widget.onThemeChanged(newSelection.first);
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
