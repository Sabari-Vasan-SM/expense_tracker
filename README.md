# 💰 Expense Tracker v1.2

A modern, feature-rich expense tracking application built with Flutter and Material 3 design. Track your spending, visualize patterns, and manage payments efficiently.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10+-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-1.2-brightgreen)

## ✨ Features

### 🎨 Dynamic Theming
- **Material You Colors**: Adapts to device wallpaper for personalized experience
- **Light/Dark Mode**: Full theme support with persistent user preference
- **Smooth Transitions**: Animated theme switching without app restart

### 💳 Payment Tracking
- **Multiple Payment Methods**: Cash, Credit Card, Debit Card, UPI, Other
- **Segmented Selection UI**: Intuitive payment method picker
- **Persistent Storage**: All payment data saved in Hive database

### 📊 Expense Management
- **Quick Add/Edit**: Bottom sheet form for rapid expense entry
- **7 Categories**: Food, Transport, Entertainment, Shopping, Utilities, Health, Other
- **Real-time Updates**: AnimatedList for smooth expense additions/deletions
- **Recent Transactions**: Always-visible recent expense list

### 📈 Analytics Dashboard
- **Weekly Trends**: Line chart showing 7-day spending patterns
- **Category Breakdown**: Visual pie/bar charts of spending by category
- **Summary Cards**: Today, This Week, This Month totals
- **Export Options**: Share expenses or download as PDF

### 🎬 UI/UX Polish
- **Splash Screen**: Animated splash with developer credit
- **Loading States**: Staggered wave loading animation
- **Empty States**: Beautiful empty state with call-to-action
- **Smooth Animations**: Fade, scale, and slide transitions throughout

### 💾 Data Persistence
- **Hive Database**: Fast, local-only data storage (no cloud)
- **SharedPreferences**: Theme preference persistence
- **Auto-sync**: Immediate data save on all operations

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── expense.dart                   # Expense model (Hive)
│   └── expense.g.dart                 # Generated adapter
├── services/
│   ├── expense_storage_service.dart    # Database operations
│   ├── export_service.dart             # PDF/Share export
│   ├── export_service_stub.dart        # Stub for non-web
│   ├── export_service_web.dart         # Web implementation
│   └── theme_storage_service.dart      # Theme persistence
├── ui/
│   ├── screens/
│   │   ├── home_screen.dart            # Main expenses & analytics
│   │   └── splash_screen.dart          # Splash animation
│   ├── theme/
│   │   └── app_theme.dart              # Material 3 themes
│   └── widgets/
│       ├── expense_card.dart           # Individual expense tile
│       ├── expense_bottom_sheet.dart   # Add/edit form
│       ├── expense_chart.dart          # Chart visualizations
│       ├── summary_card.dart           # Summary tiles
│       ├── empty_state.dart            # Empty state UI
│       ├── about_dialog.dart           # Developer info
│       ├── expenses_detail_dialog.dart # Period details
│       └── all_expenses_dialog.dart    # Full expense list
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|----------|
| **UI Framework** | Flutter 3.10+ | Cross-platform development |
| **State Management** | StatefulWidget | Simple, built-in state |
| **Database** | Hive 2.2+ | Fast, local data storage |
| **Charts** | fl_chart 0.69+ | Data visualization |
| **Theming** | dynamic_color 1.7+ | Material You adaptation |
| **Persistence** | shared_preferences 2.2+ | Simple key-value store |
| **Export** | pdf 3.10+ | PDF generation |
| **Sharing** | share_plus 7.1+ | Share functionality |

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10.4+
- Dart 3.10.4+
- iOS 11.0+ (macOS 10.15+)
- Android 5.1+ (API 21+)
- Windows 10+ / Linux (GTK 3.0+)

### Installation

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd expense_tracker
   ```

2. **Get Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Models** (if needed)
   ```bash
   flutter pub run build_runner build
   ```

4. **Run Application**
   ```bash
   # Development
   flutter run
   
   # Specific platform
   flutter run -d windows
   flutter run -d android
   ```

## 📱 Usage

### Adding an Expense
1. Tap **"Add Expense"** FAB (bottom-right)
2. Fill in details:
   - Title (required)
   - Amount (required)
   - Category (select from 7)
   - Date (tap to pick)
   - Payment Method (Cash/Card/UPI/etc)
3. Tap **"Save"** to confirm

### Viewing Analytics
1. Switch to **"Analytics"** tab
2. View **Weekly Trend** chart (7-day spending)
3. See **Category Breakdown** (visual percentage)
4. Use chart toggle for Weekly/Category view

### Exporting Data
1. Tap **⋯ (Menu)** → **More Options**
2. Choose:
   - **Share**: Send as text to any app
   - **Download PDF**: Save PDF to device

### Switching Themes
1. Tap **⋯ (Menu)** → **More Options**
2. Use theme toggle: **☀️ Light** or **🌙 Dark**
3. Selection saves automatically

## 🎨 Customization

### Change Primary Color
Edit [lib/ui/theme/app_theme.dart](lib/ui/theme/app_theme.dart):
```dart
static const Color primaryColor = Color(0xFF6750A4); // Change this
```

### Add New Category
1. Edit [lib/models/expense.dart](lib/models/expense.dart)
2. Add to `ExpenseCategory` enum
3. Regenerate adapters: `flutter pub run build_runner build`

### Modify Chart Colors
Edit category colors in [lib/models/expense.dart](lib/models/expense.dart):
```dart
case ExpenseCategory.food:
  return 0xFFFF6B6B; // Change color
```

## 📊 Data Model

### Expense
```dart
class Expense {
  final String id;              // UUID
  final String title;           // Expense name
  final double amount;          // In rupees
  final ExpenseCategory category;
  final DateTime date;          // When spent
  final PaymentMethod paymentMethod;
  final DateTime createdAt;     // Record time
}
```

### Categories
- 🍔 Food
- 🚗 Transport
- 🎬 Entertainment
- 🛍️ Shopping
- 💡 Utilities
- ⚕️ Health
- 🏷️ Other

### Payment Methods
- 💵 Cash
- 💳 Credit Card
- 💳 Debit Card
- 📱 UPI
- ➕ Other

## 🧪 Testing

### Manual Testing Checklist
- [ ] Add expense with all fields
- [ ] Edit existing expense
- [ ] Delete expense (with confirmation)
- [ ] Switch between Expenses/Analytics tabs
- [ ] Toggle theme (Light/Dark)
- [ ] Export to PDF
- [ ] Share expenses
- [ ] Verify data persists after restart

## 🐛 Known Issues

- Windows requires Developer Mode enabled for Flutter plugins
- PDF export may take 2-3 seconds on older devices
- Dynamic colors require Android 12+ for best results

## 🔄 Version History

### v1.2 (Current)
- Dynamic Material You theming
- Persistent theme preference
- Payment method selection
- Enhanced splash animation
- Always-visible menu actions
- Light mode background fix

### v1.1
- Basic expense CRUD
- Weekly/Category analytics
- Export to PDF
- Share functionality

### v1.0
- Initial release
- Expense tracking
- Dark theme

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  hive: ^2.2.3              # Database
  hive_flutter: ^1.1.0      # Flutter adapter
  fl_chart: ^0.69.0         # Charts
  intl: ^0.19.0             # Internationalization
  uuid: ^4.5.1              # ID generation
  url_launcher: ^6.2.0      # URL opening
  loading_animation_widget: ^1.2.0  # Loading animation
  pdf: ^3.10.0              # PDF generation
  share_plus: ^7.1.0        # Sharing
  path_provider: ^2.1.0     # File paths
  shared_preferences: ^2.2.2  # Preferences
  dynamic_color: ^1.7.0     # Material You
```

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 👤 Author

**Sabarivasan**
- Portfolio: [portfolio.vasan.tech](https://portfolio.vasan.tech/)
- GitHub: [@Sabari-Vasan-SM](https://github.com/Sabari-Vasan-SM)
- LinkedIn: [Sabarivasan S M](https://www.linkedin.com/in/sabarivasan-s-m-b10229255/)

## 🙏 Acknowledgments

- Material Design 3 guidelines
- Flutter community
- All contributors and testers

## 📧 Contact

For questions or feedback, reach out on LinkedIn or GitHub!

---

**Made with ❤️ by Sabarivasan**
