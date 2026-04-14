# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

Open `buluoaichat.xcodeproj` in Xcode. No external dependencies or package managers — pure SwiftUI.

- **Minimum deployment target**: iOS 26.4
- **Bundle ID**: `com.hinapi.buluaichat`
- **Build**: `⌘ + B` in Xcode, or `xcodebuild -project buluoaichat.xcodeproj -scheme buluoaichat -sdk iphonesimulator`
- **Run on simulator**: `⌘ + R`. Use an iOS 26 simulator (required for Liquid Glass APIs).
- **Previews**: All views have `#Preview` macros. Use Xcode Canvas (`⌘ + Option + Return`).

There are no tests yet.

## Project Structure

```
buluoaichat/
├── buluoaichatApp.swift      # App entry point (@main)
├── ContentView.swift         # Root view — currently just routes to LoginView
├── Design/
│   └── BlahajTheme.swift     # Single source of truth for all colors, radii
├── Views/
│   └── Auth/
│       ├── AuthFieldRow.swift    # Shared input row component (icon + field)
│       ├── LoginView.swift
│       └── RegisterView.swift
└── Assets.xcassets/
    └── frontui.imageset/     # Shark mascot image (frontui.JPG)
```

The project uses **`PBXFileSystemSynchronizedRootGroup`** — Xcode auto-syncs with the filesystem. Adding/moving Swift files on disk is immediately reflected in Xcode without editing `project.pbxproj`.

## Design System

All UI colors and corner radii are defined in `BlahajTheme.swift`. Never hardcode colors in views.

**Blåhaj color palette:**
- `BlahajTheme.primary` — deep shark blue `#2B5F9E`, titles and main text
- `BlahajTheme.primaryMid` — medium blue `#4D8BC4`, icons and secondary text
- `BlahajTheme.pageBg` — light blue `#D6EAF5`, page background
- `BlahajTheme.cardBg` — white `#FFFFFF`, bottom cards
- `BlahajTheme.cta / accent` — shark mouth pink `#ffdada`, all CTA buttons and links

**Radius constants:** `radiusCard=42` (card top corners) · `radiusInput=18` · `radiusButton=18` · `radiusAvatar=28`

## iOS 26 Liquid Glass

This project targets iOS 26 and uses the Liquid Glass API:
- Apply `.glassEffect(in: shape)` directly on a `VStack`/container — **do not wrap form fields in `GlassEffectContainer`**, as focus changes trigger unwanted morphing animations.
- Use `GlassEffectContainer` only for independent interactive elements that should visually morph between each other.

## Auth Screen Layout Pattern

Both `LoginView` and `RegisterView` share the same layout structure:
1. `ZStack(alignment: .bottom)` — no `.ignoresSafeArea()` on the ZStack itself
2. `BlahajTheme.pageBg.ignoresSafeArea()` — background extends behind status bar
3. Hero section (image + title) sits naturally below the safe area top
4. Bottom white card uses `.background(alignment: .top) { shape.ignoresSafeArea(edges: .bottom) }` — this decouples the card background from content sizing so it extends to the physical screen bottom
5. Content inside the card uses `.safeAreaPadding(.bottom)` to stay above the Home indicator
