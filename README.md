# OKS QR Mobile

Мобильное приложение **OKS Group** на Flutter для контроля допуска на строительные объекты. Пользователь проходит корпоративную авторизацию через **OKS ID**, получает роль по `permissions` с бэкенда и работает в одном из двух сервисов:

| Роль в приложении | Permission (OKS ID) | Сервис |
|---|---|---|
| **Worker** — работник на объектах | `core:security_staff` | QR-пропуск, список объектов, профиль |
| **Guard** — охранник на КПП | `facilities:manager` | Сканирование QR и выдача/отказ в допуске |

Код организован по **Feature-Sliced Design (FSD)**: слои разделены по зонам ответственности (`app`, `entities`, `features`, `screens`, `shared`).

---

## Стек технологий

| Категория | Пакет / инструмент |
|---|---|
| Фреймворк | Flutter (Dart SDK ^3.12) |
| Маршрутизация | `go_router` |
| Состояние | `provider` (`ChangeNotifier`) |
| HTTP / API | `dio` |
| Безопасное хранение JWT | `flutter_secure_storage` |
| Мониторинг сети | `connectivity_plus` |
| Генерация QR | `qr_flutter` |
| Сканирование QR | `mobile_scanner` |
| SVG-ресурсы | `flutter_svg` |
| Шрифт | Manrope (variable font) |
| Форматирование дат | `intl` |
| Skeleton-загрузка | `shimmer` |

---

## Быстрый старт

```bash
flutter pub get
flutter run
```

Release APK:

```bash
flutter clean
flutter build apk --release
```

Артефакт: `build/app/outputs/flutter-apk/app-release.apk`

### Переменные окружения

| Переменная | Назначение | Значение по умолчанию |
|---|---|---|
| `API_BASE_URL` | Base URL OKS ID API | `https://api.id.oks.group/api/v1` |

Пример:

```bash
flutter run --dart-define=API_BASE_URL=https://api.id.oks.group/api/v1
```

---

## Архитектура

### Слои FSD

```
lib/
├── main.dart              # Точка входа → AppBootstrap
├── app/                   # Тема, роутер, DI, корневой виджет
├── entities/              # Доменные модели и репозитории данных
├── features/              # Бизнес-возможности (auth, profile, QR, …)
├── screens/               # Полноэкранные маршруты (композиция features + shared)
└── shared/                # API-клиент, auth-инфраструктура, UI-кит, утилиты
```

### Правила зависимостей

```
screens  →  features, entities, shared, app
features →  entities, shared, app
entities →  (без импортов «вверх» по слоям)
shared   →  app (только токены темы / конфиг)
app      →  features, screens (сборка роутера и DI)
```

- **screens** — собирают экран из features и shared, привязаны к маршрутам `go_router`.
- **features** — одна пользовательская возможность: auth, profile, qr_display, connectivity и т.д.
- **entities** — чистые модели и доступ к данным без UI.
- **shared** — переиспользуемые компоненты дизайн-системы, Dio, interceptors, secure storage.
- **app** — глобальная конфигурация: тема, роутинг, `AppDependencies`.

### Запуск приложения

```
main.dart
  └── AppBootstrap                    # async-инициализация DI
        └── AppDependencies.init()    # Dio, TokenStorage, AuthRepository, ProfileApi
              └── OksQrApp            # MultiProvider + MaterialApp.router
                    └── OfflineAppShell   # глобальный offline-overlay
```

**Provider-дерево** (`OksQrApp`):

| Provider | Назначение |
|---|---|
| `AuthNotifier` | Состояние авторизации, polling approval |
| `ProfileApi` | `GET /accounts/me/` |
| `TokenStorage` | JWT + pending approval в secure storage |
| `ConnectivityNotifier` | Отслеживание Wi‑Fi / мобильных данных |
| `LanguageNotifier` | Язык интерфейса RU / KZ (worker) |
| `ObjectsNotifier` | Список строительных объектов |

---

## Авторизация (OKS ID)

Интеграция с production API **`https://api.id.oks.group/api/v1`**. Mock-слой отключён — все auth-запросы идут на реальный бэкенд.

### Поток входа

```
AuthScreen                    ApprovalWaitingScreen              RoleSelectionScreen
(ввод телефона)        →      (ожидание admin approval)   →     (Мои сервисы)
     │                              │                                │
     │ POST /auth/phone/approval/   │ GET …/approval/{code}/status/│ GET /accounts/me/
     │                              │ каждые 3 сек                   │ permissions → роль
     │                              │ POST /auth/verify/ (approved)  │
     │                              │ JWT → secure storage           │
```

### Экран ожидания (`ApprovalWaitingScreen`)

**Ожидание (`waitingForApproval`):**

- Шапка `OksHeader`: «Авторизация» слева, OKS Group справа (без кнопки «Назад»).
- Основной текст, номер телефона, подсказка о ~20 минутах ожидания.
- Иллюстрация `builder.svg` + брендированный spinner `load.svg` по центру.

**Отказ (`denied`):**

- Тот же layout шапки и текста об отказе в доступе.
- Иллюстрация с badge `warning.svg`.
- Кнопка **«Вернуться назад»** закреплена внизу экрана → сброс flow и переход на `/`.

Polling останавливается при `authenticated` и `denied`.

### API-эндпоинты auth

| Метод | Путь | Когда вызывается |
|---|---|---|
| `POST` | `/auth/phone/approval/` | Пользователь нажал «Войти» на экране авторизации |
| `GET` | `/auth/approval/{code}/status/` | Polling каждые 3 сек на экране ожидания |
| `POST` | `/auth/verify/` | Статус `approved` — обмен code на JWT |
| `POST` | `/auth/refresh/` | Автоматически при 401 (через interceptor) |
| `GET` | `/accounts/me/` | Профиль и permissions после входа |

Тело verify:

```json
{
  "type": "approval",
  "code": "<approval_code>",
  "refreshTtlDays": 30
}
```

### Состояния `AuthFlowState`

| Состояние | Описание |
|---|---|
| `initial` | Не авторизован |
| `submittingPhone` | Отправка номера на approval |
| `waitingForApproval` | Есть approval code, идёт polling |
| `denied` | Администратор отклонил запрос |
| `authenticated` | JWT сохранены, сессия активна |
| `error` | Сетевая или HTTP-ошибка |

### Защита от перебора

- После **5 неудачных попыток** входа — блокировка на **65 секунд**.
- Обратный отсчёт (`MM:SS`) отображается под сообщением о блокировке на экране авторизации.
- По истечении таймера пользователь может повторить попытку без перезапуска приложения.

### Persistence pending approval

Если пользователь закрыл приложение во время ожидания подтверждения, `(phone, approvalCode)` сохраняются в **flutter_secure_storage**. При следующем запуске приложение восстанавливает состояние `waitingForApproval` и продолжает polling.

### Сетевой слой auth

Два экземпляра **Dio**:

| Клиент | Назначение |
|---|---|
| `publicDio` | Auth-эндпоинты до входа (approval, verify, refresh) |
| `authenticatedDio` | Защищённые запросы с JWT (`ProfileApi` и далее) |

**`AuthInterceptor`** (на `authenticatedDio`):

- Подставляет `Authorization: Bearer <access_token>` ко всем запросам, кроме публичных auth-путей.
- При **401** — прозрачный refresh через `POST /auth/refresh/`.
- Если refresh не удался — logout и `AuthSessionExpiredException`.

Ключевые файлы:

```
lib/features/auth/
├── api/auth_api.dart
├── repository/auth_repository.dart
├── auth_notifier.dart
└── model/                  # AuthTokens, ApprovalStatus, PhoneApprovalResponse, …

lib/shared/auth/
├── auth_interceptor.dart
├── token_storage.dart
└── auth_session_expired_exception.dart

lib/shared/api/
├── api_config.dart
├── dio_client.dart
└── dio_logging.dart
```

---

## Роли и экран «Мои сервисы»

После успешной авторизации пользователь попадает на **`RoleSelectionScreen`** (`/roles`).

1. Вызывается **`GET /accounts/me/`** через `ProfileApi`.
2. Из поля **`permissions`** извлекаются коды ролей.
3. Маппинг (`AccountPermissions`):

   - `facilities:manager` → `ServiceType.guard`
   - `core:security_staff` → `ServiceType.worker`

4. Пользователь видит **только свою роль** (переключатель `ServiceSwitcher` скрыт, если роль одна).
5. Если permissions пуст — сообщение об ошибке; кнопка **«Перейти»** скрыта, **Профиль** и **Выход** остаются на своих местах.
6. Нажатие на логотип **OKS Group** в шапке (на всех экранах **кроме auth**) ведёт на `/roles` через `OksHeader.onLogoTap`.

Профиль на этом экране — **`AccountProfileSheet`** с live-данными из `GET /accounts/me/`.

---

## Навигация

```
/                          → AuthScreen              (ввод телефона)
/approval-waiting          → ApprovalWaitingScreen   (polling / denied)
/roles                     → RoleSelectionScreen     (Мои сервисы)
/worker                    → WorkerMainScreen        (Мой пропуск)
/worker/object/:id         → ObjectDetailsScreen     (карточка объекта)
/guard                     → GuardMainScreen         (Охрана КПП)
/guard/scanner             → GuardScannerScreen      (сканер QR)
```

### Redirect-логика (`app_router.dart`)

- Неавторизованный пользователь может находиться только на `/` и `/approval-waiting`.
- При `isWaitingForApproval` и переходе на `/` — редирект на `/approval-waiting`.
- На `/approval-waiting` разрешено оставаться при `isDenied` (экран отказа с кнопкой «Вернуться назад»).
- Авторизованный на auth-маршрутах — редирект на `/roles`.
- `GoRouter.refreshListenable` привязан к `AuthNotifier`.

---

## Глобальный offline-overlay

`ConnectivityNotifier` + `OfflineAppShell` оборачивают всё приложение через `MaterialApp.builder`.

При потере Wi‑Fi или мобильных данных:

- Показывается полноэкранный блокер с `warning.svg`.
- Все кнопки и сервисы заблокированы до восстановления связи.
- Overlay автоматически скрывается при возвращении сети.

Файлы: `lib/features/connectivity/`, `lib/shared/ui/offline_blocking_overlay.dart`.

---

## Данные объектов

Список строительных объектов на экране worker формируется через **`ObjectsNotifier`** → **`ObjectRepository`**:

- **4 локальных mock-объекта** — всегда доступны как fallback.
- **3 объекта из JSONPlaceholder** (`/users/5`, `/users/6`, `/users/7`) — подгружаются асинхронно и маппятся в `ConstructionObject`.

При ошибке загрузки API приложение продолжает работать с локальными mock-данными.

### Профиль worker

**`ProfileSheet`** (нижняя панель worker / детали объекта) — гибридная модель:

- Имя, компания, ИИН, документы — из **`MockUserRepository`**.
- **Телефон** — из **`GET /accounts/me/`** (при ошибке API — fallback на mock).

---

## Modal bottom sheets

Общая инфраструктура вынесена в **`shared/ui/bottom_sheet_launchers.dart`**:

| Функция | Назначение |
|---|---|
| `showAppModalBottomSheet` | Draggable sheet с настраиваемой высотой |
| `showFixedModalBottomSheet` | Фиксированная высота (min = max = initial) |
| `showQrPassModalBottomSheet` | QR-пропуск на **75%** высоты экрана |
| `showLanguageModalBottomSheet` | Выбор языка на **40%** высоты |

Контент листов оборачивается в **`AppBottomSheetShell`** (`shared/ui/bottom_sheets/`).

---

## Пользовательские сценарии

### Worker (работник)

```
RoleSelectionScreen
  → WorkerMainScreen
      ├── Вкладка «Объекты»     → ObjectCard → ObjectDetailsScreen
      ├── Вкладка «История»     → placeholder «блок в разработке»
      ├── Нижняя панель: Профиль → ProfileSheet (mock + телефон с API)
      ├── Нижняя панель: QR     → ObjectSelectSheet → QrPassSheet
      └── Нижняя панель: Язык   → LanguageSheet (RU ↔ KZ)
```

- Верхний блок (шапка, табы, подсказка) **закреплён** — скроллятся только карточки объектов / текст истории.
- Нижняя панель `FloatingBottomBar` с отступом `bottomBarBottomInset = 38px`.
- Системная кнопка «Назад» возвращает на `/roles`.

### Guard (охранник)

```
RoleSelectionScreen
  → GuardMainScreen
      → кнопка «Отсканировать пропуск»
      → GuardScannerScreen
          ├── Скан QR → ConfirmAccessSheet
          ├── Допуск  → SuccessDialog
          ├── Отказ   → DenialDialog
          └── Невалидный QR → RejectDialog
```

- На главном экране guard: объект, подсказка и жёлтая кнопка сканирования (`YellowActionButton`).
- Сканирование — mock через **`MockScanApi`**.
- Системная кнопка «Назад» возвращает на `/roles`.

---

## UI и дизайн-система

| Компонент | Файл | Назначение |
|---|---|---|
| `OksHeader` / `OksGroupLogo` | `shared/ui/oks_header.dart` | Шапка + wordmark (опциональный `onLogoTap`) |
| `AppPrimaryButton` | `shared/ui/app_primary_button.dart` | Основная тёмная кнопка |
| `SheetIconButton` | `shared/ui/bottom_sheets/sheet_icon_button.dart` | Круглая кнопка 42×42 с тенью |
| `FloatingBottomBar` | `shared/ui/floating_bottom_bar.dart` | Нижняя панель worker |
| `AppBottomSheetShell` | `shared/ui/bottom_sheets/app_bottom_sheet_shell.dart` | Стандартный modal bottom sheet |
| `bottom_sheet_launchers.dart` | `shared/ui/bottom_sheet_launchers.dart` | Хелперы открытия листов |
| `SegmentTabs` | `shared/ui/segment_tabs.dart` | Переключатель «Объекты / История» |
| `ObjectCard` | `shared/ui/object_card.dart` | Карточка объекта в списке |
| `SpinningAsset` | `shared/ui/spinning_asset.dart` | Брендированный loader |
| Skeleton-виджеты | `shared/ui/skeleton/` | Shimmer-заглушки при загрузке |

Типографика: **Manrope** через `manropeTextStyle()` с `FontVariation.weight` (variable font).  
Токены: `app/theme/` — `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`.

---

## Структура `lib/` (ключевые модули)

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # OksQrApp, AppBootstrap
│   ├── di/app_dependencies.dart    # Singleton DI
│   ├── router/app_router.dart      # GoRouter + auth redirects
│   └── theme/                      # AppTheme, colors, fonts, spacing
│
├── features/
│   ├── auth/                       # OKS ID: API, repository, notifier, models
│   ├── profile/                    # ProfileApi, AccountProfile, permissions
│   ├── connectivity/               # ConnectivityNotifier
│   ├── construction_objects/       # JSONPlaceholder API, mapper, ObjectsNotifier
│   ├── qr_display/                 # QR-пропуск, выбор объекта
│   ├── qr_scanning/                # Сканер, overlay, mock scan API
│   ├── access_confirmation/        # Диалоги допуска / отказа
│   ├── language_switcher/          # RU / KZ (toggle + setLanguage)
│   ├── service_switcher/           # Переключатель worker / guard
│   └── profile/widgets/            # ProfileSheet, AccountProfileSheet
│
├── entities/
│   ├── construction_object/        # ConstructionObject, ObjectRepository
│   ├── user_profile/               # UserProfile (mock)
│   ├── worker/                     # ScannedWorker
│   └── service_type/               # ServiceType enum
│
├── screens/
│   ├── auth/                       # AuthScreen, ApprovalWaitingScreen
│   ├── role_selection/             # RoleSelectionScreen
│   ├── worker/                     # WorkerMainScreen, ObjectDetailsScreen
│   └── guard/                      # GuardMainScreen, GuardScannerScreen
│
└── shared/
    ├── api/                        # Dio, ApiConfig, logging
    ├── auth/                       # Interceptor, TokenStorage
    ├── constants/app_assets.dart   # Пути к SVG/ресурсам
    ├── ui/                         # UI-кит, skeleton, offline overlay, launchers
    └── utils/kz_phone_input_formatter.dart
```

---

## Assets

```
assets/
├── crane.svg          # Worker / строительство
├── barrier.svg        # Guard / КПП
├── builder.svg        # Иллюстрация auth
├── warning.svg        # Offline-overlay, denied state
├── load.svg           # Spinner-loader
├── icon_qr.svg        # QR-кнопка
├── icon_profile.svg   # Профиль
├── logout.svg         # Выход
└── fonts/
    └── Manrope-VariableFont_wght.ttf
```

---

## Тестирование

```bash
flutter test
```

| Файл | Что проверяет |
|---|---|
| `test/widget_test.dart` | Smoke-тест: приложение стартует, экран авторизации с кнопкой «Войти» |
| `test/account_profile_test.dart` | Парсинг permissions и маппинг ролей |
| `test/connectivity_notifier_test.dart` | Логика определения наличия сети |

---

## Что подключено к API, а что — mock

| Область | Источник данных |
|---|---|
| Авторизация (OKS ID) | Production API |
| Профиль / permissions (`/roles`) | Production API (`GET /accounts/me/`) |
| Телефон в worker ProfileSheet | Production API (остальное — mock) |
| JWT refresh | Production API |
| Строительные объекты | Локальные mock + JSONPlaceholder |
| История посещений (worker) | UI-placeholder («в разработке») |
| QR-сканирование (guard) | `MockScanApi` |

---

## Android

- Разрешение камеры в `AndroidManifest.xml` для QR-сканера.
- ProGuard rules для ML Kit barcode scanning в release-сборках.
- Package: `com.oksgroup.oks_qr_mobile`.
