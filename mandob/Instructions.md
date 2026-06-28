# Development Guidelines & Constraints

## State Management

* استخدام Cubit فقط.
* ممنوع استخدام `setState()` لإدارة Business Logic أو البيانات.
* `setState()` مسموح فقط للحالات البسيطة جدًا الخاصة بالـ UI المحلي (مثلاً إظهار/إخفاء Password أو تغيير Tab داخلي).
* جميع البيانات القادمة من SQLite يجب أن تمر عبر Cubit.

---

## Architecture

* الالتزام بـ Clean Architecture.
* ممنوع استدعاء SQLite مباشرة من UI.
* ممنوع كتابة SQL داخل Screens.
* جميع عمليات القراءة والكتابة تمر عبر:

  * DataSource
  * Repository
  * Cubit

---

## Database

* استخدام Migrations من البداية.
* عدم حذف أو تعديل الجداول مباشرة بين الإصدارات.
* تجهيز Versioning لقاعدة البيانات.

مثال:

```dart
version: 1
```

حتى يمكن إضافة أعمدة أو جداول لاحقًا بدون كسر البيانات.

---

## IDs

* استخدام Integer Auto Increment.
* عدم الاعتماد على اسم المنتج أو العميل كمفتاح.

---

## Inventory

### مهم جداً

المخزون لا يتم تعديله مباشرة.

ممنوع:

```dart
product.stock--;
```

كل حركة مخزون يجب أن تنشئ Record داخل:

```text
stock_movements
```

ثم يتم تحديث الرصيد.

حتى يمكن تتبع أي خطأ مستقبلاً.

---

## Invoice Rules

### بعد حفظ الفاتورة

لا يتم تعديلها.

المتاح فقط:

```text
إلغاء الفاتورة
```

Cancellation

لأن تعديل الفواتير بعد خصم المخزون والتحصيلات يسبب مشاكل كثيرة.

---

## Transactions

أي عملية تشمل أكثر من جدول يجب تنفيذها داخل Transaction.

مثال إنشاء فاتورة:

```text
1. إنشاء Invoice
2. إنشاء Invoice Items
3. خصم المخزون
4. إنشاء Stock Movement
5. تحديث Last Price
```

لو فشل أي جزء:

```text
Rollback
```

لكل العملية.

---

## Profit Calculations

عدم حساب الأرباح داخل UI.

يتم الحساب داخل:

```text
Repository
Service
UseCase
```

فقط.

---

## Reports

ممنوع تحميل جميع البيانات في الذاكرة ثم الفلترة.

مثال سيئ:

```dart
final invoices = await getAllInvoices();

invoices.where(...)
```

الأفضل:

```sql
SELECT ...
WHERE ...
GROUP BY ...
```

داخل SQLite.

---

## Performance

* استخدام Pagination أو Lazy Loading عند الحاجة.
* عدم إعادة تحميل كل البيانات بعد كل عملية حفظ.
* تحديث الجزء المتأثر فقط.

---

## Models

يفضل استخدام:

```text
Freezed
Json Serializable
```

بدلاً من كتابة Models يدويًا.

---

## Dependency Injection

استخدام:

```text
get_it
```

لكل:

* Repositories
* Services
* Cubits

عدم إنشاء Objects مباشرة داخل Screens.

---

## Error Handling

ممنوع:

```dart
catch (e) {}
```

أو

```dart
print(e);
```

يجب وجود Error Handling واضح ورسائل مناسبة للمستخدم.

---

## Backup

أثناء Backup أو Restore:

* إغلاق قاعدة البيانات أولاً.
* تنفيذ العملية.
* إعادة فتح القاعدة.

حتى لا يحدث Corrupted Database.

---

## Testing

### Test Scenarios

* إنشاء فاتورة كاش.
* إنشاء فاتورة آجل.
* إلغاء فاتورة.
* تسجيل تحصيل.
* شراء مخزون جديد.
* بيع كمية أكبر من المخزون.
* استعادة Backup.

---

## Code Quality

* عدم استخدام ملفات ضخمة.
* كل Feature مستقلة.
* عدم إنشاء Cubit واحد للتطبيق بالكامل.
* Cubit لكل Feature.

مثال:

```text
ProductsCubit

CustomersCubit

InvoiceCubit

CollectionCubit

ReportsCubit

BackupCubit
```

---

## Critical Rules

### أهم 3 نقاط يجب الالتزام بها

1. استخدام SQLite Transactions في إنشاء الفواتير والتحصيلات.
2. عدم تعديل المخزون مباشرة بدون Stock Movements.
3. عدم استخدام setState لإدارة البيانات، والاعتماد بالكامل على Cubit.

الالتزام بهذه النقاط من البداية يمنع معظم المشاكل الشائعة في تطبيقات المخزون والمبيعات.
