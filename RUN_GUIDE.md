# 🚀 دليل تشغيل المشروع من الصفر

هذا الدليل لأي مرة تسكر فيها المشروع أو تمسحه وتحتاج تشغّله من جديد.

---

## الحالة 1: المشروع لسا موجود بجهازك (بس مقفول)

1. افتح **VS Code**
2. من `File > Open Folder`، افتح مجلد المشروع (`ai_chatbot`)
3. افتح Terminal جديد (`` Ctrl+` ``)
4. شغّل بالترتيب:

```bash
flutter clean
flutter pub get
flutter run
```

5. وصّل موبايلك بـ USB (تأكد إن USB Debugging مفعّل) وانتظر لين يفتح التطبيق.

---

## الحالة 2: مسحت المشروع بالكامل ولازم تبنيه من الصفر

### المتطلبات الأساسية (تأكد منها أول مرة بس)
```bash
flutter doctor
```
تأكد ما فيه علامات ❌ حرجة (خصوصاً بـ Android toolchain).

### الخطوات

1. **فك ضغط ملف المشروع** (لو عندك نسخة zip محفوظة) بمكان زي سطح المكتب:
```bash
unzip ai_chatbot.zip -d ai_chatbot
cd ai_chatbot
```

2. **ولّد ملفات المنصات** (Android/iOS) لو مو موجودة:
```bash
flutter create .
```

3. **ثبّت الحزم**:
```bash
flutter pub get
```

4. **جهّز مفتاح Gemini API**:
```bash
cp .env.example .env
```
افتح `.env` وحط مفتاحك:
```
GEMINI_API_KEY=مفتاحك_هون
```
(احصل على مفتاح مجاني من [aistudio.google.com/apikey](https://aistudio.google.com/apikey))

5. **ولّد أيقونة التطبيق** (لو حاطط صورة بـ `assets/app_icon.png`):
```bash
dart run flutter_launcher_icons
```

6. **شغّل التطبيق**:
```bash
flutter clean
flutter run
```

---

## ⚠️ لو ما اشتغل من أول مرة

| المشكلة | الحل السريع |
|---|---|
| `flutter devices` ما يطلع الجهاز | تأكد USB Debugging مفعّل ووصلت كيبل بيانات (مو شحن بس) |
| "Developer Mode" تحذير بويندوز | شغّل: `start ms-settings:developers` وفعّله |
| "Could not find package" | تأكد الحزمة مضافة صح بـ `pubspec.yaml` وشغّل `flutter pub get` |
| مفتاح API ما اشتغل | تأكد ملف `.env` محفوظ وفيه المفتاح بدون مسافات أو علامات تنصيص |
| الأيقونة القديمة ضلت ظاهرة | امسح التطبيق من الموبايل بالكامل وثبّته من جديد |

---

## 💾 نصيحة: احتفظ بنسخة احتياطية

بعد ما يشتغل التطبيق تمام، اعمل نسخة zip من المجلد كامل (ما عدا `build/` و`.dart_tool/`) واحفظها بمكان آمن (Google Drive مثلاً)، عشان لو صار أي مشكلة تقدر ترجعله بسرعة بدل ما تعيد كل الخطوات.

```bash
# مثال لعمل نسخة احتياطية (من داخل مجلد المشروع)
flutter clean
cd ..
zip -r ai_chatbot_backup.zip ai_chatbot -x "ai_chatbot/.git/*"
```
