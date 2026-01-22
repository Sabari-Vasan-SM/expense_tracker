import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

/// Service class for handling local storage with Hive
class ExpenseStorageService {
  static const String _boxName = 'expenses';
  late Box<Expense> _expenseBox;
  final Uuid _uuid = const Uuid();

  /// Initialize Hive and open the expense box
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PaymentMethodAdapter());
    }

    _expenseBox = await Hive.openBox<Expense>(_boxName);
  }

  /// Get all expenses sorted by date (newest first)
  List<Expense> getAllExpenses() {
    try {
      final expenses = _expenseBox.values.toList();
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e) {
      return [];
    }
  }

  /// Add a new expense
  Future<Expense> addExpense({
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required PaymentMethod paymentMethod,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
    );

    await _expenseBox.put(expense.id, expense);
    return expense;
  }

  /// Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  /// Delete an expense by ID
  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  /// Get expenses for a specific date
  List<Expense> getExpensesForDate(DateTime date) {
    return getAllExpenses().where((expense) {
      return expense.date.year == date.year &&
          expense.date.month == date.month &&
          expense.date.day == date.day;
    }).toList();
  }

  /// Get expenses for a specific month
  List<Expense> getExpensesForMonth(int year, int month) {
    return getAllExpenses().where((expense) {
      return expense.date.year == year && expense.date.month == month;
    }).toList();
  }

  /// Get expenses for the current week
  List<Expense> getExpensesForCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return getAllExpenses().where((expense) {
      return expense.date.isAfter(
            startOfWeek.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  /// Calculate total for a list of expenses
  double calculateTotal(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  /// Get daily total for today
  double getTodayTotal() {
    return calculateTotal(getExpensesForDate(DateTime.now()));
  }

  /// Get monthly total for current month
  double getCurrentMonthTotal() {
    final now = DateTime.now();
    return calculateTotal(getExpensesForMonth(now.year, now.month));
  }

  /// Get expenses grouped by category for a month
  Map<ExpenseCategory, double> getCategoryTotalsForMonth(int year, int month) {
    final expenses = getExpensesForMonth(year, month);
    final Map<ExpenseCategory, double> categoryTotals = {};

    for (final category in ExpenseCategory.values) {
      final categoryExpenses = expenses.where((e) => e.category == category);
      categoryTotals[category] = categoryExpenses.fold(
        0,
        (sum, e) => sum + e.amount,
      );
    }

    return categoryTotals;
  }

  /// Get weekly totals for chart (last 7 days)
  Map<DateTime, double> getWeeklyTotals() {
    final Map<DateTime, double> dailyTotals = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      dailyTotals[date] = calculateTotal(getExpensesForDate(date));
    }

    return dailyTotals;
  }

  /// Close the Hive box
  Future<void> close() async {
    await _expenseBox.close();
  }
}
