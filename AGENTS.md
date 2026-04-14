# Repository Guidelines

## Project Structure & Module Organization
`buluaichat/` contains the app source. Main entry points are `buluaichatApp.swift` and `ContentView.swift`. Feature views live under `buluaichat/Views/` by domain, for example `Views/Auth/`, `Views/Chat/`, `Views/Contacts/`, `Views/Main/`, and `Views/Profile/`. Shared models are in `buluaichat/Models/`, and design tokens live in `buluaichat/Design/BlahajTheme.swift`. Image assets are stored in `buluaichat/Assets.xcassets/`. `LandmarksBuildingAnAppWithLiquidGlass/` is a reference sample and should only be edited when intentionally updating the demo source.

## Build, Test, and Development Commands
Open the project with `open buluaichat.xcodeproj` for normal development in Xcode.

- `xcodebuild -project buluaichat.xcodeproj -scheme buluaichat -sdk iphonesimulator build`: build the app from the command line.
- `xcodebuild -project buluaichat.xcodeproj -scheme buluaichat -destination 'platform=iOS Simulator,name=iPhone 16' build`: build for a specific simulator.
- `xcodebuild test -project buluaichat.xcodeproj -scheme buluaichat -destination 'platform=iOS Simulator,name=iPhone 16'`: run tests when a test target is added.

Use an iOS 26 simulator; the project targets iOS 26.4 and relies on Liquid Glass APIs.

## Coding Style & Naming Conventions
Use SwiftUI-first patterns and keep indentation at 4 spaces. Name types with `UpperCamelCase` and properties/functions with `lowerCamelCase`. Place new views in the matching feature folder, for example `Views/Chat/MessageComposerView.swift`. Do not hardcode colors; use `BlahajTheme`. Prefer system navigation and tab containers over custom chrome when Liquid Glass behavior should come from the OS.

## Testing Guidelines
There is currently no committed test target and no coverage gate. When adding tests, use XCTest and mirror the source layout with targets such as `buluaichatTests/`. Name test files after the feature, for example `ConversationListViewTests.swift`, and name methods like `test_searchFiltersConversations()`.

## Commit & Pull Request Guidelines
Follow the existing commit style: short Conventional Commit prefixes such as `feat:`, `fix:`, and `refactor:`. Keep each commit focused on one change. PRs should include a concise summary, note any UI or navigation behavior changes, link related issues if available, and attach screenshots or simulator recordings for visible SwiftUI updates.

## UI & Configuration Notes
Keep Liquid Glass usage aligned with Apple’s system behavior. For form surfaces, follow the existing guidance in `CLAUDE.md`: use `glassEffect` directly on the intended container and avoid unnecessary custom tab bars or overlays when `TabView`, `NavigationStack`, or toolbars already provide the correct system presentation.
