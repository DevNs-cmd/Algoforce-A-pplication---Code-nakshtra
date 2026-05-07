# AlgoForce AI

AlgoForce AI is a Flutter startup execution operating system for managing builder cohorts, MVP studio work, founder verification, revenue projections, roadmap execution, analytics, and an AI-assisted code builder.

![Flutter](https://img.shields.io/badge/Flutter-3.38.9-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10.8-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

> Train builders, build products, verify founders, and track the venture flywheel from one operating dashboard.

## Install on Android

Download the latest APK from this repository:

```text
dist/algoforce-ai-release.apk
```

[Download AlgoForce AI APK](dist/algoforce-ai-release.apk)

To install on a phone, copy the APK to your Android device, open it from the file manager, allow installation from that source if prompted, and tap **Install**.

## Table of Contents

- [Install on Android](#install-on-android)
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started - Prerequisites](#getting-started---prerequisites)
- [Installation - Exact Steps](#installation---exact-steps)
- [Build for Production](#build-for-production)
- [Install APK on Android](#install-apk-on-android)
- [Authentication](#authentication)
- [Navigation](#navigation)
- [State Management](#state-management)
- [API Integration](#api-integration)
- [Screens](#screens)
- [Known Issues / Limitations](#known-issues--limitations)
- [Contributing](#contributing)
- [License](#license)
- [Footer](#footer)

## Overview

AlgoForce AI is a multi-module Flutter app for operating a startup ecosystem. It gives the team a single interface to monitor Academy students and cohorts, run Studio MVP projects and deal modeling, process Verified founder certifications, project revenue, follow a roadmap, review analytics, and generate starter product code through Nexus AI.

The business problem it solves is operational visibility: AlgoForce has multiple revenue engines and founder/builder workflows, and this app keeps those workflows inspectable through dashboards, forms, Kanban-style movement, mock investor deal flow, and persisted local preferences.

The three core engines are:

| Engine | Plain-English meaning | What exists in the app |
| --- | --- | --- |
| Academy | Trains students/builders and tracks readiness for deployment | Cohort dashboard, enrollment form, student table, leaderboard, progress board, ISA calculator, student profiles |
| Studio | Builds MVPs for founders and models cash/equity deals | Studio pipeline, build detail view, project stage updates, deal calculator, portfolio valuation controls |
| Verified | Certifies founders and exposes trusted opportunities to investors | Founder application flow, verification pipeline, founder scorecards, investor dashboard, deal room |

| Metric | Value |
| --- | --- |
| Active routed screens | 28 |
| Provider declarations | 25 |
| Platforms scaffolded | iOS, Android, Web |
| Navigation type | `go_router` with `StatefulShellRoute.indexedStack` |
| State management | Riverpod `StateNotifierProvider`, `StateProvider`, `FutureProvider`, plus `SharedPreferences` persistence |

## Features

### App Shell

- Responsive `AppShell` with desktop sidebar, navigation rail, mobile bottom navigation, and top bar.
- `ShellNavigationScope` keeps navigation metadata synchronized with routes.
- Global search overlay with keyboard navigation, highlighted results, and persisted recent searches.
- Notification panel with filters for all, unread, and high-priority notifications.
- Speed-dial floating action button for quick actions.
- Theme toggle persisted through `SharedPreferences`.
- Friendly `ErrorBoundaryWidget` wrapper around routed pages.

### Authentication

- Splash screen checks stored session and onboarding state.
- Login form supports email/password sign-in, remember-me sessions, password visibility, role inference from email, and simulated Google login.
- Registration flow validates full name, email, Indian phone number, OTP verification, password strength, matching confirmation, role details, primary interest, terms acceptance, and optional company name.
- Forgot-password screen simulates reset-link delivery.
- OTP verification uses the built-in demo OTP `1234`.
- Onboarding screen stores completion locally before allowing normal auth routes.

### Overview

- Hero phrase rotator cycling through operating-system positioning.
- Engine card grid for Academy, Studio, Verified, and Nexus AI.
- Traction strip, real-time metrics panel, flywheel diagram, moat table, and activity feed.
- Live revenue metric increments every 30 seconds through `liveMetricsProvider`.

### Academy

- Cohort dashboard backed by `MockData.cohorts()`.
- Cohort table with persisted sort column and sort direction.
- Enrollment bottom sheet with form validation, city-tier selection, payment type, LinkedIn field, draft persistence, and pending application list.
- Cohort detail screen with student progress cards and action buttons.
- Student profile route for individual cohort students.
- Actions to mark students Studio-ready, issue badges, and mark placement.
- Student filtering by all, Studio deployed, certified, and placed.
- Student search by name or college.
- Leaderboard with tab/filter state and animated visual ranking widgets.
- Progress board with multiple filter providers for cohort, week, tier, and status.
- ISA calculator for income-share agreement projections.
- Ambassador map using the India SVG asset.

### Studio

- Studio screen with build pipeline board.
- Kanban-style project movement across discovery, sprint, QA, live, and retainer statuses.
- Quick-add project action.
- Build detail screen with timeline, project summary, deal details, tech stack, and progress panels.
- Deal calculator with cash amount, equity percent, exit valuation, success probability, expected equity value, total deal value, margin, and break-even cohort equivalents.
- Portfolio screen with editable valuation and stage state persisted locally.
- Deal cards and tech-stack pills.

### Verified

- Verified dashboard for certified founders and pending applications.
- Founder application screen with a multi-step local application form covering legal/company details, product information, certification reason, terms, payment method, and UPI ID.
- Draft persistence for founder applications.
- Verification pipeline and layer cards.
- Application layer advancement.
- Founder profile screen with index score details, score blocks, renewal actions, and investor intro logging.
- Investor dashboard with founder matching and intro requests.
- Deal room with sector filters, sorting, search, deck preview, and express-interest form.

### Nexus AI

- Nexus overview with strategy cards, pricing cards, template library, and framework switcher.
- Builder screen with prompt input, settings panel, generated code output, deploy URL, and build history restore/delete.
- Settings for framework, styling, TypeScript flag, mobile responsiveness, comments, auto-deploy, line numbers, max lines, and code style.
- Anthropic Messages API request attempt for generated code.
- Fallback local code generation when the Anthropic call fails.
- Simulated code streaming with haptic feedback and build history persistence.

### Revenue

- Revenue projection screen with scenario switching.
- Revenue chart powered by `fl_chart`.
- Revenue streams table with active/critical stream toggles.
- Revenue projector inputs persisted in local preferences.
- Stream breakdown cards, unit economics widget, and animated target bar.

### Roadmap

- Roadmap screen for 2026 phases.
- Progress tracker and milestone tracker.
- Gantt chart, vision grid, phase blocks, and risk register.
- Phase item completion toggles persisted locally.
- Phase expansion state persisted locally.
- Reorderable phase items in provider state.

### Analytics

- Business intelligence dashboard combining Academy, Studio, and Nexus state.
- Date-range picker with built-in options and custom range dialog.
- Revenue bar chart, Studio build status pie chart, Academy funnel painter, Nexus line chart, and deal value scatter chart.
- AI insights panel generated through `AdvisorService.generateInsights()`.
- Export report action copies analytics JSON to clipboard.

### Advisor

- Advisor sheet with contextual prefill support.
- `AdvisorService` streams fallback business guidance token by token.
- Context labels for Academy, Studio, Verified, Revenue, Analytics, and general operating-system advice.

### Notifications and Activity

- Smart notifications seeded on first load and persisted locally.
- Five-minute timer generates mock Verified application notifications.
- Activity feed records important actions from Academy, Studio, Verified, Nexus, and Roadmap providers.

### Backend Folder

- A Node/Express backend exists under `backend/` with auth, startup, task, evidence upload, investment, events, builder profile, and notifications endpoints.
- The active Flutter code does not call this backend. Flutter state currently comes from mock data, providers, and `SharedPreferences`.
- Java service skeletons also exist under `backend/services`, but they are outside the active Flutter runtime.

## Tech Stack

### Flutter and Dart Versions

| Tool | Version source | Version |
| --- | --- | --- |
| Flutter SDK | Local `flutter --version` | `3.38.9` |
| Dart SDK | `pubspec.yaml` environment and local Flutter toolchain | `^3.10.8` / `3.10.8` |

### Packages

| Package | Version | Purpose |
| --- | --- | --- |
| `flutter` | SDK | Flutter application framework |
| `cupertino_icons` | `^1.0.8` | Cupertino icon font |
| `flutter_riverpod` | `^2.5.1` | State management and dependency injection |
| `go_router` | `^13.0.0` | Declarative routing and shell navigation |
| `google_fonts` | `^6.2.1` | Google Fonts typography |
| `http` | `^1.2.1` | HTTP client dependency; not used by active Flutter source |
| `fl_chart` | `^0.68.0` | Revenue, analytics, pie, line, bar, and scatter charts |
| `shared_preferences` | `^2.2.3` | Local persistence for sessions, drafts, settings, history, and preferences |
| `lottie` | `^3.1.0` | Lottie animation support |
| `flutter_animate` | `^4.5.0` | UI shimmer and entrance animations |
| `animated_text_kit` | `^4.2.2` | Animated text effects |
| `percent_indicator` | `^4.2.3` | Percent/progress indicators |
| `shimmer` | `^3.0.0` | Shimmer loading UI |
| `intl` | `^0.19.0` | Date and number formatting |
| `url_launcher` | `^6.2.6` | External URL launching; imported by source utilities/widgets |
| `flutter_svg` | `^2.0.10+1` | SVG rendering, including the India map asset |
| `dio` | `^5.4.3` | HTTP client used by Advisor and Nexus service classes |
| `visibility_detector` | `^0.4.0+2` | Visibility-driven UI behavior |
| `web_socket_channel` | `^3.0.1` | WebSocket dependency; not used by active Flutter source |
| `cached_network_image` | `^3.3.1` | Cached network image dependency; not used by active Flutter source |
| `screenshot` | `^3.0.0` | Screenshot capture dependency |
| `share_plus` | `^10.1.4` | Platform sharing dependency |
| `flutter_speed_dial` | `^7.0.0` | Speed-dial floating action button |
| `flutter_staggered_grid_view` | `^0.7.0` | Masonry deal-room grid |
| `confetti` | `^0.7.0` | Confetti animation support |
| `flutter_staggered_animations` | `^1.1.1` | Staggered list/grid animations |
| `crypto` | `^3.0.3` | Simulated auth token and demo user ID hashing |
| `timeago` | `^3.6.1` | Relative timestamp display |
| `flutter_keyboard_visibility` | `^6.0.0` | Keyboard visibility support for auth/forms |
| `pinput` | `^5.0.0` | OTP/PIN input fields |
| `password_strength` | `^0.2.0` | Password strength feedback in registration |
| `flutter_test` | SDK | Flutter test framework |
| `flutter_lints` | `^4.0.0` | Recommended Flutter lint rules |
| `build_runner` | `^2.4.9` | Code generation runner; present in dev dependencies |
| `riverpod_generator` | `^2.4.0` | Riverpod code-generation support; active providers are handwritten |

## Project Structure

<details>
<summary>Full <code>lib/</code> tree</summary>

```text
lib/
|-- app.dart - Root AlgoForceApp, MaterialApp.router, theme selection, and global error widget wiring.
|-- main.dart - Initializes Flutter, SharedPreferences, ProviderScope, and AlgoForceApp.
|-- core/
|   |-- animations/
|   |   |-- animation_controller_mixin.dart - Reusable animation controller lifecycle mixin.
|   |   `-- staggered_animation.dart - Staggered entrance animation helper.
|   |-- constants/
|   |   |-- app_dimensions.dart - Shared spacing, radius, and layout constants.
|   |   |-- app_icons.dart - Central Material icon mapping for modules.
|   |   |-- app_strings.dart - App-level string constants.
|   |   `-- mock_data.dart - Mock cohorts, projects, deals, founders, revenue streams, and roadmap phases.
|   |-- responsive/
|   |   |-- responsive_grid.dart - Responsive grid helper.
|   |   `-- responsive_layout.dart - Responsive breakpoints and padding helpers.
|   |-- router/
|   |   `-- app_router.dart - GoRouter route tree, auth redirects, role gates, and route transitions.
|   |-- services/
|   |   `-- preferences_service.dart - SharedPreferences wrapper and app persistence keys.
|   |-- theme/
|   |   |-- app_colors.dart - Light color palette.
|   |   |-- app_text.dart - Text style helpers.
|   |   |-- app_theme.dart - Material light/dark themes.
|   |   |-- app_theme_extension.dart - Custom theme extension values.
|   |   |-- dark_colors.dart - Dark palette constants.
|   |   `-- theme_provider.dart - Riverpod theme mode controller.
|   |-- utils/
|   |   |-- breakpoints.dart - Numeric breakpoint constants.
|   |   |-- extensions.dart - Shared Dart/Flutter extensions.
|   |   `-- formatters.dart - Currency, date, percent, and compact formatting helpers.
|   `-- widgets/
|       |-- animated_counter.dart - Animated number counter widget.
|       |-- astro_loader.dart - Branded loading animation.
|       |-- error_boundary_widget.dart - Friendly error UI wrapper.
|       |-- initials_avatar.dart - Initials-based avatar.
|       |-- inline_editable_text.dart - Inline text editing control.
|       |-- pulse_dot.dart - Pulsing status dot.
|       `-- shimmer_loader.dart - Shimmer loading placeholder.
|-- features/
|   |-- academy/
|   |   |-- models/
|   |   |   |-- cohort.dart - Cohort model and status enum.
|   |   |   `-- student.dart - Student model, city tier, and fee type enums.
|   |   |-- providers/
|   |   |   `-- academy_provider.dart - Cohort, student, enrollment, sorting, filtering, and action state.
|   |   |-- screens/
|   |   |   |-- academy_screen.dart - Academy dashboard with cohort panels and enrollment actions.
|   |   |   |-- cohort_detail_screen.dart - Cohort detail with student cards and action buttons.
|   |   |   |-- isa_calculator_screen.dart - ISA projection calculator.
|   |   |   |-- leaderboard_screen.dart - Student leaderboard with filters.
|   |   |   |-- progress_board_screen.dart - Student progress board with filters and cards.
|   |   |   `-- student_profile_screen.dart - Individual student profile route.
|   |   `-- widgets/
|   |       |-- ambassador_map.dart - India map / ambassador visualization.
|   |       |-- cohort_dashboard.dart - Cohort KPI dashboard.
|   |       |-- cohort_table.dart - Sortable cohort table.
|   |       |-- enroll_form_sheet.dart - Enrollment form bottom sheet.
|   |       `-- step_flow.dart - Academy-specific step flow widget.
|   |-- activity/
|   |   `-- providers/
|   |       `-- activity_feed_provider.dart - Persisted activity feed and unread important count.
|   |-- advisor/
|   |   |-- advisor_provider.dart - Streaming advisor chat state.
|   |   |-- advisor_service.dart - Fallback advisor response stream and analytics insight generation.
|   |   `-- advisor_sheet.dart - Advisor bottom sheet UI.
|   |-- analytics/
|   |   `-- analytics_screen.dart - BI dashboard, charts, AI insights, and export action.
|   |-- auth/
|   |   |-- models/
|   |   |   |-- auth_state.dart - Auth status and state model.
|   |   |   `-- user.dart - AlgoUser model and user role enum.
|   |   |-- providers/
|   |   |   `-- auth_provider.dart - Auth controller for login, register, OTP, logout, and session updates.
|   |   |-- screens/
|   |   |   |-- forgot_password_screen.dart - Simulated password reset flow.
|   |   |   |-- login_screen.dart - Email/password and Google demo sign-in UI.
|   |   |   |-- onboarding_screen.dart - First-run onboarding flow.
|   |   |   |-- otp_verify_screen.dart - OTP verification screen.
|   |   |   |-- register_screen.dart - Multi-field registration form.
|   |   |   `-- splash_screen.dart - Session/onboarding bootstrap screen.
|   |   `-- services/
|   |       `-- auth_service.dart - Simulated auth, demo users, OTP, tokens, and persistence.
|   |-- dealroom/
|   |   `-- deal_room_screen.dart - Verified investor deal room with filters, deck preview, and interest form.
|   |-- nexus/
|   |   |-- providers/
|   |   |   |-- nexus_models.dart - Nexus build history model.
|   |   |   `-- nexus_provider.dart - Nexus prompt, settings, generation, streaming, and history state.
|   |   |-- screens/
|   |   |   |-- builder_screen.dart - Prompt-to-code builder workspace.
|   |   |   `-- nexus_screen.dart - Nexus landing/dashboard screen.
|   |   |-- services/
|   |   |   `-- nexus_api_service.dart - Anthropic Messages API request and local fallback generator.
|   |   `-- widgets/
|   |       |-- code_output_panel.dart - Generated-code display and controls.
|   |       |-- nexus_settings_sheet.dart - Nexus generation settings UI.
|   |       |-- pricing_card.dart - Nexus pricing card.
|   |       |-- prompt_input.dart - Prompt input widget.
|   |       |-- strategy_card.dart - Nexus strategy card.
|   |       `-- template_library.dart - Prompt/template library.
|   |-- notifications/
|   |   |-- models/
|   |   |   `-- notification_item.dart - Notification model, priority, and type encoding.
|   |   |-- providers/
|   |   |   `-- notifications_provider.dart - Notification list, filters, seeding, timer, and persistence.
|   |   `-- widgets/
|   |       |-- notification_card.dart - Individual notification card.
|   |       `-- notification_panel.dart - Notification drawer/panel UI.
|   |-- onboarding/
|   |   `-- onboarding_flow.dart - Additional onboarding flow component not routed by AppRouter.
|   |-- overview/
|   |   |-- providers/
|   |   |   `-- overview_provider.dart - Hero phrase rotator and live metrics timer.
|   |   |-- screens/
|   |   |   `-- overview_screen.dart - Main operating dashboard.
|   |   `-- widgets/
|   |       |-- activity_feed.dart - Overview activity feed widget.
|   |       |-- engine_card_grid.dart - Engine card grid.
|   |       |-- flywheel_diagram.dart - Custom flywheel visualization.
|   |       |-- hero_rotator.dart - Rotating hero phrase widget.
|   |       |-- moat_table.dart - Competitive moat table.
|   |       |-- real_time_metrics_panel.dart - Live metric panel.
|   |       `-- traction_strip.dart - Traction KPI strip.
|   |-- profile/
|   |   `-- profile_screen.dart - Profile, account, role, preferences, security, and danger-zone UI.
|   |-- revenue/
|   |   |-- providers/
|   |   |   |-- revenue_models.dart - Revenue stream, projection scenario, and input models.
|   |   |   `-- revenue_provider.dart - Revenue scenario, stream, chart, and input state.
|   |   |-- screens/
|   |   |   `-- revenue_screen.dart - Revenue projection dashboard.
|   |   `-- widgets/
|   |       |-- revenue_chart.dart - Revenue chart widget.
|   |       |-- revenue_projector.dart - Projection input controls.
|   |       |-- revenue_streams_table.dart - Revenue stream table.
|   |       |-- stream_breakdown_card.dart - Revenue stream breakdown card.
|   |       |-- target_bar_animated.dart - Animated target bar.
|   |       `-- unit_economics.dart - Unit economics panel.
|   |-- roadmap/
|   |   |-- providers/
|   |   |   |-- roadmap_models.dart - Roadmap phase and item models.
|   |   |   `-- roadmap_provider.dart - Roadmap completion, expansion, and reorder state.
|   |   |-- screens/
|   |   |   `-- roadmap_screen.dart - Roadmap dashboard.
|   |   `-- widgets/
|   |       |-- gantt_chart.dart - Gantt chart visualization.
|   |       |-- milestone_tracker.dart - Milestone tracker.
|   |       |-- phase_block.dart - Roadmap phase block.
|   |       |-- progress_tracker.dart - Overall progress tracker.
|   |       |-- risk_register.dart - Risk register panel.
|   |       `-- vision_grid.dart - 2030 vision grid.
|   |-- search/
|   |   |-- search_overlay.dart - Spotlight-style search overlay.
|   |   `-- search_provider.dart - Search query, highlighted index, and recent history state.
|   |-- shell/
|   |   |-- providers/
|   |   |   `-- navigation_provider.dart - Navigation items and route metadata.
|   |   `-- widgets/
|   |       |-- app_shell.dart - Responsive shell around routed branches.
|   |       |-- bottom_nav.dart - Mobile bottom navigation.
|   |       |-- global_search.dart - Shell search entry point.
|   |       |-- navigation_rail_nav.dart - Tablet/rail navigation.
|   |       |-- notifications_panel.dart - Shell notification panel wrapper.
|   |       |-- shell_navigation_scope.dart - Route synchronization scope.
|   |       |-- sidebar_nav.dart - Desktop sidebar navigation.
|   |       `-- top_bar.dart - Top app bar with actions.
|   |-- studio/
|   |   |-- models/
|   |   |   |-- build_project.dart - Studio build project model and status enum.
|   |   |   `-- deal.dart - Deal model and deal type enum.
|   |   |-- providers/
|   |   |   `-- studio_provider.dart - Project, deal, calculator, valuation, stage, and Kanban state.
|   |   |-- screens/
|   |   |   |-- build_detail_screen.dart - Studio project detail screen.
|   |   |   |-- deal_calculator_screen.dart - Full-screen deal calculator route.
|   |   |   |-- portfolio_screen.dart - Portfolio valuation/stage screen.
|   |   |   `-- studio_screen.dart - Studio pipeline screen.
|   |   `-- widgets/
|   |       |-- build_pipeline_board.dart - Kanban-style build pipeline board.
|   |       |-- deal_card.dart - Studio deal card.
|   |       |-- equity_calculator.dart - Deal economics calculator widget.
|   |       `-- tech_stack_pills.dart - Tech-stack pill list.
|   `-- verified/
|       |-- models/
|       |   |-- certified_founder.dart - Certified founder model and badge status enum.
|       |   `-- founder_application.dart - Founder application model.
|       |-- providers/
|       |   `-- verified_provider.dart - Certified founder, application, draft, layer, and investor-intro state.
|       |-- screens/
|       |   |-- founder_application_screen.dart - Multi-step Verified application form.
|       |   |-- founder_profile_screen.dart - Founder score/profile details.
|       |   |-- investor_dashboard_screen.dart - Investor matching dashboard.
|       |   `-- verified_screen.dart - Verified dashboard.
|       `-- widgets/
|           |-- founder_list.dart - Certified founder list.
|           |-- index_score_meter.dart - Founder index score meter.
|           |-- layer_card.dart - Verification layer card.
|           |-- verification_pipeline.dart - Pending application pipeline.
|           `-- verification_stepper.dart - Verification stepper.
|-- shared/
|   `-- widgets/
|       |-- astronaut_widget.dart - Branded astronaut visual widget.
|       |-- callout_card.dart - Shared callout card.
|       |-- engine_card.dart - Shared engine summary card.
|       |-- feature_item.dart - Shared feature list item.
|       |-- ghost_button.dart - Secondary ghost button.
|       |-- hero_card.dart - Shared hero card.
|       |-- logo_widget.dart - AlgoForce logo widget.
|       |-- margin_bar.dart - Margin/progress bar.
|       |-- metric_card.dart - Shared KPI card.
|       |-- phase_block_widget.dart - Shared phase block widget.
|       |-- primary_button.dart - Primary CTA button.
|       |-- section_label.dart - Section label text widget.
|       |-- speed_dial_fab.dart - Speed dial FAB.
|       |-- step_flow_widget.dart - Shared step flow visualization.
|       |-- tab_bar_widget.dart - Shared tab bar.
|       `-- tag_pill.dart - Shared tag pill.
`-- src/ - Dormant/excluded Capital OS prototype tree; excluded by analysis_options.yaml and not imported by main.dart.
    |-- algo_force_ai_app.dart - Large prototype app file.
    |-- app/
    |   |-- capital_os_app.dart - Prototype Capital OS root app.
    |   `-- capital_os_theme.dart - Prototype theme.
    |-- core/
    |   |-- domain/
    |   |   `-- venture_object.dart - Prototype venture domain object.
    |   |-- engines/
    |   |   `-- capital_os_engines.dart - Prototype engine logic.
    |   |-- state/
    |   |   `-- capital_os_controller.dart - Prototype state controller.
    |   `-- widgets/
    |       |-- capital_background.dart - Prototype background widget.
    |       `-- capital_glass.dart - Prototype glass UI widgets.
    `-- features/
        |-- auth/
        |   `-- auth_gate.dart - Prototype auth gate.
        |-- equity_finance/
        |   `-- equity_finance_screen.dart - Prototype equity finance screen.
        |-- intelligence/
        |   `-- intelligence_engine_screen.dart - Prototype intelligence engine screen.
        |-- shell/
        |   `-- capital_shell.dart - Prototype shell.
        |-- venture_creation/
        |   `-- venture_creation_screen.dart - Prototype venture creation screen.
        `-- venture_execution/
            `-- venture_execution_screen.dart - Prototype venture execution screen.
```

</details>

## Getting Started - Prerequisites

| Requirement | Version / Notes |
| --- | --- |
| Flutter SDK | Not pinned in `pubspec.yaml`; local verified SDK is `3.38.9` |
| Dart SDK | `^3.10.8` from `pubspec.yaml` |
| Android | Android Studio, Android SDK, emulator or device |
| iOS | Xcode and CocoaPods on macOS |
| Web | Chrome or another Flutter-supported browser |
| Desktop | No `macos/`, `windows/`, or `linux/` Flutter platform folders are present in this repository |

## Installation - Exact Steps

### Step 1: Clone

```bash
git clone https://github.com/algoforce-ai/algoforce_ai.git
cd algoforce_ai
```

### Step 2: Install dependencies

```bash
flutter pub get
```

### Step 3: Run code generation

`build_runner` is present in `pubspec.yaml`, so run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

The current active providers are handwritten; this command is still safe when generated outputs are introduced.

### Step 4: Environment setup

The active Flutter app does not use a `.env` file and does not define an Anthropic API-key variable.

`lib/features/nexus/services/nexus_api_service.dart` posts to Anthropic directly with these headers:

```dart
{
  'Content-Type': 'application/json',
  'anthropic-version': '2023-06-01',
}
```

There is no `x-api-key` header in the Flutter code. As written, the Nexus request is expected to fail unless an external network layer injects credentials, and the app falls back to local generated sample code. For production, add a backend proxy and keep the Anthropic key out of the Flutter client.

The backend folder has its own environment example:

```bash
cd backend
cp .env.example .env
```

Backend variables currently defined:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/algoforce_ai?schema=public"
JWT_SECRET="replace-with-production-secret"
PORT=4000
```

The active Flutter app is not wired to this backend.

### Step 5: Run the app

```bash
flutter run -d chrome
```

```bash
flutter run -d ios
```

```bash
flutter run -d android
```

No macOS or Windows run command is listed because this repository does not contain `macos/` or `windows/` Flutter platform folders.

## Build for Production

```bash
flutter build web --release
```

```bash
flutter build apk --release
```

Release APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The repository also includes a distributable Android installer:

```text
dist/algoforce-ai-release.apk
```

```bash
flutter build ipa
```

No macOS production command is listed because this repository does not contain a `macos/` folder.

## Install APK on Android

Android users can install the app directly from the release APK included in this repository:

```text
dist/algoforce-ai-release.apk
```

To install by file transfer:

1. Copy `dist/algoforce-ai-release.apk` to the Android phone.
2. Open the APK from the phone's file manager.
3. Allow installation from the browser or file manager if Android prompts for permission.
4. Tap **Install**.

To install from a development machine with ADB:

```bash
adb install -r dist/algoforce-ai-release.apk
```

To rebuild the APK before sharing:

```bash
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk dist/algoforce-ai-release.apk
```

## Authentication

Authentication is simulated in Flutter through `AuthService`; it does not call a real backend from the active app.

Login accepts any syntactically valid email address and any password with at least 8 characters. The password is not checked against a server. If no stored user exists, `AuthService` creates a demo user from the email address.

| Demo login | Role produced |
| --- | --- |
| `admin@algoforce.ai` with any password of 8+ characters | `admin` |
| `investor@algoforce.ai` with any password of 8+ characters | `investor` |
| `builder@algoforce.ai` with any password of 8+ characters | `builder` |
| Any other valid email with any password of 8+ characters | `founder` |
| Google demo login | `demo@algoforce.ai`, role `admin` |

OTP uses the hardcoded demo value:

```text
1234
```

Session persistence is stored in `SharedPreferences` using:

| Key | Purpose |
| --- | --- |
| `auth_user` | Encoded `AlgoUser` |
| `auth_token` | Simulated token |
| `auth_session_expires` | Session expiry timestamp |
| `auth_registered_emails` | Locally registered emails |

Remember-me sessions last 30 days. Non-remembered sessions last 7 days.

## Navigation

The app uses `GoRouter` with `StatefulShellRoute.indexedStack`. The initial route is `/splash`. Auth and onboarding redirects are handled in `AppRouter.router.redirect`.

Role-gated paths:

| Route | Allowed roles |
| --- | --- |
| `/verified/investors` | `investor`, `admin` |
| `/verified/deal-room` | `investor`, `founder`, `admin` |
| `/analytics` | `admin`, `founder` |
| `/academy/leaderboard` | All roles |

Route tree:

```text
/splash -> SplashScreen
/login -> LoginScreen
/register -> RegisterScreen
/forgot-password -> ForgotPasswordScreen
/otp-verify -> OtpVerifyScreen
/onboarding -> OnboardingScreen
/
`-- OverviewScreen
/academy
|-- AcademyScreen
|-- cohort/:cohortId -> CohortDetailScreen
|   `-- student/:studentId -> StudentProfileScreen
|-- leaderboard -> LeaderboardScreen
|-- progress-board -> ProgressBoardScreen
|-- isa-calculator -> IsaCalculatorScreen
`-- :cohortId -> CohortDetailScreen
    `-- student/:studentId -> StudentProfileScreen
/studio
|-- StudioScreen
|-- project/:projectId -> BuildDetailScreen
|-- portfolio -> PortfolioScreen
|-- calculator -> DealCalculatorScreen
`-- :projectId -> BuildDetailScreen
/verified
|-- VerifiedScreen
|-- apply -> FounderApplicationScreen
|-- investors -> InvestorDashboardScreen
|-- deal-room -> DealRoomScreen
|-- founder/:founderId -> FounderProfileScreen
`-- :founderId -> FounderProfileScreen
/nexus
|-- NexusScreen
`-- builder -> BuilderScreen
/revenue -> RevenueScreen
/roadmap -> RoadmapScreen
/analytics -> AnalyticsScreen
/profile -> ProfileScreen
```

Every `_route()` page is wrapped in `ErrorBoundaryWidget` and uses a 240 ms fade/scale `CustomTransitionPage`.

## State Management

Riverpod is configured at app startup in `main.dart` with a `ProviderScope`. `SharedPreferences` is created before `runApp()` and injected by overriding `sharedPreferencesProvider`.

| Provider | File path | What it manages |
| --- | --- | --- |
| `sharedPreferencesProvider` | `lib/core/services/preferences_service.dart` | Raw `SharedPreferences` instance injected from `main.dart` |
| `preferencesServiceProvider` | `lib/core/services/preferences_service.dart` | Typed persistence wrapper for app settings and drafts |
| `themeModeProvider` | `lib/core/theme/theme_provider.dart` | Light/dark theme mode |
| `authServiceProvider` | `lib/features/auth/services/auth_service.dart` | Simulated auth service |
| `authProvider` | `lib/features/auth/providers/auth_provider.dart` | Auth status, current user, login/register/OTP/logout flows |
| `activityFeedProvider` | `lib/features/activity/providers/activity_feed_provider.dart` | Persisted activity feed and important unread count |
| `academyProvider` | `lib/features/academy/providers/academy_provider.dart` | Cohorts, students, enrollment form, filters, sorting, and student actions |
| `advisorServiceProvider` | `lib/features/advisor/advisor_service.dart` | Advisor response and insight service |
| `advisorProvider` | `lib/features/advisor/advisor_provider.dart` | Advisor messages, streaming state, context, and prefill |
| `analyticsRangeProvider` | `lib/features/analytics/analytics_screen.dart` | Analytics date range selection |
| `analyticsInsightsProvider` | `lib/features/analytics/analytics_screen.dart` | Async advisor-generated analytics insights |
| `dealRoomProvider` | `lib/features/dealroom/deal_room_screen.dart` | Mock deal-room entries and express-interest state |
| `dealRoomSectorProvider` | `lib/features/dealroom/deal_room_screen.dart` | Deal-room sector filter |
| `dealRoomSortProvider` | `lib/features/dealroom/deal_room_screen.dart` | Deal-room sort mode |
| `dealRoomSearchProvider` | `lib/features/dealroom/deal_room_screen.dart` | Deal-room search query |
| `nexusApiServiceProvider` | `lib/features/nexus/providers/nexus_provider.dart` | Nexus API service instance |
| `nexusProvider` | `lib/features/nexus/providers/nexus_provider.dart` | Nexus prompt, settings, output, streaming, deploy URL, and history |
| `notificationsProvider` | `lib/features/notifications/providers/notifications_provider.dart` | Notifications, filters, seeding, timer generation, and persistence |
| `overviewProvider` | `lib/features/overview/providers/overview_provider.dart` | Overview day count and rotating hero phrase |
| `liveMetricsProvider` | `lib/features/overview/providers/overview_provider.dart` | Live revenue metric and refresh count |
| `revenueProvider` | `lib/features/revenue/providers/revenue_provider.dart` | Revenue scenarios, stream toggles, chart data, targets, and inputs |
| `roadmapProvider` | `lib/features/roadmap/providers/roadmap_provider.dart` | Roadmap phases, item completion, expansion, and reorder state |
| `searchProvider` | `lib/features/search/search_provider.dart` | Spotlight query, recent searches, and highlighted index |
| `navigationProvider` | `lib/features/shell/providers/navigation_provider.dart` | Current route metadata and navigation labels |
| `studioProvider` | `lib/features/studio/providers/studio_provider.dart` | Studio projects, deals, calculator, valuations, stages, and Kanban order |
| `verifiedProvider` | `lib/features/verified/providers/verified_provider.dart` | Certified founders, applications, selected founder, application form, layers, and intros |

## API Integration

### Anthropic

Nexus AI is the only active Flutter feature that attempts an external AI API call.

| Item | Value |
| --- | --- |
| File | `lib/features/nexus/services/nexus_api_service.dart` |
| Endpoint | `https://api.anthropic.com/v1/messages` |
| Model | `claude-sonnet-4-20250514` |
| Method | `POST` through `dio` |
| Headers present | `Content-Type: application/json`, `anthropic-version: 2023-06-01` |
| API key handling | No API key variable, no `.env`, and no `x-api-key` header exist in the Flutter app |
| Error handling | `DioException` and generic exceptions return local fallback code |

Because no Anthropic key is configured in the Flutter client, there is no key to add out of the box. For production, put the key behind a backend proxy and call that proxy from `NexusApiService`.

### Backend

The repository contains `backend/src/server.js`, an Express API with endpoints for auth, startups, tasks, evidence uploads, investments, events, builder profiles, and notifications. The Flutter app does not currently call these endpoints.

## Screens

| Screen | Route path | File path | Description |
| --- | --- | --- | --- |
| `SplashScreen` | `/splash` | `lib/features/auth/screens/splash_screen.dart` | Bootstraps session and onboarding routing. |
| `LoginScreen` | `/login` | `lib/features/auth/screens/login_screen.dart` | Simulated email/password and Google demo sign-in. |
| `RegisterScreen` | `/register` | `lib/features/auth/screens/register_screen.dart` | Validated registration and role-detail form. |
| `ForgotPasswordScreen` | `/forgot-password` | `lib/features/auth/screens/forgot_password_screen.dart` | Simulated password reset request screen. |
| `OtpVerifyScreen` | `/otp-verify` | `lib/features/auth/screens/otp_verify_screen.dart` | OTP verification using the demo OTP. |
| `OnboardingScreen` | `/onboarding` | `lib/features/auth/screens/onboarding_screen.dart` | First-run product onboarding. |
| `OverviewScreen` | `/` | `lib/features/overview/screens/overview_screen.dart` | Main operating dashboard. |
| `AcademyScreen` | `/academy` | `lib/features/academy/screens/academy_screen.dart` | Academy cohort and enrollment dashboard. |
| `CohortDetailScreen` | `/academy/cohort/:cohortId` | `lib/features/academy/screens/cohort_detail_screen.dart` | Cohort detail, student cards, and student actions. |
| `CohortDetailScreen` | `/academy/:cohortId` | `lib/features/academy/screens/cohort_detail_screen.dart` | Alternate cohort detail route. |
| `StudentProfileScreen` | `/academy/cohort/:cohortId/student/:studentId` | `lib/features/academy/screens/student_profile_screen.dart` | Student profile inside the nested cohort route. |
| `StudentProfileScreen` | `/academy/:cohortId/student/:studentId` | `lib/features/academy/screens/student_profile_screen.dart` | Alternate student profile route. |
| `LeaderboardScreen` | `/academy/leaderboard` | `lib/features/academy/screens/leaderboard_screen.dart` | Academy leaderboard and ranking filters. |
| `ProgressBoardScreen` | `/academy/progress-board` | `lib/features/academy/screens/progress_board_screen.dart` | Filterable Academy progress board. |
| `IsaCalculatorScreen` | `/academy/isa-calculator` | `lib/features/academy/screens/isa_calculator_screen.dart` | Income-share agreement calculator. |
| `StudioScreen` | `/studio` | `lib/features/studio/screens/studio_screen.dart` | Studio build pipeline dashboard. |
| `BuildDetailScreen` | `/studio/project/:projectId` | `lib/features/studio/screens/build_detail_screen.dart` | Studio project detail route. |
| `BuildDetailScreen` | `/studio/:projectId` | `lib/features/studio/screens/build_detail_screen.dart` | Alternate Studio project detail route. |
| `PortfolioScreen` | `/studio/portfolio` | `lib/features/studio/screens/portfolio_screen.dart` | Studio portfolio valuation and stage screen. |
| `DealCalculatorScreen` | `/studio/calculator` | `lib/features/studio/screens/deal_calculator_screen.dart` | Studio deal calculator screen. |
| `VerifiedScreen` | `/verified` | `lib/features/verified/screens/verified_screen.dart` | Verified founder dashboard. |
| `FounderApplicationScreen` | `/verified/apply` | `lib/features/verified/screens/founder_application_screen.dart` | Multi-step founder certification application. |
| `InvestorDashboardScreen` | `/verified/investors` | `lib/features/verified/screens/investor_dashboard_screen.dart` | Investor matching dashboard. |
| `DealRoomScreen` | `/verified/deal-room` | `lib/features/dealroom/deal_room_screen.dart` | Private deal-room workspace for certified startups. |
| `FounderProfileScreen` | `/verified/founder/:founderId` | `lib/features/verified/screens/founder_profile_screen.dart` | Certified founder score/profile route. |
| `FounderProfileScreen` | `/verified/:founderId` | `lib/features/verified/screens/founder_profile_screen.dart` | Alternate founder profile route. |
| `NexusScreen` | `/nexus` | `lib/features/nexus/screens/nexus_screen.dart` | Nexus AI dashboard and templates. |
| `BuilderScreen` | `/nexus/builder` | `lib/features/nexus/screens/builder_screen.dart` | Prompt-to-code builder workspace. |
| `RevenueScreen` | `/revenue` | `lib/features/revenue/screens/revenue_screen.dart` | Revenue projection dashboard. |
| `RoadmapScreen` | `/roadmap` | `lib/features/roadmap/screens/roadmap_screen.dart` | Roadmap and milestone screen. |
| `AnalyticsScreen` | `/analytics` | `lib/features/analytics/analytics_screen.dart` | Business intelligence and charts screen. |
| `ProfileScreen` | `/profile` | `lib/features/profile/profile_screen.dart` | User profile and account settings screen. |

## Known Issues / Limitations

- Auth is simulated in Flutter and does not validate passwords against a real backend.
- Mock data is used for cohorts, students, Studio projects, deals, founders, revenue streams, and roadmap phases.
- The active Flutter app does not call the included backend.
- Nexus AI attempts Anthropic without an API key header, so it relies on fallback code generation unless credentials are injected externally.
- There is no `.env` integration in the Flutter app.
- Desktop platform folders are not present.
- `lib/src/**` contains a dormant Capital OS prototype tree that is excluded by `analysis_options.yaml` and not imported by `main.dart`.
- No actionable `TODO`, `FIXME`, `HACK`, or `XXX` comments were found in the active Flutter source. The backend contains a task status string literal named `TODO`, which is not a developer TODO comment.

## Contributing

1. Fork the repository.
2. Create a branch with a focused name.
3. Install dependencies.

```bash
flutter pub get
```

4. Run code generation after Riverpod provider changes or generated-model changes.

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. Run analysis and fix every issue.

```bash
flutter analyze
```

6. Open a pull request.

Commit message prefixes:

| Prefix | Use for |
| --- | --- |
| `feat:` | New user-facing functionality |
| `fix:` | Bug fixes |
| `chore:` | Tooling, dependency, or maintenance work |
| `docs:` | Documentation-only changes |

## License

```text
MIT License

Copyright (c) 2026 AlgoForce AI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Footer

<div align="center">

**AlgoForce AI**

Contact: [contact@algoforceai.com](mailto:contact@algoforceai.com)

Website: [algoforceai.com](https://algoforceai.com)

</div>
