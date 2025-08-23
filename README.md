# 🐱 Pet Hotel POS System

A comprehensive Point of Sale (POS) system designed specifically for pet hotels, catteries, and pet care facilities. Built with Flutter for cross-platform compatibility (Windows, Android, Web).

## ✨ Features

### 🔐 **Authentication & Security**
- **Role-Based Access Control (RBAC)** with 4 user roles:
  - **Staff**: Basic POS operations, customer management
  - **Manager**: Staff permissions + financial operations, inventory management
  - **Owner**: Manager permissions + loyalty programs, CRM, services management
  - **Administrator**: Full system access
- Secure password hashing (SHA256)
- Biometric authentication support
- Audit logging for all system activities

### 🛒 **POS System**
- **Quick Actions**: Fast check-in, customer search, cart management
- **Product Management**: Service packages, retail items, pricing
- **Cart Operations**: Add/remove items, apply discounts, hold carts
- **Payment Processing**: Multiple payment methods, split bills, partial payments
- **Receipt Generation**: Customizable receipts with business branding
- **Refund/Void**: Transaction management with audit trail

### 👥 **Staff Management**
- **Staff Profiles**: Complete employee information, roles, permissions
- **Shift Scheduling**: Manage work schedules, time tracking
- **Performance Analytics**: Sales metrics, productivity reports
- **Role Management**: Assign permissions, manage access levels

### 🐾 **Customer & Pet Management**
- **Customer Profiles**: Contact information, preferences, history
- **Pet Profiles**: Breed, age, medical information, special needs
- **Vaccination Records**: Track required vaccinations and due dates
- **Waiver Management**: Digital consent forms and agreements
- **Incident Reports**: Log and track any incidents or special care needs

### 💰 **Financial Operations**
- **Account Management**: Multiple financial accounts, categories
- **Transaction Tracking**: Income, expenses, transfers
- **Budget Management**: Set budgets, track spending, generate reports
- **Financial Analytics**: Profit & loss, cash flow, expense analysis

### 🏨 **Booking & Room Management**
- **Reservation System**: Book rooms, cages, facilities
- **Room Management**: Track availability, maintenance, cleaning status
- **Capacity Planning**: Optimize space utilization

### 📦 **Inventory & Purchasing**
- **Stock Management**: Track supplies, products, equipment
- **Supplier Management**: Vendor information, contact details
- **Purchase Orders**: Create, track, and manage orders
- **Low Stock Alerts**: Automated notifications for reordering

### 📊 **Reports & Analytics**
- **Sales Reports**: Daily, weekly, monthly sales analysis
- **Customer Analytics**: Demographics, preferences, loyalty metrics
- **Financial Reports**: Revenue, expenses, profitability analysis
- **Operational Reports**: Staff performance, room utilization
- **Export Capabilities**: PDF, Excel, CSV formats

### 🎯 **Loyalty & CRM**
- **Loyalty Programs**: Points system, tiers, rewards
- **Customer Relationship Management**: Campaigns, communication templates
- **Automated Reminders**: Vaccination due dates, check-ups
- **Marketing Tools**: Email campaigns, SMS notifications

### ⚙️ **System Settings**
- **Business Configuration**: Company information, branding
- **General Settings**: Language, timezone, notifications
- **System Preferences**: Backup frequency, maintenance schedules
- **User Preferences**: Interface customization, notification settings

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.2.0 or higher)
- Git
- For Windows: Visual Studio 2019 or higher with C++ tools
- For Android: Android Studio, Android SDK
- For Web: Chrome browser

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:nerrazzuri/pet_hotel_POS.git
   cd pet_hotel_POS
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code files**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   # For Windows
   flutter run -d windows
   
   # For Android
   flutter run -d android
   
   # For Web
   flutter run -d chrome
   ```

### Default Login Credentials

| Role | Username | Password | Access Level |
|------|----------|----------|--------------|
| **Staff** | `staff` | `staff123` | Basic POS operations |
| **Manager** | `manager` | `manager123` | Enhanced management features |
| **Owner** | `owner` | `owner123` | Full business access |
| **Administrator** | `admin` | `admin123` | Complete system access |

## 🏗️ Architecture

### **Clean Architecture Pattern**
```
lib/
├── core/                    # Core services, utilities, constants
├── features/               # Feature modules
│   ├── auth/              # Authentication & authorization
│   ├── dashboard/         # Main dashboard & navigation
│   ├── pos/               # Point of sale system
│   ├── staff/             # Staff management
│   ├── customers/         # Customer & pet management
│   ├── financials/        # Financial operations
│   ├── settings/          # System configuration
│   ├── loyalty/           # Loyalty programs
│   ├── crm/               # Customer relationship management
│   ├── booking/           # Booking & reservations
│   ├── inventory/         # Inventory & purchasing
│   ├── reports/           # Reporting & analytics
│   ├── payments/          # Payment processing
│   └── services/          # Service management
└── shared/                # Shared widgets, models, utilities
```

### **State Management**
- **Riverpod** for state management and dependency injection
- **Provider pattern** for service layer
- **Repository pattern** for data access

### **Data Persistence**
- **SQLite** for Windows/Desktop platforms
- **localStorage** for Web platforms
- **In-memory DAOs** for Android compatibility
- **Secure storage** for sensitive data

## 🔧 Configuration

### **Environment Setup**
1. Copy `.env.example` to `.env`
2. Configure database connections
3. Set business information
4. Configure notification settings

### **Business Configuration**
- Company name and branding
- Tax rates and currency
- Operating hours
- Service categories and pricing
- Room types and rates

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Windows** | ✅ Full Support | Primary development platform |
| **Android** | ✅ Full Support | Mobile app functionality |
| **Web** | ✅ Full Support | Browser-based access |
| **iOS** | 🔄 Planned | Future development |
| **macOS** | 🔄 Planned | Future development |
| **Linux** | 🔄 Planned | Future development |

## 🧪 Testing

### **Run Tests**
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
```

### **Test Structure**
- **Unit Tests**: Individual component testing
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end workflow testing

## 📦 Build & Deploy

### **Build for Production**
```bash
# Windows
flutter build windows

# Android
flutter build apk --release

# Web
flutter build web
```

### **Distribution**
- **Windows**: Executable installer
- **Android**: APK file
- **Web**: Static files for web hosting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Guidelines**
- Follow Flutter best practices
- Use meaningful commit messages
- Write comprehensive tests
- Update documentation for new features
- Follow the existing code style

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### **Documentation**
- [User Manual](docs/USER_MANUAL.md)
- [API Reference](docs/API_REFERENCE.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

### **Contact**
- **Issues**: [GitHub Issues](https://github.com/nerrazzuri/pet_hotel_POS/issues)
- **Discussions**: [GitHub Discussions](https://github.com/nerrazzuri/pet_hotel_POS/discussions)
- **Email**: support@cathotelpos.com

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Riverpod** for state management solutions
- **Freezed** for code generation
- **SQLite** for database functionality
- **Material Design** for UI components

## 📈 Roadmap

### **Version 2.0** (Q2 2024)
- [ ] Multi-location support
- [ ] Advanced reporting dashboard
- [ ] Mobile app optimization
- [ ] API for third-party integrations

### **Version 3.0** (Q4 2024)
- [ ] AI-powered analytics
- [ ] Advanced scheduling algorithms
- [ ] Customer portal
- [ ] Payment gateway integrations

---

**Made with ❤️ for pet care professionals**

*This system is designed to help pet hotels provide excellent service while managing their business efficiently.*
