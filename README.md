# OKS QR Mobile

Мобильное приложение на Flutter для **OKS Group** — контроль допуска на строительные объекты. Поддерживаются две роли:

- **Worker (работник)** — просмотр назначенных объектов, показ QR-пропуска, история посещений, документы профиля.
- **Guard (охранник)** — сканирование QR-кодов работников на КПП и выдача или отказ в допуске.

Код организован по **Feature-Sliced Design (FSD)**: слои разделены по зонам ответственности (`app`, `entities`, `features`, `screens`, `shared`).

---

## Стек технологий

| Категория | Пакет / инструмент |
|---|---|
| Фреймворк | Flutter (Dart SDK ^3.12) |
| Маршрутизация | `go_router` |
| Состояние | `provider` (`ChangeNotifier`) |
| Генерация QR | `qr_flutter` |
| Сканирование QR | `mobile_scanner` |
| SVG-ресурсы | `flutter_svg` |
| Форматирование дат | `intl` |

---

## Навигация

```
/                          → RoleSelectionScreen
/guard                     → GuardMainScreen
/guard/scanner             → GuardScannerScreen
/worker                    → WorkerMainScreen
/worker/object/:id         → ObjectDetailsScreen
```

---

## Обзор архитектуры

```
lib/
├── main.dart                 # Точка входа приложения
├── app/                      # Оболочка приложения (тема, роутер, корневой виджет)
├── entities/                 # Доменные модели и mock-репозитории
├── features/                 # Пользовательские возможности (QR, профиль, допуск и т.д.)
├── screens/                  # Полноэкранные маршруты
└── shared/                   # Переиспользуемые UI-компоненты и константы
```

Данные сейчас поступают из **mock-репозиториев** в `entities/*/repository/`. Реальный backend пока не подключён.

---

## Справочник файлов

Ниже перечислены все исходные файлы проекта: для каждого указан основной тип (класс, enum, функция) и краткое описание назначения и принципа работы.

### Корень проекта

| Файл | Объект | Описание |
|---|---|---|
| `lib/main.dart` | — | Точка входа приложения; вызывает `runApp(OksQrApp)` и запускает Flutter-дерево виджетов. |
| `pubspec.yaml` | — | Метаданные проекта, зависимости и список подключаемых ресурсов (assets). |
| `analysis_options.yaml` | — | Настройки анализатора Dart и правил линтинга. |
| `test/widget_test.dart` | — | Дымовой тест: монтирует `OksQrApp` и проверяет, что экран выбора роли отображается. |

---

### `lib/app/` — Слой приложения

| Файл | Объект | Описание |
|---|---|---|
| `app/app.dart` | `OksQrApp` | Корневой виджет: оборачивает приложение в `ChangeNotifierProvider<LanguageNotifier>` и настраивает `MaterialApp.router`. |
| `app/router/app_router.dart` | `appRouter` | Экземпляр `GoRouter` — описывает все маршруты и параметры пути (`:id` и т.д.). |
| `app/theme/app_theme.dart` | `AppTheme` | Светлая тема `ThemeData`, собранная из дизайн-токенов (цвета, радиусы, типографика). |
| `app/theme/app_colors.dart` | `AppColors` | Централизованная палитра цветов (navy, жёлтый, статусы green/red, фоны и т.д.). |
| `app/theme/app_spacing.dart` | `AppSpacing` | Шкала отступов (`xs`–`xxxl`). |
| `app/theme/app_radius.dart` | `AppRadius` | Токены скругления углов (`sm`–`pill`). |

---

### `lib/entities/` — Доменный слой

#### `construction_object/` — строительный объект

| Файл | Объект | Описание |
|---|---|---|
| `model/construction_object.dart` | `ConstructionObject` | Основная доменная модель объекта строительства: название, адрес, статусы, документы, payload для QR. |
| `model/access_status.dart` | `AccessStatus` | Enum допуска: `granted` / `denied`; содержит локализованные подписи (RU/KZ). |
| `model/object_status.dart` | `ObjectStatus` | Enum статуса объекта: `underConstruction` / `completed`; содержит локализованные подписи. |
| `model/object_document.dart` | `ObjectDocument` | Прикреплённый к объекту файл (id, имя файла, дата загрузки). |
| `repository/mock_object_repository.dart` | `MockObjectRepository` | Singleton с mock-данными объектов; методы `findById` и `getAccessibleObjects` для выборки. |

#### `user_profile/` — профиль пользователя

| Файл | Объект | Описание |
|---|---|---|
| `model/user_profile.dart` | `UserProfile` | Профиль работника: ФИО, компания, ИИН, телефон, список документов. |
| `model/personal_document.dart` | `PersonalDocument` | Метаданные личного документа (id, имя файла, дата загрузки). |
| `repository/mock_user_repository.dart` | `MockUserRepository` | Singleton с mock-профилем работника; используется в worker- и guard-потоках. |

#### `worker/` — отсканированный работник

| Файл | Объект | Описание |
|---|---|---|
| `model/scanned_worker.dart` | `ScannedWorker` | Данные работника после сканирования QR охранником: имя, компания, ИИН, телефон, объект. |

#### `visit_history/` — история посещений

| Файл | Объект | Описание |
|---|---|---|
| `model/visit_record.dart` | `VisitRecord` | Запись одного посещения: объект, адрес, время, результат (допуск / отказ). |
| `repository/mock_visit_repository.dart` | `MockVisitRepository` | Singleton со списком mock-записей посещений для вкладки «История» работника. |

#### `service_type/` — тип сервиса

| Файл | Объект | Описание |
|---|---|---|
| `model/service_type.dart` | `ServiceType` | Enum роли: `worker` / `guard`; хранит заголовок, описание и маршрут для экрана выбора сервиса. |

---

### `lib/features/` — Слой фич

#### `access_confirmation/` — подтверждение допуска

| Файл | Объект | Описание |
|---|---|---|
| `widgets/confirm_access_sheet.dart` | `ConfirmAccessSheet`, `_InfoRow` | Bottom sheet после успешного сканирования QR: данные работника и кнопки «Допуск» / «Отказ». |
| `widgets/success_dialog.dart` | `SuccessDialog` | Модальный диалог об успешной выдаче допуска работнику. |
| `widgets/denial_dialog.dart` | `DenialDialog` | Модальный диалог отказа в допуске с полем для указания причины. |
| `widgets/reject_dialog.dart` | `RejectDialog` | Модальный диалог при недействительном или отклонённом QR-коде. |

#### `language_switcher/` — переключение языка

| Файл | Объект | Описание |
|---|---|---|
| `language_notifier.dart` | `AppLanguage`, `LanguageNotifier` | `ChangeNotifier` с текущим языком приложения (`ru` / `kz`); переключается из нижней панели worker-экрана. |

#### `profile/` — профиль

| Файл | Объект | Описание |
|---|---|---|
| `widgets/profile_sheet.dart` | `ProfileSheet` | Перетаскиваемый bottom sheet с данными профиля работника и списком личных документов. |

#### `qr_display/` — отображение QR

| Файл | Объект | Описание |
|---|---|---|
| `widgets/qr_pass_sheet.dart` | `QrPassSheet` | Bottom sheet с QR-кодом пропуска для выбранного строительного объекта. |
| `widgets/object_select_sheet.dart` | `YellowActionButton`, `ObjectSelectTile` | Жёлтая кнопка действия и строка выбора объекта при открытии QR-пропуска. |

#### `qr_scanning/` — сканирование QR

| Файл | Объект | Описание |
|---|---|---|
| `api/mock_scan_api.dart` | `ScanApiResult`, `MockScanApi` | Mock-API: имитирует проверку QR-кода и возвращает `ScannedWorker` с задержкой. |
| `widgets/scan_overlay.dart` | `ScanOverlay`, `_ScannerMaskPainter`, `_ScannerCornerPainter` | Оверлей камеры: затемнение, прозрачная область сканирования, жёлтые угловые акценты и подсказка. |

#### `service_switcher/` — переключатель сервиса

| Файл | Объект | Описание |
|---|---|---|
| `widgets/service_switcher.dart` | `ServiceSwitcher`, `_ServiceToggleButton` | Переключатель кран/шлагбаум на экране выбора роли (Worker / Guard). |

---

### `lib/screens/` — Слой экранов

| Файл | Объект | Описание |
|---|---|---|
| `role_selection/role_selection_screen.dart` | `RoleSelectionScreen` | Стартовый экран: переключатель сервиса, иконка-герой, описание и кнопка «Перейти». |
| `guard/guard_main_screen.dart` | `GuardMainScreen` | Главный экран охранника: назначенный объект и кнопка перехода к сканеру QR. |
| `guard/guard_scanner_screen.dart` | `GuardScannerScreen` | Полноэкранный сканер камеры (`MobileScanner`); цепочка: скан → подтверждение → допуск/отказ. |
| `worker/worker_main_screen.dart` | `WorkerMainScreen`, `_ObjectSelectBottomSheet`, `_VisitCard` | Главный экран работника: вкладки «Объекты» / «История», нижняя панель, профиль и QR. |
| `worker/object_details_screen.dart` | `ObjectDetailsScreen`, `_ObjectSelectBottomSheet` | Детальная страница объекта: статус, даты, документы, доступ к QR-пропуску. |

---

### `lib/shared/` — Общий слой

#### `constants/`

| Файл | Объект | Описание |
|---|---|---|
| `constants/app_assets.dart` | `AppAssets` | Константы путей к ресурсам: кран, шлагбаум, QR, профиль. |

#### `ui/`

| Файл | Объект | Описание |
|---|---|---|
| `ui/object_card.dart` | `ObjectCard` | Серая информационная карточка объекта: иконка, название, адрес, бейдж допуска, chevron. |
| `ui/status_badge.dart` | `StatusBadge` | Индикатор статуса допуска (зелёная галочка / красный крест + локализованная подпись). |
| `ui/oks_header.dart` | `OksGroupLogo`, `OksHeader` | Фирменный логотип OKS Group и заголовок экрана с опциональным подзаголовком. |
| `ui/app_asset_icon.dart` | `AppAssetIcon` | Универсальный рендер SVG/PNG с опциональной перекраской и fallback на Material Icons. |
| `ui/app_primary_button.dart` | `AppPrimaryButton` | Основная тёмная кнопка на всю ширину (экран выбора роли). |
| `ui/app_bottom_sheet_shell.dart` | `AppBottomSheetShell`, `showAppModalBottomSheet` | Обёртка для перетаскиваемых bottom sheet и хелпер открытия модальных листов. |
| `ui/floating_bottom_bar.dart` | `FloatingBottomBar`, `_CircleIconButton` | Плавающая нижняя панель worker-экрана: профиль, QR, переключение языка. |
| `ui/segment_tabs.dart` | `SegmentTabs` | Анимированные сегментированные вкладки с «пилюлей» (Объекты / История). |
| `ui/icon_circle_button.dart` | `IconCircleButton` | Круглая кнопка с иконкой (заголовок сканера, экран деталей). |
| `ui/detail_row.dart` | `DetailRow` | Строка «метка + значение» для полей детальной информации об объекте. |
| `ui/document_tile.dart` | `DocumentTile` | Строка файла: имя, дата загрузки, опциональное действие скачивания. |

---

### `assets/` — Статические ресурсы

| Файл | Объект | Описание |
|---|---|---|
| `assets/crane.svg` | Иконка крана | Иконка строительства / worker-сервиса. |
| `assets/barrier.svg` | Иконка шлагбаума | Иконка охраны / guard-сервиса (КПП). |
| `assets/icon_qr.png` | Иконка QR | PNG-иконка для кнопок, связанных с QR-кодом. |
| `assets/icon_profile.png` | Иконка профиля | PNG-иконка кнопки профиля в нижней панели. |

---

### `android/` — Платформа Android

| Файл | Объект | Описание |
|---|---|---|
| `android/app/build.gradle.kts` | — | Gradle-конфигурация модуля app: версии SDK, ProGuard для release, зависимость ML Kit для штрихкодов. |
| `android/app/proguard-rules.pro` | — | Правила ProGuard для Google ML Kit barcode scanning в release-сборках. |
| `android/app/src/main/AndroidManifest.xml` | — | Манифест: разрешение камеры, meta-data ML Kit barcode, launcher activity. |
| `android/app/src/main/kotlin/com/oksgroup/oks_qr_mobile/MainActivity.kt` | `MainActivity` | Точка входа Flutter embedding на Android. |
| `android/app/src/main/res/values/styles.xml` | — | Светлая тема запуска (splash). |
| `android/app/src/main/res/values-night/styles.xml` | — | Тёмная тема запуска (splash). |
| `android/app/src/main/res/drawable/launch_background.xml` | — | Фон splash-экрана (API < 21). |
| `android/app/src/main/res/drawable-v21/launch_background.xml` | — | Фон splash-экрана (API 21+). |
| `android/build.gradle.kts` | — | Gradle-конфигурация уровня проекта. |
| `android/settings.gradle.kts` | — | Настройки Gradle и управление плагинами. |

---

## Пользовательские сценарии

### Сценарий работника (Worker)

```
RoleSelectionScreen (Worker)
  → WorkerMainScreen
      ├── Вкладка «Объекты» → список ObjectCard → ObjectDetailsScreen
      ├── Вкладка «История» → карточки посещений
      ├── Нижняя панель: Профиль → ProfileSheet
      ├── Нижняя панель: QR → выбор объекта → QrPassSheet
      └── Нижняя панель: переключение языка (RU ↔ KZ)
```

### Сценарий охранника (Guard)

```
RoleSelectionScreen (Guard)
  → GuardMainScreen
      → GuardScannerScreen
          ├── Скан QR → ConfirmAccessSheet
          ├── Допуск → SuccessDialog
          ├── Отказ → DenialDialog
          └── Недействительный QR → RejectDialog
```

---

## Запуск проекта

```bash
# Установка зависимостей
flutter pub get

# Запуск на подключённом устройстве или эмуляторе
flutter run

# Сборка release APK
flutter clean
flutter build apk --release
```

Release APK сохраняется в: `build/app/outputs/flutter-apk/app-release.apk`

---

## Правила зависимостей слоёв (FSD)

```
screens  →  features, entities, shared, app
features →  entities, shared, app
entities →  (без импортов «вверх»)
shared   →  app (только токены темы)
app      →  features, screens (подключение роутера)
```

**Принцип работы слоёв:**

- **screens** — собирают экраны из features и shared-виджетов, привязаны к маршрутам.
- **features** — инкапсулируют одну пользовательскую возможность (сканирование, профиль, QR и т.д.).
- **entities** — чистые доменные модели и доступ к данным, без UI-зависимостей.
- **shared** — переиспользуемые UI-блоки уровня дизайн-системы.
- **app** — глобальная конфигурация: тема, роутинг, корневой виджет.
