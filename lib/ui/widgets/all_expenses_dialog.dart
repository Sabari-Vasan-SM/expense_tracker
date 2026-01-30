import 'package:flutter/material.dart';
import '../../models/expense.dart';
import 'expense_card.dart';

/// Dialog showing all expenses with date filtering
class AllExpensesDialog extends StatefulWidget {
  final List<Expense> expenses;

  const AllExpensesDialog({super.key, required this.expenses});

  @override
  State<AllExpensesDialog> createState() => _AllExpensesDialogState();
}

class _AllExpensesDialogState extends State<AllExpensesDialog> {
  late List<Expense> _filteredExpenses;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _filteredExpenses = widget.expenses;
  }

  void _deleteExpense(Expense expense) {
    setState(() {
      _filteredExpenses.removeWhere((e) => e == expense);
      widget.expenses.removeWhere((e) => e == expense);
    });
    if (_filteredExpenses.isEmpty) {
      Navigator.pop(context);
    }
  }

  void _applyDateFilter() async {
    final start = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (start != null) {
      final end = await showDatePicker(
        context: context,
        initialDate: _endDate ?? DateTime.now(),
        firstDate: start,
        lastDate: DateTime.now(),
      );

      if (end != null) {
        setState(() {
          _startDate = start;
          _endDate = end;
          _filteredExpenses = widget.expenses.where((expense) {
            return expense.date.isAfter(_startDate!) &&
                expense.date.isBefore(_endDate!.add(const Duration(days: 1)));
          }).toList();
        });
      }
    }
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _filteredExpenses = widget.expenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _filteredExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'All Expenses',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter and Summary Section
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _applyDateFilter,
                        icon: Icon(
                          Icons.calendar_today_rounded,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        tooltip: 'Filter by Date',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Clear Filter Button
                    if (_startDate != null && _endDate != null)
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _clearFilter,
                          icon: Icon(
                            Icons.clear_rounded,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          tooltip: 'Clear Filter',
                        ),
                      ),
                  ],
                ),
                // Date Range Display
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Expense List
          if (_filteredExpenses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 48,
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: List.generate(
                      _filteredExpenses.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ExpenseCard(
                          expense: _filteredExpenses[index],
                          onTap: () {},
                          onDelete: () =>
                              _deleteExpense(_filteredExpenses[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
