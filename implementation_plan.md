# مندوب المبيعات — خطة التنفيذ الشاملة

> تطبيق إدارة مبيعات ومخزون لمندوب مواد غذائية — Offline First, Single User

---

## 🎨 Color Palette (مستخرج من اللوجو)

| الدور | اللون | Hex |
|---|---|---|
| **Primary** (أخضر داكن — خلفية النص) | Teal Green | `#0D5C63` |
| **Primary Dark** | Deep Teal | `#094147` |
| **Secondary** (برتقالي — العربة والنص) | Vibrant Orange | `#E8611A` |
| **Secondary Light** | Light Orange | `#F28C28` |
| **Accent** (أخضر فاتح — السهم) | Fresh Green | `#4CAF50` |
| **Background** | Off White | `#F5F5F5` |
| **Surface** | White | `#FFFFFF` |
| **On Primary** | White | `#FFFFFF` |
| **On Secondary** | White | `#FFFFFF` |
| **Error** | Red | `#D32F2F` |
| **Text Primary** | Dark Gray | `#212121` |
| **Text Secondary** | Medium Gray | `#757575` |

---

## 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Database
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.1
  # State Management
  flutter_bloc: ^9.1.0
  equatable: ^2.0.7
  # Dependency Injection
  get_it: ^8.0.3
  # UI
  intl: ^0.20.2
  flutter_slidable: ^3.1.1
  shimmer: ^3.0.0
  fl_chart: ^0.70.2
  # Utils
  uuid: ^4.5.1
  share_plus: ^11.0.0
  file_picker: ^9.2.3
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## 🏗️ Architecture Overview

```
lib/
├── core/
│   ├── database/
│   │   ├── database_helper.dart         # SQLite init + migrations
│   │   └── database_tables.dart         # Table names & SQL constants
│   ├── constants/
│   │   └── app_constants.dart           # ثوابت التطبيق
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── number_utils.dart
│   │   └── input_validators.dart
│   ├── services/
│   │   └── service_locator.dart         # get_it setup
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       └── app_text_styles.dart
│
├── features/
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── dashboard_cubit.dart
│   │       │   └── dashboard_state.dart
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── stat_card.dart
│   │           ├── today_sales_card.dart
│   │           ├── low_stock_card.dart
│   │           └── debts_card.dart
│   │
│   ├── products/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── product_model.dart
│   │   │   │   └── product_unit_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── product_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── product_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── product.dart
│   │   │   │   └── product_unit.dart
│   │   │   ├── repositories/
│   │   │   │   └── product_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_products.dart
│   │   │       ├── add_product.dart
│   │   │       ├── update_product.dart
│   │   │       └── search_products.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── product_cubit.dart
│   │       │   └── product_state.dart
│   │       ├── screens/
│   │       │   ├── products_screen.dart
│   │       │   └── add_edit_product_screen.dart
│   │       └── widgets/
│   │           ├── product_card.dart
│   │           ├── product_search_bar.dart
│   │           └── unit_input_widget.dart
│   │
│   ├── customers/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── customer_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── customer_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── customer_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── customer.dart
│   │   │   ├── repositories/
│   │   │   │   └── customer_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_customers.dart
│   │   │       ├── add_customer.dart
│   │   │       ├── update_customer.dart
│   │   │       └── search_customers.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── customer_cubit.dart
│   │       │   └── customer_state.dart
│   │       ├── screens/
│   │       │   ├── customers_screen.dart
│   │       │   └── add_edit_customer_screen.dart
│   │       └── widgets/
│   │           ├── customer_card.dart
│   │           └── customer_search_bar.dart
│   │
│   ├── sales/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── invoice_model.dart
│   │   │   │   ├── invoice_item_model.dart
│   │   │   │   └── last_price_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── invoice_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── invoice_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── invoice.dart
│   │   │   │   ├── invoice_item.dart
│   │   │   │   └── last_price.dart
│   │   │   ├── repositories/
│   │   │   │   └── invoice_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_invoice.dart
│   │   │       ├── get_invoices.dart
│   │   │       ├── get_invoice_details.dart
│   │   │       └── get_last_price.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── invoice_cubit.dart
│   │       │   ├── invoice_state.dart
│   │       │   ├── new_invoice_cubit.dart
│   │       │   └── new_invoice_state.dart
│   │       ├── screens/
│   │       │   ├── invoices_screen.dart
│   │       │   ├── new_invoice_screen.dart
│   │       │   └── invoice_details_screen.dart
│   │       └── widgets/
│   │           ├── invoice_card.dart
│   │           ├── invoice_item_row.dart
│   │           ├── customer_selector.dart
│   │           ├── product_selector_sheet.dart
│   │           └── payment_type_selector.dart
│   │
│   ├── stock/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── stock_purchase_model.dart
│   │   │   │   └── stock_movement_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── stock_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── stock_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── stock_purchase.dart
│   │   │   │   └── stock_movement.dart
│   │   │   ├── repositories/
│   │   │   │   └── stock_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_stock_purchase.dart
│   │   │       ├── get_stock_movements.dart
│   │   │       └── calculate_weighted_avg_cost.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── stock_cubit.dart
│   │       │   └── stock_state.dart
│   │       ├── screens/
│   │       │   └── stock_entry_screen.dart
│   │       └── widgets/
│   │           ├── unit_qty_input.dart
│   │           └── stock_entry_form.dart
│   │
│   ├── collections/          # Phase 2
│   ├── reports/              # Phase 3
│   └── backup/               # Phase 4
│
├── shared/
│   └── widgets/
│       ├── app_bottom_nav.dart
│       ├── app_search_bar.dart
│       ├── empty_state_widget.dart
│       ├── loading_widget.dart
│       ├── confirm_dialog.dart
│       └── amount_display.dart
│
└── main.dart
```

---

## 🗄️ Database Schema

### جدول `products`
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  base_unit TEXT NOT NULL DEFAULT 'قطعة',
  low_stock_threshold INTEGER NOT NULL DEFAULT 10,
  stock_qty INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);
```

### جدول `product_units`
```sql
CREATE TABLE product_units (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  unit_name TEXT NOT NULL,
  conversion_factor INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

> **مثال:** منتج "بيبسي" — base_unit = "زجاجة"
> - قطعة → conversion_factor = 1
> - باكو → conversion_factor = 10
> - كرتونة → conversion_factor = 120

### جدول `customers`
```sql
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  region TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);
```

### جدول `invoices`
```sql
CREATE TABLE invoices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_number TEXT NOT NULL UNIQUE,
  customer_id INTEGER NOT NULL,
  invoice_date TEXT NOT NULL,
  total_amount REAL NOT NULL DEFAULT 0,
  paid_amount REAL NOT NULL DEFAULT 0,
  remaining REAL NOT NULL DEFAULT 0,
  payment_type TEXT NOT NULL DEFAULT 'cash',  -- cash / credit
  status TEXT NOT NULL DEFAULT 'active',      -- active / cancelled
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
```

### جدول `invoice_items`
```sql
CREATE TABLE invoice_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  qty_units INTEGER NOT NULL,         -- بأصغر وحدة دائماً
  unit_id INTEGER,                    -- الوحدة المختارة (للعرض)
  display_qty REAL,                   -- الكمية كما أدخلها المندوب (للعرض)
  unit_price REAL NOT NULL,           -- سعر الوحدة المختارة
  cost_at_sale REAL NOT NULL,         -- Weighted Avg Cost وقت البيع
  line_total REAL NOT NULL,
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

### جدول `collections` (Phase 2)
```sql
CREATE TABLE collections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL,
  invoice_id INTEGER,
  amount REAL NOT NULL,
  collect_date TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (invoice_id) REFERENCES invoices(id)
);
```

### جدول `stock_purchases`
```sql
CREATE TABLE stock_purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  qty_units INTEGER NOT NULL,         -- بأصغر وحدة
  cost_per_unit REAL NOT NULL,        -- تكلفة أصغر وحدة
  purchase_date TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

### جدول `last_prices`
```sql
CREATE TABLE last_prices (
  product_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  unit_id INTEGER,
  last_price REAL NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  PRIMARY KEY (product_id, customer_id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
```

### جدول `stock_movements`
```sql
CREATE TABLE stock_movements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  type TEXT NOT NULL,                  -- purchase / sale / cancel_invoice / manual_adjustment
  qty INTEGER NOT NULL,               -- موجب للداخل، سالب للخارج
  reference_id INTEGER,               -- invoice_id أو purchase_id
  created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

---

## 📊 Business Logic — قواعد العمل الهامة

### 1. إدارة المخزون
- **التخزين:** المخزون يُخزن دائماً بأصغر وحدة (base_unit)
- **الشراء:** عند إدخال شراء بوحدة كبيرة → يتم ضرب الكمية × `conversion_factor` ← يُخزن بأصغر وحدة
- **البيع:** عند البيع بأي وحدة → يتم ضرب الكمية × `conversion_factor` ← يُخصم من `stock_qty`

### 2. حساب التكلفة (Weighted Average Cost)
```
WAC = (المخزون_الحالي × التكلفة_القديمة + الكمية_الجديدة × تكلفة_الجديدة)
      ÷ (المخزون_الحالي + الكمية_الجديدة)
```
- يتم حساب WAC عند كل عملية شراء جديدة
- يُحفظ `cost_at_sale` في `invoice_items` لحظة البيع

### 3. آخر سعر بيع
- عند إنشاء فاتورة واختيار منتج + عميل → يُقترح آخر سعر بيع من جدول `last_prices`
- عند حفظ الفاتورة → يتم تحديث `last_prices` لكل (product_id, customer_id)

### 4. رقم الفاتورة
- Auto-increment بالصيغة: `INV-YYYYMMDD-XXX` (مثال: `INV-20260625-001`)

---

## 🚀 خطة التنفيذ — 4 مراحل

---

### Phase 1 — MVP (تشغيل المبيعات) ≈ ~85 ملف

> [!IMPORTANT]
> هذه المرحلة تشمل كل ما يحتاجه المندوب لبدء العمل الفعلي

#### Step 1.1 — Core Setup
| # | الملف | الوصف |
|---|---|---|
| 1 | `core/database/database_helper.dart` | إنشاء قاعدة البيانات + جميع الجداول + migrations |
| 2 | `core/database/database_tables.dart` | ثوابت أسماء الجداول والأعمدة |
| 3 | `core/constants/app_constants.dart` | ثوابت عامة |
| 4 | `core/theme/app_colors.dart` | ألوان التطبيق (من اللوجو) |
| 5 | `core/theme/app_theme.dart` | ThemeData كامل |
| 6 | `core/theme/app_text_styles.dart` | أنماط النصوص |
| 7 | `core/utils/date_utils.dart` | دوال تنسيق التاريخ |
| 8 | `core/utils/number_utils.dart` | تنسيق الأرقام والمبالغ |
| 9 | `core/utils/input_validators.dart` | التحقق من صحة المدخلات |
| 10 | `core/services/service_locator.dart` | إعداد get_it |
| 11 | `shared/widgets/` | Widgets مشتركة (6 ملفات) |
| 12 | `main.dart` | نقطة البداية + BlocProviders |
| 13 | `pubspec.yaml` | إضافة المكتبات |

#### Step 1.2 — Products Feature
| # | الملف | الوصف |
|---|---|---|
| 1 | `products/domain/entities/product.dart` | Entity |
| 2 | `products/domain/entities/product_unit.dart` | Entity |
| 3 | `products/domain/repositories/product_repository.dart` | Abstract Repository |
| 4 | `products/domain/usecases/*.dart` | 4 Use Cases |
| 5 | `products/data/models/product_model.dart` | Model + toMap/fromMap |
| 6 | `products/data/models/product_unit_model.dart` | Model |
| 7 | `products/data/datasources/product_local_datasource.dart` | CRUD SQLite |
| 8 | `products/data/repositories/product_repository_impl.dart` | Implementation |
| 9 | `products/presentation/cubit/product_cubit.dart` | State management |
| 10 | `products/presentation/cubit/product_state.dart` | States |
| 11 | `products/presentation/screens/products_screen.dart` | قائمة + بحث |
| 12 | `products/presentation/screens/add_edit_product_screen.dart` | إضافة/تعديل |
| 13 | `products/presentation/widgets/*.dart` | 3 Widgets |

#### Step 1.3 — Customers Feature
| # | الملف | الوصف |
|---|---|---|
| 1-13 | نفس هيكل Products | بنفس النمط |

#### Step 1.4 — Stock Feature
| # | الملف | الوصف |
|---|---|---|
| 1 | Stock entities + models | purchase + movement |
| 2 | Stock datasource | إدخال شراء + حركات |
| 3 | Stock repository | Implementation |
| 4 | Use Cases | add_purchase + calculate_WAC + get_movements |
| 5 | Stock Cubit | State management |
| 6 | Stock Entry Screen | شاشة إدخال المخزون |

#### Step 1.5 — Sales Feature (الأهم)
| # | الملف | الوصف |
|---|---|---|
| 1 | Invoice entities | invoice + invoice_item + last_price |
| 2 | Invoice models | toMap/fromMap |
| 3 | Invoice datasource | CRUD + حفظ + خصم مخزون |
| 4 | Invoice repository | Implementation |
| 5 | Use Cases | create + list + details + last_price |
| 6 | New Invoice Cubit | إدارة حالة إنشاء الفاتورة |
| 7 | Invoice List Cubit | قائمة الفواتير |
| 8 | New Invoice Screen | شاشة إنشاء فاتورة جديدة |
| 9 | Invoice Details Screen | عرض تفاصيل فاتورة |
| 10 | Invoices List Screen | قائمة الفواتير |
| 11 | Widgets | customer_selector, product_selector_sheet, payment_type |

#### Step 1.6 — Dashboard
| # | الملف | الوصف |
|---|---|---|
| 1 | Dashboard Cubit | حساب الإحصائيات |
| 2 | Dashboard Screen | عرض الإحصائيات |
| 3 | Stat Widgets | كروت الإحصائيات (4 widgets) |

#### Step 1.7 — Navigation Shell
| # | الملف | الوصف |
|---|---|---|
| 1 | `app_bottom_nav.dart` | Bottom Navigation (5 tabs) |
| 2 | `main_shell.dart` | Shell wrapper |

---

### Phase 2 — التحصيلات وتفاصيل العملاء

| الشاشة | الوصف |
|---|---|
| Collections Screen | تسجيل تحصيل جديد |
| Customer Details Screen | فواتير + تحصيلات + مديونية العميل |
| Stock Movements Screen | كشف حركة المخزون لكل منتج |
| Invoice Cancellation | إلغاء فاتورة + إرجاع المخزون |

---

### Phase 3 — التقارير

| التقرير | الوصف |
|---|---|
| مبيعات اليوم / الشهر | إجمالي المبيعات حسب الفترة |
| أرباح الشهر | إجمالي الأرباح (بيع - تكلفة) |
| أفضل المنتجات مبيعاً | ترتيب حسب الكمية أو القيمة |
| المنتجات الراكدة | بدون حركة لفترة محددة |
| العملاء الأكثر شراءً | ترتيب حسب قيمة المشتريات |
| العملاء المتأخرون | مديونيات قديمة |
| تقرير المخزون | الأرصدة الحالية + التقييم |

---

### Phase 4 — النسخ الاحتياطي

| الميزة | الوصف |
|---|---|
| Backup | نسخ ملف `app.db` بالكامل |
| Restore | استعادة من نسخة احتياطية |
| Share | مشاركة النسخة عبر التطبيقات |

---

## 🎯 UX Design Guidelines

### Bottom Navigation
```
┌───────────────────────────────────────────────┐
│  🏠         📦         ➕         👥         📊  │
│ الرئيسية   المنتجات   بيع جديد   العملاء   التقارير │
└───────────────────────────────────────────────┘
```

### تصميم الكروت
- **Cards بزوايا مدورة** (radius: 16) مع ظل خفيف
- **Gradient headers** باللون الأخضر الداكن (Primary)
- **أيقونات برتقالية** (Secondary) للأزرار والأرقام المهمة
- **نص عربي بخط Cairo** من Google Fonts
- **RTL layout** بالكامل

### الشاشة الرئيسية
- 4 كروت إحصائيات في أعلى الشاشة (2×2 grid)
- قائمة المنتجات الناقصة أسفلها
- زر FAB لإنشاء فاتورة سريعة

### إنشاء فاتورة
- Bottom Sheet لاختيار العميل (مع بحث)
- Bottom Sheet لإضافة منتج (مع بحث)
- اقتراح آخر سعر بيع تلقائياً
- ملخص الفاتورة مباشر أثناء الإدخال
- اختيار الوحدة (كرتونة/باكو/قطعة) مع حساب تلقائي

---

## ⚠️ User Review Required

> [!IMPORTANT]
> **اتجاه التطبيق (RTL):** التطبيق سيكون بالعربية بالكامل مع دعم RTL. هل تريد إضافة دعم للإنجليزية لاحقاً؟

> [!IMPORTANT]
> **الخط العربي:** سأستخدم خط **Cairo** من Google Fonts. هل لديك تفضيل لخط آخر؟

> [!IMPORTANT]
> **رقم الفاتورة:** سأستخدم الصيغة `INV-YYYYMMDD-XXX`. هل تريد صيغة مختلفة؟

---

## Open Questions

> [!WARNING]
> **حذف المنتجات:** هل نسمح بحذف منتج إذا كان مرتبط بفواتير سابقة؟ أقترح **soft delete** أو منع الحذف مع رسالة توضيحية.

> [!WARNING]
> **تعديل الفاتورة:** هل نسمح بتعديل فاتورة محفوظة؟ أم فقط إلغاء وإعادة إنشاء؟ أقترح **إلغاء فقط** (أبسط وأدق محاسبياً).

---

## Verification Plan

### Automated Tests
```bash
flutter analyze
flutter test
```

### Manual Verification
- إنشاء منتجات مع وحدات متعددة
- إدخال مشتريات والتحقق من المخزون
- إنشاء فواتير والتحقق من:
  - خصم المخزون الصحيح
  - حساب WAC الصحيح
  - اقتراح آخر سعر بيع
  - حساب الأرباح
- التحقق من إحصائيات الداشبورد



