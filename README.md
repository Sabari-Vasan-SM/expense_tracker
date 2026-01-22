# 💰 Expense Tracker

A modern, feature-rich Flutter application for tracking daily expenses with beautiful Material 3 design, dynamic theming, and powerful analytics.

![Version](https://img.shields.io/badge/version-1.2-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.10.4%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blueviolet)

## ✨ Features

### 🎨 Theming
- **Dynamic Material You**: Automatically adapts colors to device wallpaper
- **Light & Dark Mode**: Full support with persistent user preference
- **Material 3 Compliance**: Modern design system throughout the app
- **Seamless Theme Toggle**: Real-time theme switching with smooth transitions

### 💳 Expense Management
- **Multiple Categories**: Food, Transport, Entertainment, Shopping, Bills, Other
- **Payment Methods**: Cash, Credit Card, Debit Card, UPI, Other
- **Add/Edit/Delete**: Full CRUD operations with smooth animations
- **Date Tracking**: Organize expenses by specific dates
- **Search & Filter**: Find expenses easily in the list

### 📊 Analytics Dashboard
- **Weekly Trend Chart**: Visualize spending patterns with line charts
- **Category Breakdown**: Pie charts showing expense distribution
- **Summary Cards**: Today, This Week, This Month totals at a glance
- **Expense Details**: Drill-down into specific time periods

### 📤 Export & Share
- **PDF Export**: Download expense reports as PDF files
- **Share via WhatsApp/Email**: Share expense summaries instantly
- **Smart Formatting**: Well-formatted reports with totals and categories

### 💾 Data Persistence
- **Local Database**: Hive-powered local storage (no cloud required)
- **Theme Persistence**: Your theme preference survives app restart
- **Automatic Backups**: Data synced locally in real-time

### 🎬 Polish & Animation
- **Splash Screen**: Animated app launch with developer credit
- **Smooth Transitions**: Fade & scale animations throughout
- **Loading States**: Elegant loading animations for better UX
- **List Animations**: Smooth add/remove animations for expenses

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10.4 or higher
- Dart 3.10.4 or higher
- Android SDK (for Android)
- Xcode (for iOS)

### Installation

1. **Clone the Repository**
```bash
git clone https://github.com/yourusername/expense_tracker.git
cd expense_tracker
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Run Build Runner** (for Hive code generation)
```bash
flutter pub run build_runner build
```

4. **Run the App**
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Web
flutter run -d web

# For Windows
flutter run -d windows
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point & theme setup
├── models/
│   ├── expense.dart             # Expense data model
│   └── expense.g.dart           # Generated Hive adapter
├── services/
│   ├── expense_storage_service.dart   # Hive storage logic
│   ├── export_service.dart            # PDF & share exports
│   ├── export_service_web.dart        # Web-specific exports
│   ├── export_service_stub.dart       # Platform stub
│   └── theme_storage_service.dart     # Theme persistence
└── ui/
    ├── theme/
    │   └── app_theme.dart       # Material 3 theme definitions
    ├── screens/
    │   ├── home_screen.dart     # Main expenses & analytics
    │   └── splash_screen.dart   # Launch screen
    └── widgets/
        ├── expense_card.dart          # Expense list item
        ├── expense_bottom_sheet.dart  # Add/edit form
        ├── summary_card.dart          # Summary tiles
        ├── expense_chart.dart         # Chart components
        ├── empty_state.dart           # Empty state UI
        ├── about_dialog.dart          # Developer info
        ├── expenses_detail_dialog.dart # Detailed breakdown
        └── all_expenses_dialog.dart   # Complete expense list
```

## 🏗️ Architecture

### State Management
- **StatefulWidget**: Local state management for simplicity
- **ScaffoldMessenger**: Toast/snackbar notifications
- **Named Routes**: Proper navigation architecture

### Data Layer
- **Hive**: Local NoSQL database for expense storage
- **SharedPreferences**: Theme mode persistence
- **Local File System**: PDF generation and storage

### Presentation Layer
- **Material 3**: Modern UI components
- **CustomScrollView with Slivers**: Efficient scrolling
- **AnimatedList**: Smooth list item animations
- **Charts (fl_chart)**: Data visualization

## 📦 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **flutter** | 3.10.4+ | UI framework |
| **hive** | 2.2.3+ | Local database |
| **fl_chart** | 0.69.0+ | Charts & analytics |
| **intl** | 0.19.0+ | Date/time formatting |
| **uuid** | 4.5.1+ | Unique IDs |
| **pdf** | 3.10.0+ | PDF generation |
| **share_plus** | 7.1.0+ | Share functionality |
| **path_provider** | 2.1.0+ | File system paths |
| **shared_preferences** | 2.2.2+ | User preferences |
| **dynamic_color** | 1.7.0+ | Material You colors |
| **loading_animation_widget** | 1.2.0+ | Loading animations |

## 🎯 Usage

### Adding an Expense
1. Tap the **"+ Add Expense"** button
2. Fill in details: Title, Amount, Category, Payment Method, Date
3. Tap **"Save"** to add

### Viewing Analytics
1. Navigate to **Analytics** tab
2. View weekly trends, category breakdown, and summary
3. Tap on category tiles for detailed breakdowns

### Exporting Data
1. Tap the **three-dot menu** icon
2. Choose **"Download PDF"** or **"Share"**
3. Save or share your expense report

### Changing Theme
1. Tap the **three-dot menu** icon
2. Select **Light** or **Dark** mode
3. Theme persists automatically

## 🔧 Technical Highlights

### Dynamic Theming
```dart
// Uses DynamicColorBuilder for Material You support
// Falls back to seed color: #6750A4
ColorScheme.fromSeed(seedColor: primaryColor, brightness: brightness)
```

### Local Storage
```dart
// Hive database with type-safe adapters
// Payment method enum with Hive integration
// Automatic data persistence
```

### PDF Generation
```dart
// pw package for PDF creation
// Platform-specific export handling
// Share integration for multiple platforms
```

## 📊 Data Models

### Expense
```dart
{
  id: String,
  title: String,
  amount: double,
  category: ExpenseCategory,
  date: DateTime,
  paymentMethod: PaymentMethod,
  createdAt: DateTime,
}
```

### ExpenseCategory
- Food
- Transport
- Entertainment
- Shopping
- Bills
- Other

### PaymentMethod
- Cash
- Credit Card
- Debit Card
- UPI
- Other

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Build for Release
```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
flutter build windows  # Windows
```

## 🎨 Customization

### Change Theme Colors
Edit [lib/ui/theme/app_theme.dart](lib/ui/theme/app_theme.dart):
```dart
static const Color primaryColor = Color(0xFF6750A4); // Change this
```

### Add New Categories
Edit [lib/models/expense.dart](lib/models/expense.dart) and add to the `ExpenseCategory` enum.

### Modify Summary Cards
Customize [lib/ui/widgets/summary_card.dart](lib/ui/widgets/summary_card.dart) for different styling.

## 🐛 Known Issues

- Windows build requires Developer Mode enabled (symlink support)
- Web platform has limited file system access

## 🚧 Roadmap

- [ ] Cloud sync with Firebase
- [ ] Budget alerts & notifications
- [ ] Recurring expenses
- [ ] Multi-currency support
- [ ] Receipt image attachment
- [ ] Advanced filtering & sorting
- [ ] Monthly reports & statistics
- [ ] Widget dashboard

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 👤 Author

**Sabarivasan**
- GitHub: [@yourgithub](https://github.com/yourusername)
- LinkedIn: [@yourlinkedin](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design guidelines
- fl_chart for charting library
- Hive for local storage solution

## 💬 Support

Found a bug or have a feature request? Open an issue on [GitHub Issues](https://github.com/yourusername/expense_tracker/issues).

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

Made with ❤️ using Flutter
