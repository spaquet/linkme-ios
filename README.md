# LinkMe — iOS App

**Private memory and instinct of a great connector, in your pocket.**

A relationship operating system for founders, investors, and C-suite operators. Capture → Remember → Recall just-in-time → Act.

## Features (v1 MVP)

- **Voice-to-card**: Speak a 10-second note after meeting; on-device AI extracts structured person record
- **Just-in-time briefing**: "Brief me on Marcus before 3pm" — history, open threads, talking points, shared connections
- **Reciprocal share-back**: Send no-app web card to recipients; they claim and remember you back
- **On-device first**: All capture, briefing, and relationship graph stays private on-device by default
- **Siri integration**: Hands-free briefing via App Intents

## Tech Stack

- iOS 26 & 27 (latest only)
- SwiftUI
- SQLite with abstraction layer
- Apple Intelligence (on-device Foundation Models, Speech-to-text)
- App Intents (Siri)

## Project Structure

```
LinkMe/
├── LinkMeApp.swift           # App entry point
├── ContentView.swift         # Root navigation
├── Screens/                  # Feature screens
│   ├── OnboardingScreen.swift
│   ├── TodayScreen.swift
│   ├── CaptureScreen.swift
│   ├── PersonScreen.swift
│   ├── BriefingScreen.swift
│   ├── FollowUpScreen.swift
│   └── ShareBackScreen.swift
├── Components/               # Reusable UI (Avatar, Card, Button, etc)
├── Models/                   # Data models
├── Database/                 # SQLite layer
├── Services/                 # Apple Intelligence (AI extraction, speech)
└── Assets/                   # Colors, icons, fonts
└── Styles/                   # Design tokens (CLAUDE.md)
```

## Design

Geist typeface, teal as on-device/AI signal, slate ink, soft elevation, generous radii. See `CLAUDE.md` for full design system and color tokens.

Design prototype: `./design/` (React, for reference only — recreate pixel-perfectly in SwiftUI).

## Getting Started

1. Open `LinkMe.xcodeproj` in Xcode
2. Target: iOS 26+ (simulator or device)
3. Build & run

## Development Guide

See `CLAUDE.md` for:
- Detailed screen specs and flows
- Data model schema
- Design tokens (colors, shadows, typography)
- Development phase strategy
- Notes on privacy-first design and on-device AI

## Next Steps

1. Build onboarding flow (4 slides, magic moment first)
2. Implement data model + SQLite abstraction
3. Build Today screen (briefing-forward home)
4. Voice capture + on-device AI extraction
