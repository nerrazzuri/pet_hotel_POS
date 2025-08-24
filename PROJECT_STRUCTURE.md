# Cat Hotel POS System - Project Structure & Setup Guide

## 🏗️ Project Architecture Overview

This is a comprehensive, cross-platform Point of Sale system designed specifically for cat hotels, supporting Windows, macOS, iOS, Android, and HarmonyOS.

### **Technology Stack**

#### **Frontend (Flutter)**
- **Framework**: Flutter 3.16+ with Dart 3.0+
- **State Management**: Riverpod for complex state management
- **Navigation**: GoRouter for declarative routing
- **Local Storage**: Hive + SQLite for offline data persistence
- **UI Framework**: Material Design 3 + Cupertino for native feel
- **HTTP Client**: Dio with interceptors for API communication

#### **Backend (Node.js)**
- **Runtime**: Node.js 18+ LTS
- **Framework**: Express.js with TypeScript
- **Database**: PostgreSQL (primary) + Redis (caching/sessions)
- **ORM**: Prisma for type-safe database operations
- **Authentication**: JWT + refresh tokens with Passport.js
- **Real-time**: Socket.IO for live updates

#### **Database Design**
- **PostgreSQL**: Core business data, transactions, customer profiles
- **Redis**: Session management, caching, real-time features
- **File Storage**: AWS S3/Cloudinary for documents/images

## 📁 Complete Project Structure

```
cat_hotel_pos/
├── 📱 Frontend (Flutter)
│   ├── lib/
│   │   ├── core/                          # Core utilities & configuration
│   │   │   ├── app.dart                   # Main app structure
│   │   │   ├── config/                    # App configuration
│   │   │   │   └── app_config.dart       # App-wide settings
│   │   │   ├── services/                  # Core services
│   │   │   │   ├── database_service.dart  # Local SQLite operations
│   │   │   │   └── notification_service.dart # Local notifications
│   │   │   ├── theme/                     # UI theming
│   │   │   │   └── app_theme.dart        # Material 3 themes
│   │   │   └── utils/                     # Utility functions
│   │   ├── features/                      # Feature-based modules
│   │   │   ├── auth/                      # Authentication
│   │   │   │   ├── data/                  # Data layer
│   │   │   │   ├── domain/                # Business logic
│   │   │   │   └── presentation/          # UI components
│   │   │   ├── pos/                       # Sales register (POS)
│   │   │   ├── booking/                   # Booking management
│   │   │   ├── customers/                 # Customer & pet profiles
│   │   │   ├── services/                  # Services & products
│   │   │   ├── inventory/                 # Inventory management
│   │   │   ├── payments/                  # Payment processing
│   │   │   ├── loyalty/                   # Loyalty & CRM
│   │   │   ├── staff/                     # Staff management
│   │   │   ├── reports/                   # Reports & analytics
│   │   │   └── settings/                  # System settings
│   │   ├── shared/                        # Shared components
│   │   │   ├── components/                # Reusable UI components
│   │   │   ├── models/                    # Data models
│   │   │   ├── services/                  # Shared services
│   │   │   └── widgets/                   # Common widgets
│   │   └── main.dart                      # Application entry point
│   ├── assets/                            # Static assets
│   │   ├── images/                        # Images & icons
│   │   ├── fonts/                         # Custom fonts
│   │   └── icons/                         # App icons
│   ├── test/                              # Test files
│   └── pubspec.yaml                       # Flutter dependencies
│
├── 🖥️ Backend (Node.js)
│   ├── src/
│   │   ├── controllers/                   # API controllers
│   │   │   ├── auth.controller.ts         # Authentication
│   │   │   ├── customer.controller.ts     # Customer management
│   │   │   ├── pet.controller.ts          # Pet management
│   │   │   ├── room.controller.ts         # Room management
│   │   │   ├── booking.controller.ts      # Booking management
│   │   │   ├── service.controller.ts      # Service management
│   │   │   ├── product.controller.ts      # Product management
│   │   │   ├── transaction.controller.ts  # Transaction management
│   │   │   ├── inventory.controller.ts    # Inventory management
│   │   │   ├── report.controller.ts       # Reporting
│   │   │   ├── user.controller.ts         # User management
│   │   │   └── communication.controller.ts # Communication
│   │   ├── services/                      # Business logic
│   │   │   ├── auth.service.ts            # Authentication logic
│   │   │   ├── customer.service.ts        # Customer operations
│   │   │   ├── pet.service.ts             # Pet operations
│   │   │   ├── room.service.ts            # Room operations
│   │   │   ├── booking.service.ts         # Booking operations
│   │   │   ├── service.service.ts         # Service operations
│   │   │   ├── product.service.ts         # Product operations
│   │   │   ├── transaction.service.ts     # Transaction operations
│   │   │   ├── inventory.service.ts       # Inventory operations
│   │   │   ├── report.service.ts          # Reporting logic
│   │   │   ├── user.service.ts            # User operations
│   │   │   ├── communication.service.ts   # Communication logic
│   │   │   ├── payment.service.ts         # Payment processing
│   │   │   ├── notification.service.ts    # Notification logic
│   │   │   └── file.service.ts            # File handling
│   │   ├── models/                        # Data models
│   │   │   ├── user.model.ts              # User model
│   │   │   ├── customer.model.ts          # Customer model
│   │   │   ├── pet.model.ts               # Pet model
│   │   │   ├── room.model.ts              # Room model
│   │   │   ├── booking.model.ts           # Booking model
│   │   │   ├── service.model.ts           # Service model
│   │   │   ├── product.model.ts           # Product model
│   │   │   ├── transaction.model.ts       # Transaction model
│   │   │   └── inventory.model.ts         # Inventory model
│   │   ├── middleware/                    # Express middleware
│   │   │   ├── auth.middleware.ts         # Authentication
│   │   │   ├── validation.middleware.ts   # Input validation
│   │   │   ├── error.middleware.ts        # Error handling
│   │   │   ├── rateLimit.middleware.ts    # Rate limiting
│   │   │   ├── cors.middleware.ts         # CORS handling
│   │   │   └── audit.middleware.ts        # Audit logging
│   │   ├── routes/                        # API routes
│   │   │   ├── auth.routes.ts             # Authentication routes
│   │   │   ├── customer.routes.ts         # Customer routes
│   │   │   ├── pet.routes.ts              # Pet routes
│   │   │   ├── room.routes.ts             # Room routes
│   │   │   ├── booking.routes.ts          # Booking routes
│   │   │   ├── service.routes.ts          # Service routes
│   │   │   ├── product.routes.ts          # Product routes
│   │   │   ├── transaction.routes.ts      # Transaction routes
│   │   │   ├── inventory.routes.ts        # Inventory routes
│   │   │   ├── report.routes.ts           # Report routes
│   │   │   ├── user.routes.ts             # User routes
│   │   │   └── communication.routes.ts    # Communication routes
│   │   ├── utils/                         # Utility functions
│   │   │   ├── logger.ts                  # Logging utility
│   │   │   ├── database.ts                # Database utilities
│   │   │   ├── encryption.ts              # Encryption utilities
│   │   │   ├── validation.ts              # Validation utilities
│   │   │   ├── file.ts                    # File handling utilities
│   │   │   └── helpers.ts                 # General helpers
│   │   ├── types/                         # TypeScript types
│   │   │   ├── auth.types.ts              # Authentication types
│   │   │   ├── customer.types.ts          # Customer types
│   │   │   ├── pet.types.ts               # Pet types
│   │   │   ├── room.types.ts              # Room types
│   │   │   ├── booking.types.ts           # Booking types
│   │   │   ├── service.types.ts           # Service types
│   │   │   ├── product.types.ts           # Product types
│   │   │   ├── transaction.types.ts       # Transaction types
│   │   │   └── inventory.types.ts         # Inventory types
│   │   ├── config/                        # Configuration
│   │   │   ├── database.config.ts         # Database configuration
│   │   │   ├── redis.config.ts            # Redis configuration
│   │   │   ├── jwt.config.ts              # JWT configuration
│   │   │   ├── email.config.ts            # Email configuration
│   │   │   ├── payment.config.ts          # Payment configuration
│   │   │   └── app.config.ts              # App configuration
│   │   └── index.ts                       # Main entry point
│   ├── prisma/                            # Database schema
│   │   └── schema.prisma                  # Prisma schema
│   ├── tests/                             # Test files
│   ├── logs/                              # Log files
│   ├── uploads/                           # File uploads
│   ├── backups/                           # Database backups
│   ├── package.json                       # Node.js dependencies
│   ├── tsconfig.json                      # TypeScript configuration
│   ├── env.example                        # Environment variables template
│   └── README.md                          # Backend documentation
│
├── 📊 Database
│   ├── migrations/                        # Database migrations
│   ├── seeds/                             # Seed data
│   └── backups/                           # Database backups
│
├── 📚 Documentation
│   ├── README.md                          # Main project documentation
│   ├── PROJECT_STRUCTURE.md               # This file
│   ├── API_DOCUMENTATION.md               # API documentation
│   ├── DEPLOYMENT.md                      # Deployment guide
│   ├── CONTRIBUTING.md                    # Contributing guidelines
│   └── CHANGELOG.md                       # Version history
│
├── 🐳 Docker
│   ├── docker-compose.yml                 # Development environment
│   ├── Dockerfile.frontend                # Frontend container
│   ├── Dockerfile.backend                 # Backend container
│   └── .dockerignore                      # Docker ignore file
│
├── 🔧 CI/CD
│   ├── .github/                           # GitHub Actions
│   ├── .gitlab-ci.yml                     # GitLab CI
│   └── scripts/                           # Build & deployment scripts
│
└── 📋 Project Files
    ├── .gitignore                         # Git ignore patterns
    ├── .editorconfig                      # Editor configuration
    ├── .prettierrc                        # Code formatting
    ├── .eslintrc.js                       # Linting rules
    └── LICENSE                            # Project license
```

## 🚀 Quick Start Guide

### **Prerequisites**
- Flutter SDK 3.16.0+
- Dart SDK 3.0.0+
- Node.js 18+ LTS
- PostgreSQL 14+
- Redis 6+
- Git

### **1. Clone Repository**
```bash
git clone <repository-url>
cd cat_hotel_pos
```

### **2. Frontend Setup**
```bash
# Install Flutter dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Run the app
flutter run
```

### **3. Backend Setup**
```bash
cd backend

# Install dependencies
npm install

# Copy environment file
cp env.example .env

# Edit .env with your configuration
nano .env

# Generate Prisma client
npm run db:generate

# Run database migrations
npm run db:migrate

# Start development server
npm run dev
```

### **4. Database Setup**
```bash
# Create PostgreSQL database
createdb cat_hotel_pos

# Run migrations
cd backend
npm run db:migrate

# Seed with sample data (optional)
npm run db:seed
```

## 🔧 Development Workflow

### **Code Generation**
```bash
# Frontend (Flutter)
flutter packages pub run build_runner build
flutter packages pub run build_runner watch

# Backend (Prisma)
npm run db:generate
npm run db:migrate
```

### **Testing**
```bash
# Frontend tests
flutter test

# Backend tests
npm test
npm run test:watch
npm run test:coverage
```

### **Building**
```bash
# Frontend builds
flutter build apk          # Android
flutter build ios          # iOS
flutter build windows      # Windows
flutter build macos        # macOS
flutter build web          # Web

# Backend build
npm run build
```

## 📱 Cross-Platform Features

### **Windows/macOS**
- Flutter desktop with native window management
- Hardware integration (receipt printers, cash drawers)
- Touch screen optimization

### **iOS/Android**
- Flutter mobile with platform-specific plugins
- Camera integration for pet photos
- Push notifications
- Offline data sync

### **HarmonyOS**
- Flutter with HarmonyOS-specific adaptations
- Native HarmonyOS features integration

### **Web**
- Flutter web for admin panels
- Online booking widget
- Customer portal

## 🔐 Security Features

- Role-based access control (RBAC)
- JWT authentication with refresh tokens
- Encrypted data storage
- Audit logging for all critical operations
- Offline data protection
- Rate limiting and CORS protection

## 🌐 API Architecture

- RESTful APIs with consistent patterns
- Real-time updates via WebSocket
- GraphQL support for complex queries
- Comprehensive error handling
- Request/response validation
- API versioning

## 📊 Database Design

### **Core Entities**
- Users, Roles, Permissions
- Customers, Pets, Vaccination Records
- Rooms, Bookings, Occupancy
- Services, Products, Inventory
- Transactions, Payments, Refunds
- Staff, Shifts, Commissions

### **Key Features**
- Relational integrity with foreign keys
- Audit logging for all changes
- Soft deletes for data retention
- Optimized indexes for performance
- Backup and recovery procedures

## 🚀 Deployment Options

### **Development**
- Local development with hot reload
- Docker Compose for services
- Local database and Redis

### **Staging**
- Cloud deployment (AWS, GCP, Azure)
- CI/CD pipeline integration
- Automated testing

### **Production**
- High availability setup
- Load balancing and scaling
- Monitoring and alerting
- Automated backups

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is proprietary software. All rights reserved.

## 🆘 Support

For support and questions, please contact the development team.
