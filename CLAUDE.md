# LinkMe — iOS App Development Guide

## What is LinkMe?

**Private memory and instinct of a great connector, in your pocket.**

LinkMe is a relationship operating system for high-stakes operators (founders, investors, C-suite). Core loop: capture → remember → recall just-in-time → act. Three hero moments drive the product:

1. **Voice-to-card**: Speak 10-second note post-meeting; on-device AI extracts structured person record (name, company, role, context, follow-up, personal detail)
2. **Just-in-time briefing**: "Brief me on Marcus before 3pm" returns history, last touchpoints, open threads, talking points. Hands-free via Siri.
3. **Reciprocal share-back**: Exchange sends no-app web card recipient values, then invites claim/control of profile. Loop closure.

## Tech Stack

- **iOS 26 & 27** (latest only; no backwards compat)
- **SwiftUI** for all UI
- **SQLite** for local data (via abstraction layer)
- **Apple Intelligence** on-device: Foundation Models (~3B LLM), Speech-to-text, visual intelligence
- **App Intents** for Siri integration (WWDC 2026)

## Design System

**Typography**: Geist (300-700 weight), Geist Mono
**Colors**:
- **Ink** `#0f1720` — headlines, primary text
- **Teal** `#14b8a6` — live/on-device/AI signal (t50-t700 range)
- **Slate** `#6b7280` → `#111827` — neutrals (s50-s900)
- **Canvas** `#f6f8f9` — app background
- **Surface** `#ffffff` — cards, inputs
- **Accents**: amber, rose, sky, indigo

**Components**: Avatar (rounded-square, tonal, initials), Chip, Button (primary/secondary), Card, Divider, OnDeviceChip (privacy signal)

**Layout**:
- Status bar height: 56px
- Tab bar height: 78px
- Home safe area: 30px
- Shadows: sm (subtle), md (default), lg (elevation), teal (accent)

**Icons**: SF Symbols only (use `Image(systemName:)` in SwiftUI). 24px base size, 1.75 stroke weight. Key icons: mic, sparkle, wand.and.stars, calendar, clock, person, person.2, share, send, shield, lock, check, chevron.right, plus, bell, x, arrow.up.right, link, phone, mail, building, star, pencil, gift, magnifyingglass, home, etc.

## Screens (v1 MVP)

### 1. **Onboarding** (4 slides, <90s, magic moment first)
   - Slide 1: Welcome + brand
   - Slide 2: Magic Moment — voice capture demo (animated wave, text-fill effect, card extraction)
   - Slide 3: Recall + Privacy — briefing demo + on-device badge
   - Slide 4: Create Your Card — form (name, role, company, tagline, email) + live preview
   - CTA: "Enter LinkMe" on final slide

### 2. **Today** (main home, briefing-forward)
   - **Up Next**: Next meeting card with just-in-time brief ("The one thing to remember")
   - **Later Today**: Upcoming meetings list (time, person, location)
   - **Needs You**: Nudges section (threads/follow-ups, preview top 2)
   - **Recent People**: Grid of recent contacts
   - TopBar: "Good afternoon, {first}", search, notification bell (badge count)

### 3. **Capture** (voice-to-card)
   - Large mic button (animated pulse when ready, recording state)
   - Transcription display (word-by-word fill as speaking)
   - Loading state for AI extraction
   - Result: card with extracted data

### 4. **Person Card**
   - Header: Avatar, name, role, company, tone
   - Timeline: capture notes, followups, interactions
   - Actions: brief me, follow up, share back
   - Live context: AI-extracted talking points

### 5. **Briefing Screen**
   - Person header with avatar
   - "The one thing to remember" (AI summary)
   - Open threads (what you promised/owe)
   - Shared connections (mutual links)
   - Action: open thread or start capture

### 6. **Follow-up** (AI draft + send)
   - Auto-drafted follow-up message (on-device AI)
   - Edit + schedule send or send now
   - Thread context visible

### 7. **Share-Back** (recipient web card + claim)
   - Your card (name, role, company, tagline, privacy badge)
   - Share link (generates no-app web card)
   - Recipient claim flow (web → profile)

### 8. **People List** (search, browse)
   - Searchable contact list
   - Filters: recent, starred, scenes, all
   - Sort: last contact, name

### 9. **Threads** (notifications center)
   - Follow-ups needing attention
   - Badge count on tab
   - Actions: mark done, snooze, reply

### 10. **Privacy Settings**
   - On-device/cloud toggle per data type
   - Consent flows (explicit, granular)
   - "Stayed on this device" indicator

## Data Model (SQLite)

Core entities:
- **User**: name, first, role, company, email, tagline, avatar, created_at
- **Person**: id, name, company, role, tone, captured_at, last_contact, favorite, deleted_at
- **Note**: id, person_id, text, transcription, extracted_json, created_at, is_followup
- **Contact**: id, person_id, type (meeting/call/text), timestamp, location, attendees
- **Thread**: id, person_id, prompt, status (open/closed/snoozed), created_at, due_at
- **Share**: id, person_id, token, sent_at, opened_at, claimed_by_person_id
- **Relationship**: id, person_a_id, person_b_id, shared_connection_date (for graph)

## Development Strategy

**Phase 1 (Onboarding + Today)**: Build the substrate — single-player capture + recall. No loop yet.
- Onboarding flow (4 slides, card creation)
- Today screen (briefing hero moment)
- Capture flow (voice → AI extraction → card)
- Data model + SQLite layer

**Phase 2 (Person + Briefing)**: Deep person knowledge.
- Person detail card + timeline
- Briefing screen (just-in-time summary)
- Follow-up drafting + sending
- Siri/App Intents integration

**Phase 3 (Share-back + Loop)**: Viral loop.
- Share-back mechanism (web card generation)
- Recipient claim flow
- Scene seeding / event mode

**Phase 4 (Polish + Instrumentation)**: Ship-ready.
- Loop instrumentation (share → open → claim → second capture metrics)
- Privacy flows + visible consent
- App Store optimization

## Notes

- **Privacy is first-class**: Every screen must have visible on-device/cloud indicator. Consent flows block cloud data.
- **Recall is the hero**: Lead UX with briefing moment, not database browser.
- **Near-zero friction capture**: 10-second voice note + mic button is the core habit. No delays.
- **Handoff files**: `./design/` has React prototype (JSX screens, design kit, icons). **Recreate pixel-perfectly in SwiftUI**, don't copy structure.
- **Colors + shadows**: Use LM color tokens exactly (see design kit). Shadows have semantic meaning (sm/md/lg/teal).
- **On-device first**: Foundation Models for extraction/summarization; Siri for hands-free briefing; local SQLite for all data by default.

## Handoff Design Files

Located at project root: `./design/`

- `design/LinkMe iOS.html` — Main prototype (React)
- `design/app/screens-*.jsx` — 7 screen components
- `design/app/ui.jsx` — UI primitives (Avatar, Chip, Button, Card)
- `design/app/kit.jsx` — Design tokens (LM.c, LM.shadow, LM.font, Icon, Mark)
- `design/app/data.jsx` — Mock data (people, meetings, nudges)
- `design/app/frames/ios-frame.jsx` — iOS device frame + tweaks panel
