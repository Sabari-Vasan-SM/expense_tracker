import 'package:hive/hive.dart';

part 'expense.g.dart';

/// Category enum for expenses with icons and colors
@HiveType(typeId: 0)
enum ExpenseCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  travel,
  @HiveField(2)
  bills,
  @HiveField(3)
  shopping,
  @HiveField(4)
  other,
}

/// Extension to provide display properties for categories
extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.travel:
        return '✈️';
      case ExpenseCategory.bills:
        return '📄';
      case ExpenseCategory.shopping:
        return '🛒';
      case ExpenseCategory.other:
        return '📦';
    }
  }

  int get colorValue {
    switch (this) {
      case ExpenseCategory.food:
        return 0xFFFF6B6B;
      case ExpenseCategory.travel:
        return 0xFF4ECDC4;
      case ExpenseCategory.bills:
        return 0xFFFFE66D;
      case ExpenseCategory.shopping:
        return 0xFF95E1D3;
      case ExpenseCategory.other:
        return 0xFFDDA0DD;
    }
  }
}

/// Expense model with Hive annotations
@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  ExpenseCategory category;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  DateTime createdAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, category: $category, date: $date)';
  }
}
