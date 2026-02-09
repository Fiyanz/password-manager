# pass_manager - Flutter Password Manager Development Guide

Ini adalah panduan lengkap untuk pengembangan aplikasi **pass_manager**, sebuah aplikasi manajemen password berbasis Flutter yang mengikuti prinsip Clean Architecture.

## 📋 Ringkasan Proyek

**pass_manager** adalah aplikasi mobile untuk mengelola password dengan aman. Proyek ini masih dalam tahap awal pengembangan dengan struktur arsitektur yang sudah siap namun implementasi minimal.

### Target Platform
- Android (primary)
- iOS (secondary)

### Teknologi Inti
- **Framework**: Flutter
- **Bahasa**: Dart
- **Arsitektur**: Clean Architecture + MVVM
- **Database**: SQLite (akan diimplementasi dengan sqflite)

---

## 🎨 Referensi Desain UI/UX

Semua implementasi UI **HARUS** mengikuti mockup yang tersedia di folder `assets/`:

| Halaman | File Mockup | File Implementasi |
|---------|-------------|-------------------|
| Halaman Utama | `assets/LandingPage.png` | `lib/presentation/pages/home_page.dart` |
| Tambah Password | `assets/AddNewPassword.png` | `lib/presentation/pages/add_password_page.dart` |
| Detail Password | `assets/DetailPage.png` | `lib/presentation/pages/password_detail_page.dart` |
| Generator Password | `assets/PasswordGenerator.png` | `lib/presentation/pages/generator_page.dart` |

### Prinsip Desain
✅ Ikuti **persis** layout, spacing, dan hierarki komponen dari mockup  
✅ Gunakan **hanya** konstanta warna dari `AppColors`  
✅ Padding konsisten: 16-24px untuk margin tepi  
✅ Rounded corners pada card dan button sesuai desain  

---

## 🏗️ Arsitektur: Clean Architecture

### Struktur Folder

```
lib/
├── core/                          # Utilities & constants bersama
│   ├── constants/
│   │   └── app_colors.dart       # ✅ Sudah ada - Warna tema aplikasi
│   └── utils/                     # Helper functions (belum ada)
│
├── domain/                        # 🎯 Business logic murni (Pure Dart)
│   ├── entities/
│   │   └── password_entity.dart  # Objek domain Password
│   └── repositories/
│       └── password_repository.dart  # Interface/Contract
│
├── data/                          # 💾 Implementasi data konkret
│   ├── datasources/
│   │   └── database_helper.dart  # Koneksi SQLite
│   ├── models/
│   │   └── password_model.dart   # DTO + serialization
│   └── repositories/
│       └── password_repository_impl.dart  # Implementasi konkret
│
├── presentation/                  # 🖼️ UI & State Management
│   ├── viewmodels/
│   │   └── password_viewmodel.dart  # Business logic untuk UI
│   └── pages/
│       ├── home_page.dart
│       ├── add_password_page.dart
│       ├── password_detail_page.dart
│       └── generator_page.dart
│
└── main.dart                      # Entry point aplikasi
```

---

## 🔄 Alur Data (Data Flow)

### Contoh: Mengambil Daftar Password

```
┌─────────────┐
│  home_page  │  (UI Layer)
└──────┬──────┘
       │ 1. User membuka halaman
       ▼
┌──────────────────────┐
│ password_viewmodel   │  (ViewModel)
└──────┬───────────────┘
       │ 2. Panggil getPasswords()
       ▼
┌──────────────────────┐
│ PasswordRepository   │  (Domain - Abstract)
│ (interface)          │
└──────┬───────────────┘
       │ 3. Implementasi dipanggil
       ▼
┌───────────────────────────┐
│ PasswordRepositoryImpl    │  (Data - Concrete)
└──────┬────────────────────┘
       │ 4. Query ke database
       ▼
┌──────────────────────┐
│ DatabaseHelper       │  (Datasource)
└──────┬───────────────┘
       │ 5. Return List<PasswordModel>
       ▼
┌───────────────────────────┐
│ PasswordRepositoryImpl    │
│ • Convert Model → Entity  │
└──────┬────────────────────┘
       │ 6. Return List<PasswordEntity>
       ▼
┌──────────────────────┐
│ password_viewmodel   │
│ • Update state       │
│ • notifyListeners()  │
└──────┬───────────────┘
       │ 7. UI rebuild
       ▼
┌─────────────┐
│  home_page  │  (Tampilkan data)
└─────────────┘
```

---

## 📐 Aturan Lapisan (Layer Rules)

### 1️⃣ Domain Layer (Pure Dart)
**Lokasi**: `lib/domain/`

**Boleh**:
- ✅ Definisi entity murni (class tanpa logic kompleks)
- ✅ Interface repository (abstract class)
- ✅ Tidak ada dependency eksternal sama sekali

**Tidak Boleh**:
- ❌ Import dari `data/` atau `presentation/`
- ❌ Import Flutter widgets (`import 'package:flutter/...'`)
- ❌ Import library database/HTTP (`sqflite`, `dio`, dll)

**Contoh Entity**:
```dart
// lib/domain/entities/password_entity.dart
class PasswordEntity {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final DateTime createdAt;

  const PasswordEntity({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    required this.createdAt,
  });
}
```

**Contoh Repository Interface**:
```dart
// lib/domain/repositories/password_repository.dart
abstract class PasswordRepository {
  Future<List<PasswordEntity>> getAllPasswords();
  Future<PasswordEntity?> getPasswordById(String id);
  Future<void> addPassword(PasswordEntity password);
  Future<void> updatePassword(PasswordEntity password);
  Future<void> deletePassword(String id);
}
```

---

### 2️⃣ Data Layer
**Lokasi**: `lib/data/`

**Tanggung Jawab**:
- Implementasi konkret dari repository interface
- Konversi Model ↔ Entity
- Komunikasi dengan database/API

**Contoh Model**:
```dart
// lib/data/models/password_model.dart
class PasswordModel {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String createdAt;

  PasswordModel({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    required this.createdAt,
  });

  // Serialization
  factory PasswordModel.fromJson(Map<String, dynamic> json) {
    return PasswordModel(
      id: json['id'],
      title: json['title'],
      username: json['username'],
      password: json['password'],
      url: json['url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'created_at': createdAt,
    };
  }

  // Conversion ke Entity
  PasswordEntity toEntity() {
    return PasswordEntity(
      id: id,
      title: title,
      username: username,
      password: password,
      url: url,
      createdAt: DateTime.parse(createdAt),
    );
  }

  // Conversion dari Entity
  factory PasswordModel.fromEntity(PasswordEntity entity) {
    return PasswordModel(
      id: entity.id,
      title: entity.title,
      username: entity.username,
      password: entity.password,
      url: entity.url,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
```

**Contoh Repository Implementation**:
```dart
// lib/data/repositories/password_repository_impl.dart
class PasswordRepositoryImpl implements PasswordRepository {
  final DatabaseHelper _databaseHelper;

  PasswordRepositoryImpl(this._databaseHelper);

  @override
  Future<List<PasswordEntity>> getAllPasswords() async {
    final models = await _databaseHelper.getAllPasswords();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addPassword(PasswordEntity password) async {
    final model = PasswordModel.fromEntity(password);
    await _databaseHelper.insertPassword(model);
  }

  // ... implementasi method lainnya
}
```

---

### 3️⃣ Presentation Layer
**Lokasi**: `lib/presentation/`

**Komponen**:
- **Pages**: Widget UI (StatelessWidget/StatefulWidget)
- **ViewModels**: State management & business logic delegation

**Aturan**:
- ❌ **JANGAN** import dari `data/` langsung
- ✅ Hanya panggil method dari `PasswordRepository` (domain)
- ✅ ViewModel berkomunikasi dengan repository
- ✅ UI hanya berkomunikasi dengan ViewModel

**Contoh ViewModel**:
```dart
// lib/presentation/viewmodels/password_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/password_entity.dart';
import '../../domain/repositories/password_repository.dart';

class PasswordViewModel extends ChangeNotifier {
  final PasswordRepository _repository;
  
  List<PasswordEntity> _passwords = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PasswordEntity> get passwords => _passwords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PasswordViewModel(this._repository);

  Future<void> loadPasswords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _passwords = await _repository.getAllPasswords();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePassword(String id) async {
    await _repository.deletePassword(id);
    await loadPasswords(); // Refresh list
  }
}
```

---

## 🎨 Palet Warna Aplikasi

**File**: `lib/core/constants/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF1164E8);      // Biru utama
  
  // Background
  static const Color background = Color(0xFFF5F7FA);   // Abu-abu terang
  
  // Text
  static const Color textDark = Color(0xFF2D3B48);     // Teks utama
  static const Color textGrey = Color(0xFF9EA6B5);     // Teks sekunder/hint
  
  // Danger
  static const Color danger = Color(0xFFF43F5E);       // Merah untuk delete/error
  
  // Whites & Grays
  static const Color white = Colors.white;
  static const Color cardBorder = Color(0xFFE5E7EB);
}
```

### Penggunaan Warna
```dart
// ✅ BENAR
Container(
  color: AppColors.primary,
  child: Text(
    'Password Manager',
    style: TextStyle(color: AppColors.textDark),
  ),
)

// ❌ SALAH - Jangan hardcode warna
Container(
  color: Color(0xFF1164E8), // ❌ Gunakan AppColors.primary
)
```

---

## 🛠️ Workflow Development

### Setup Awal
```bash
# 1. Install dependencies
flutter pub get

# 2. Jalankan aplikasi
flutter run

# 3. Format kode
dart format lib/

# 4. Analisis kode
flutter analyze
```

### Menambahkan Fitur Baru

#### Langkah 1: Domain Layer
```dart
// 1. Buat entity di lib/domain/entities/
// 2. Buat repository interface di lib/domain/repositories/
```

#### Langkah 2: Data Layer
```dart
// 1. Buat model di lib/data/models/ (dengan toJson, fromJson, toEntity)
// 2. Implementasi repository di lib/data/repositories/
// 3. Update datasource jika perlu di lib/data/datasources/
```

#### Langkah 3: Presentation Layer
```dart
// 1. Buat ViewModel di lib/presentation/viewmodels/
// 2. Buat UI page di lib/presentation/pages/
// 3. Wire up dependency injection
```

#### Langkah 4: Testing
```bash
flutter test
```

---

## 📦 Dependencies yang Direkomendasikan

### Tambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1              # MVVM pattern
  
  # Database
  sqflite: ^2.3.0               # SQLite local database
  path: ^1.8.3                  # Path manipulation
  
  # Utilities
  uuid: ^4.2.0                  # Generate unique IDs
  intl: ^0.18.1                 # Date formatting
  
  # UI
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

Install dengan:
```bash
flutter pub get
```

---

## ⚠️ Anti-Pattern yang Harus Dihindari

| ❌ JANGAN | ✅ LAKUKAN |
|-----------|------------|
| Import `data/` di `presentation/` | Import hanya `domain/` di presentation |
| Hardcode warna | Gunakan `AppColors.*` |
| Put logic di Widget | Gunakan ViewModel |
| Mix Entity dan Model | Pisahkan: Entity (domain), Model (data) |
| Gunakan `print()` untuk debugging | Gunakan `debugPrint()` atau logger |
| StatefulWidget untuk state kompleks | Gunakan ViewModel + provider |

---

## 📝 Checklist Implementasi

### Phase 1: Foundation ✅
- [x] Setup folder structure
- [x] Implementasi `AppColors`
- [ ] Setup database schema
- [ ] Implementasi `PasswordEntity`
- [ ] Implementasi `PasswordModel`

### Phase 2: Data Layer
- [ ] `DatabaseHelper` untuk CRUD SQLite
- [ ] `PasswordRepositoryImpl`
- [ ] Unit test untuk repository

### Phase 3: Presentation Layer
- [ ] `PasswordViewModel`
- [ ] Implementasi `home_page.dart` sesuai mockup
- [ ] Implementasi `add_password_page.dart` sesuai mockup
- [ ] Implementasi `password_detail_page.dart` sesuai mockup
- [ ] Implementasi `generator_page.dart` sesuai mockup

### Phase 4: Features
- [ ] Password generator logic
- [ ] Search/filter passwords
- [ ] Password strength indicator
- [ ] Encryption (jika diperlukan)

### Phase 5: Polish
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states
- [ ] Integration testing

---

## 🧪 Testing Strategy

```dart
// test/domain/entities/password_entity_test.dart
void main() {
  test('PasswordEntity should be created correctly', () {
    final password = PasswordEntity(
      id: '1',
      title: 'Gmail',
      username: 'user@gmail.com',
      password: 'securePass123',
      createdAt: DateTime.now(),
    );
    
    expect(password.title, 'Gmail');
    expect(password.username, 'user@gmail.com');
  });
}
```

---

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter MVVM Pattern](https://medium.com/flutterdevs/flutter-mvvm-architecture-f8bed2521958)

---

## 🤝 Kontribusi

Saat berkontribusi:
1. Follow struktur Clean Architecture
2. Ikuti mockup UI dengan ketat
3. Gunakan `AppColors` untuk semua warna
4. Tulis unit test untuk business logic
5. Format kode dengan `dart format`
6. Pastikan `flutter analyze` bersih

---

**Catatan**: Proyek ini masih dalam tahap awal. Prioritas pertama adalah implementasi CRUD password dasar dengan UI yang mengikuti mockup yang ada.