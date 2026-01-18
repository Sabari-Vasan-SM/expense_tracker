import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../services/expense_storage_service.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_bottom_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/expense_chart.dart';

/// Main home screen with expense list and summary
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ExpenseStorageService _storageService = ExpenseStorageService();
  List<Expense> _expenses = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  // Animation controllers for list items
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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
    });
  }

  Future<void> _addExpense(
    String title,
    double amount,
    ExpenseCategory category,
    DateTime date,
  ) async {
    final expense = await _storageService.addExpense(
      title: title,
      amount: amount,
      category: category,
      date: date,
    );

    setState(() {
      _expenses.insert(0, expense);
    });

    _listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _updateExpense(
    Expense expense,
    String title,
    double amount,
    ExpenseCategory category,
    DateTime date,
  ) async {
    final updatedExpense = expense.copyWith(
      title: title,
      amount: amount,
      category: category,
      date: date,
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

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ExpenseBottomSheet(onSave: _addExpense),
    );
  }

  void _showEditExpenseSheet(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ExpenseBottomSheet(
        expense: expense,
        onSave: (title, amount, category, date) {
          _updateExpense(expense, title, amount, category, date);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(theme),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddExpenseSheet,
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
    if (_expenses.isEmpty) {
      return EmptyState(
        title: 'No expenses yet',
        subtitle: 'Start tracking your expenses by adding your first one.',
        onAction: _showAddExpenseSheet,
        actionLabel: 'Add Expense',
      );
    }

    return CustomScrollView(
      key: const ValueKey('expenses'),
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
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
        // Summary cards
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'This Month',
                    amount: _storageService.getCurrentMonthTotal(),
                    icon: Icons.calendar_month_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Section title
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
        // Expense list
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
                  onTap: () => _showEditExpenseSheet(expense),
                  onDelete: () => _showDeleteConfirmation(index),
                ),
              );
            },
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'This Month',
                    amount: _storageService.getCurrentMonthTotal(),
                    icon: Icons.calendar_month_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: ExpenseChart(
              weeklyData: weeklyData,
              categoryData: categoryData,
            ),
          ),
        ),
        // Category breakdown
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
                                Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category.displayName,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  '\$${amount.toStringAsFixed(2)}',
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
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
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
}
