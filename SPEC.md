# Tossup — Build Specification

> Portfolio app 200, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Pick one answer on today's trivia question, seal your choice, and track your streak.

| Field | Value |
| --- | --- |
| Product name | Tossup |
| Bundle identifier | `com.tossup.ticket` |
| Domain | https://tossup-ticket.pro |
| Contact URL | https://tossup-ticket.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `tsp_` |
| User-Agent | `Tossup/1.0 (iOS; +https://tossup-ticket.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Tossup -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A daily player stakes one answer on today's trivia ticket, seals the pick, and earns a scored card on the streak timeline.

### 2.1 User flow

1. On Today, tap one of the four choices to write a StakeMark on that Choice.
2. Tap Seal to freeze the staked Choice before the reveal.
3. Read the why line and collect the Card into the Journal.
4. Open Stats to see the Swift Charts streak and points timeline.
5. Open Settings to toggle themed decks and reset local progress.

### 2.2 Essential behaviour

- One bundled Drop per calendar day from selected Decks (dayIndex modulo pool; no remote fetch).
- Stake-then-seal fold: StakeMark on a Choice, SealMark before score, Card on correct or miss with streak rules.
- Points equal question difficulty plus min(streak, 10); miss zeros streak unless a ShieldMark from every seventh correct day is spent.
- Journal lists filed Cards with the staked Choice and outcome, not a live quiz transcript.
- Stats hero is a Swift Charts timeline of streak length and daily points.
- Local Trophies unlocked from streak and deck milestones; no lives shop and no IAP.
- Peel removes the StakeMark only before Seal; after Seal the day is scored.
- Bundled JSON question bank in-app; AVCaptureMetadataOutput and cgi search pl axes stay unused.

---

## 3. Uniqueness assignment for Tossup

| Axis | Assigned value |
| --- | --- |
| Architecture | **Stake ADT fold (Open | Staked | Sealed | Scored); the ticket is a fold over Choices for the daykey; Stake writes a StakeMark on one live Choice and folds Open to Staked; Seal writes a SealMark and folds Staked to Sealed; Score writes a Card when Sealed, applying difficulty plus min(streak, 10) on a correct StakeMark or MissMark on a miss, and folds Sealed to Scored; every seventh consecutive correct day writes ShieldMark; spending ShieldMark on a miss preserves streak; Seal on Open is refused; Stake on Sealed is refused; a second Stake while Staked writes WaverMark; Peel drops the StakeMark only before Seal; empty ticket writes Blank** |
| UI approach | **SwiftUI + Swift Charts · timeline** |
| Naming convention | **Quiz bowl / turnstile lexicon** |
| File organization | **By ticket role (Drop, Choice, StakeMark, SealMark, Card, MissMark, ShieldMark, WaverMark, EarlyMark, Deck, Streak)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **vodafone · masonry · branded** |
| Typography | **Cochin** |
| Navigation pattern | **Ticket-strip locked chrome (today's admission ticket and streak timeline never leave; Journal, Stats, Trophies and Settings arrive as sheets; stake and seal fuse on Today; no tab bar)** |
| AI art style | **Art Deco poster · collage** |
| Functional twist | **Stake-then-seal (StakeMark on one Choice, SealMark freezes before reveal, Score files Card; ShieldMark every seventh correct; WaverMark on restake; Peel only before Seal; seed deals today's Drop so Stake is the first live tap)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — daily_trivia

**Core** — A daily player stakes one answer on today's trivia ticket, seals the pick, and earns a scored card on the streak timeline.

**Audience** — People who want one honest question a day with a deliberate commit step, not a four-tap cull, a double-cross board, or an endless quiz feed.

**User flow**

1. On Today, tap one of the four choices to write a StakeMark on that Choice.
2. Tap Seal to freeze the staked Choice before the reveal.
3. Read the why line and collect the Card into the Journal.
4. Open Stats to see the Swift Charts streak and points timeline.
5. Open Settings to toggle themed decks and reset local progress.

**Essential features**

- One bundled Drop per calendar day from selected Decks (dayIndex modulo pool; no remote fetch).
- Stake-then-seal fold: StakeMark on a Choice, SealMark before score, Card on correct or miss with streak rules.
- Points equal question difficulty plus min(streak, 10); miss zeros streak unless a ShieldMark from every seventh correct day is spent.
- Journal lists filed Cards with the staked Choice and outcome, not a live quiz transcript.
- Stats hero is a Swift Charts timeline of streak length and daily points.
- Local Trophies unlocked from streak and deck milestones; no lives shop and no IAP.
- Peel removes the StakeMark only before Seal; after Seal the day is scored.
- Bundled JSON question bank in-app; AVCaptureMetadataOutput and cgi search pl axes stay unused.

**Twist** — Stake-then-seal. Home is today's admission ticket with the stem, four Choices, and a docked streak timeline. Stake on a live Choice writes a StakeMark and folds Open to Staked. Seal writes a SealMark, freezes the StakeMark, and folds Staked to Sealed. Score writes a Card when Sealed: correct adds difficulty plus min(streak, 10) and increments streak; miss writes MissMark, zeros streak unless the player spends one ShieldMark from the every-seventh-correct grant. Seal on Open writes EarlyMark and is refused. Stake on Sealed is refused. A second Stake while Staked writes WaverMark and keeps Staked. Peel drops the StakeMark only before Seal. Collect fuses the why line after Scored. Seed already holds Open with today's Drop dealt so the opening tap is Stake. Home verb: stake-then-seal — not cull-the-field and not cross-twice-then-call. Local only.

**Why this is not a repeat** — Third daily_trivia verb in the portfolio: Oleograph files the survivor by culling three slips (Field-cull); Colloquy eliminates two wrong choices then calls among two (Cross-out); Turnstile requires an explicit stake on one choice and a separate seal before score (Stake ADT). Navigation avoids Drop-tab and Dock-locked chrome already used by those apps. Axes follow the batch hint (Swift Charts timeline, vodafone masonry, SF Pro) while swapping art to Art Deco poster · collage because Bauhaus geometric · collage is already on Studlink.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Today = one drop card.
- Invariant: dayIndex % pool.count from selected decks. Points = difficulty + min(streak,10). Miss zeros streak unless a shield (every 7-day streak).
- Never: One question a day. No IAP.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The day's ticket is a Stake ADT fold over its Choices, with states Open, Staked, Sealed, and Scored, keyed by a daykey Int in YYYYMMDD form taken from Calendar.current.startOfDay. Stake on one live Choice writes a StakeMark and folds Open to Staked, a second Stake while Staked writes a WaverMark and does not replace that StakeMark, and Stake on Sealed is refused. Seal writes a SealMark and folds Staked to Sealed, Seal on Open writes an EarlyMark and is refused, and Peel drops the StakeMark only while the ticket is still Staked. The Today control fuses Seal into Score so the answer stays hidden until the seal: Score files a Card, a correct StakeMark adds difficulty plus the minimum of the streak before the increment and 10 and then increments streak, and a miss files a MissMark that zeros streak unless the player spends one ShieldMark. Every seventh consecutive correct day writes one ShieldMark, and spending it on a miss keeps the streak. An empty ticket writes Blank, today's Drop is dayIndex modulo the bundled pool of selected Decks, and a unit test locks that selection, the points formula, and the refused folds.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

SwiftUI only, with the streak drawn by Swift Charts as a Chart of LineMark series for streak length and daily points, never an image and never a UIViewRepresentable. Today is a masonry of one large admission-ticket hero, then uneven Choice tiles, then a full-width chart strip that does not repeat the ticket's column structure. One radius pair, 28 on the filled-capsule verb and 14 on tiles, and one shadow. The live verb wears the accent: Stake while Open, Seal while Staked. Press scales to 0.97 in 140 to 180ms ease-out, sheets scale from 0.96 to 1 with a fade, and Reduce Motion keeps opacity only. A ButtonStyle covers default, pressed, disabled, and loading. Reset uses a destructive style. Native Button and Toggle only, contentShape on the whole chrome, minimum 44pt. Colour is never the only signal. One haptic when Score files the Card, none when a sheet opens. Voice is status first: Stake sealed. Miss. Streak cleared. Already staked. Peel to change.

### 3.3 Naming contract

Convention: Quiz bowl / turnstile lexicon.

Examples to follow: `Drop`, `StakeMark`, `sealTicket()`, `ShieldMark`

### 3.4 Dependency contract

Zero external dependencies. No Swift Package Manager entry, no CocoaPods, no vendored source, and no packages key. System frameworks only: SwiftUI and Charts for the ticket and the timeline, Foundation for Codable, NumberFormatter, and Calendar, UIKit only for the commit haptic and for opening the contact URL. Core Graphics, AVFoundation, and URLSession stay unused because the ticket does not draw a capture preview and does not call the search endpoint. No WebView, no analytics, no remote config.

### 3.5 Navigation contract

Ticket-strip locked chrome. Today's admission ticket and the docked streak timeline never leave the root. Journal, Stats, Trophies, and Settings arrive as sheets. Stake and Seal fuse on Today. There is no tab bar and no TabView. Sheet buttons sit on the strip, each a full Button label. Read ProcessInfo arguments once, after onboarding is done. -ReviewScreen today stays on Today, log presents Journal, goals presents Stats, trophies presents Trophies, and settings presents Settings. Those are launch keys, not tabs. If onboarding is still up, the hook does not fire.

### 3.6 Screen composition contract

Ticket-root fused timeline (Today holds the prompt, choice rail, fused stake and seal, and embedded Swift Charts streak strip; Journal, Stats, Trophies and Settings are sheets; maps family Today|Journal|Stats|Trophies|Settings without TabView). Physical screens: Onboarding, three or four pages, Continue or Next full width at the bottom, skip writes default decks. Today, the mechanic itself: stem hero, four Choices, fused Stake and Seal, Peel only before Seal, embedded streak strip, sheet buttons for the other four destinations. Journal sheet lists filed Cards with the staked Choice and the outcome, not a live transcript. Stats sheet is the large Swift Charts timeline of streak length and daily points, a different frame from the home strip. Trophies sheet lists local marks earned from streak and deck milestones. Settings sheet toggles themed Decks, confirms reset by naming the filed cards and the streak that will be erased, and links to https://tossup-ticket.pro/contact-us. Empty states are full pages with generated art, one headline, one line, and a bottom CTA: Today's drop is waiting. No card filed yet.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By ticket role (Drop, Choice, StakeMark, SealMark, Card, MissMark, ShieldMark, WaverMark, EarlyMark, Deck, Streak)**

```
Tossup/
  Drop/Drop.swift
Drop/TicketFold.swift
Drop/TicketChart.swift
Drop/TodayTicket.swift
Drop/Onboarding.swift
Choice/Choice.swift
Choice/ChoiceRail.swift
StakeMark/StakeMark.swift
SealMark/SealMark.swift
Card/Card.swift
Card/JournalSheet.swift
MissMark/MissMark.swift
ShieldMark/ShieldMark.swift
WaverMark/WaverMark.swift
EarlyMark/EarlyMark.swift
Deck/Deck.swift
Deck/QuestionBank.json
Deck/SettingsSheet.swift
Streak/Streak.swift
Streak/StreakStrip.swift
Streak/StatsSheet.swift
Streak/TrophiesSheet.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Today
A first-class screen for **Today**. Must render empty, populated and error states.

### 5.3 Journal
A first-class screen for **Journal**. Must render empty, populated and error states.

### 5.4 Stats
A first-class screen for **Stats**. Must render empty, populated and error states.

### 5.5 Trophies
A first-class screen for **Trophies**. Must render empty, populated and error states.

### 5.6 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.7 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.8 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Question** — named per this app's convention.
- **Answer** — named per this app's convention.
- **Progress** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **vodafone · masonry · branded**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#FFFFFF` | Screen background |
| `surface` | `#FFFFFF` | Cards, rows, sheets |
| `ink` | `#000000` | Primary text and icons |
| `accent` | `#E60000` | Primary action, key figure, progress fill |
| `muted` | `#6B6B6B` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Tossup/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Cochin**

Cochin is the only UI face, through one accessor as Font.custom relative to a text style so Dynamic Type scales it. Today uses two steps and no third weight: Cochin-Bold for one short uppercase display line (the ticket state, one or two lines), then Cochin caption. The stem and the why line sit on the body step, about 17pt. The scale elsewhere is at most six steps, display, title, headline, body, caption, and micro, and the display step starts at 34pt before accessibility scaling. No fixedSize. Points, streak, difficulty, and shield count go through NumberFormatter with tabular digits. Day edges use Calendar.current.startOfDay before the YYYYMMDD int. At the largest size the ticket grows instead of clipping the stem. If Cochin's thin serifs fail that size, long lines fall back to New York. No second decorative family.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **28pt** for cards, sheets and primary surfaces; **14pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI + Swift Charts · timeline**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI + Swift Charts · timeline** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **vodafone** — steal rhythm and restraint, not their colours or logos.

Mood: **Global telecom brand. Monumental uppercase display, Vodafone Red chapter bands.**.

Home rhythm (`masonry`, dense): Uneven tiles, no empty hole, one hero tile larger than the rest.

High-end agency: huge type, air, one accent, hairline depth. Layout `masonry`, density dense. Kit 28/14, shadow, filled capsule. Palette recipe `branded`. Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: One display size, then caption. No third weight on home. Reference type feel: agency.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`tactical`): Status-first. Noun plus state. 'Scan failed. Try again.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults holds one Codable Chart root, TicketChart, under the single key tsp.chart.v1. TicketChart holds the selected Decks, the ticket fold for each daykey, the live StakeMark, SealMarks, Cards, MissMarks, ShieldMarks, WaverMarks, EarlyMarks, and the Streak. Marks and the why line come from the bundled bank copied into the chart when the Drop is dealt. Each mark schedules a debounced save of that one record, about 400ms after the last change, with an immediate flush when scenePhase leaves active. daykey is an Int in YYYYMMDD form from Calendar.current.startOfDay. TicketChart is the only storage seam. The UI never touches UserDefaults. resetAllData() deletes the key and is reachable from Settings. A decode failure replaces the record with a fresh chart. Simulator seed runs once behind tsp.demo.v1, marks onboarding complete, deals today's Drop in Open so Stake is enabled, and files several prior Cards so Journal and the chart are already in use. No seed on device. No iCloud and no account.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Tossup/1.0 (iOS; +https://tossup-ticket.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.education`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.education
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Stake-then-seal (StakeMark on one Choice, SealMark freezes before reveal, Score files Card; ShieldMark every seventh correct; WaverMark on restake; Peel only before Seal; seed deals today's Drop so Stake is the first live tap)

Home is today's admission ticket, the stem, four Choices, and a docked streak timeline, and the simulator seed already holds Open with today's Drop dealt so the first live tap is Stake. Stake writes a StakeMark on one Choice and folds Open to Staked. Seal writes a SealMark that freezes that Choice before the reveal, then Score files the Card in the same commit. A correct Card adds difficulty plus the minimum of the current streak and 10, then increments streak. A miss writes MissMark and zeros streak unless the player spends one ShieldMark granted on every seventh consecutive correct day. Collect shows the why line only after Scored. Seal on Open writes EarlyMark and is refused, Stake on Sealed is refused, a second Stake while Staked writes WaverMark and keeps the original StakeMark, and Peel drops the StakeMark only before Seal. The home verb is stake-then-seal, one question a day, local only, with no lives shop.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Art Deco poster · collage**


Base prompt, reused and extended for every asset:

```
Art Deco poster collage. Symmetrical cut-paper planes, stepped arches, a sunburst fan, chevron engraving, and a solid central subject with torn paper edges on a flat poster ground. Hard edges, no glass, no clay, no photograph, no lettering.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `tsp_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `tsp_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `tsp_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `tsp_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `tsp_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `tsp_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `tsp_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `tsp_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `tsp_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `tsp_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `tsp_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Stake-then-seal (StakeMark on one Choice, SealMark freezes before reveal, Score files Card; ShieldMark every seventh correct; WaverMark on restake; Peel only before Seal; seed deals today's Drop so Stake is the first live tap)' feature screen. |
| 11 | `tsp_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `tsp_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`tsp_AppIcon`** — 1024x1024

```
Art Deco poster collage emblem of a turnstile arm crossing a sealed admission ticket, one solid subject filling the canvas edge to edge, no lettering, no rounded mask, no shadow outside the canvas.
```

**`tsp_Splash`** — 1290x2796

```
Art Deco poster collage, vertical, stepped arches and a sunburst, a wide quiet centre band with no lettering so a wordmark can sit on it, filling the frame.
```

**`tsp_Onboarding1`** — 1024x1536

```
Art Deco poster collage cutout of one admission ticket, solid paper subject centred on a transparent ground.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tsp_Onboarding2`** — 1024x1536

```
Art Deco poster collage cutout of a hand pressing a seal onto a ticket corner, mid gesture, solid subject centred.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tsp_Onboarding3`** — 1024x1536

```
Art Deco poster collage cutout of a short stack of scored cards bound by a ribbon, solid subject centred.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tsp_EmptyHome`** — 1024x1024

```
Art Deco poster collage cutout of a folded blank ticket, solid opaque paper, not a hollow frame and not glass, calm and waiting.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tsp_EmptyList`** — 1024x1024

```
Art Deco poster collage cutout of an empty open journal folio with blank pages, solid subject centred.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tsp_CardBackdrop`** — 1200x800

```
Art Deco poster collage abstract frieze of fans and chevrons filling the canvas, low contrast so type stays readable, no lettering.
```

**`tsp_ControlFace`** — 512x512

```
Art Deco poster collage of a solid seal-stamp disc with an engraved fan on its face, thick and centred, not a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tsp_TwistHero`** — 1024x1024

```
Art Deco poster collage emblem of one choice marked on a four-choice ticket and then sealed, solid central subject, no lettering.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tsp_SuccessMark`** — 512x512

```
Art Deco poster collage of a solid filled medallion, thick metal or ceramic, opaque in the centre of the canvas, not a thin outline and not a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`tsp_HeaderDecor`** — 1200x600

```
Art Deco poster collage wide ornamental band, a fan flanked by chevrons, no lettering.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`tsp.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `TossupTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Tossup/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Tossup -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Stake ADT fold (Open | Staked | Sealed | Scored); the ticket is a fold over Choices for the daykey; Stake writes a StakeMark on one live Choice and folds Open to Staked; Seal writes a SealMark and folds Staked to Sealed; Score writes a Card when Sealed, applying difficulty plus min(streak, 10) on a correct StakeMark or MissMark on a miss, and folds Sealed to Scored; every seventh consecutive correct day writes ShieldMark; spending ShieldMark on a miss preserves streak; Seal on Open is refused; Stake on Sealed is refused; a second Stake while Staked writes WaverMark; Peel drops the StakeMark only before Seal; empty ticket writes Blank** with no leakage across layers.
- [ ] UI approach matches **SwiftUI + Swift Charts · timeline**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Ticket-strip locked chrome (today's admission ticket and streak timeline never leave; Journal, Stats, Trophies and Settings arrive as sheets; stake and seal fuse on Today; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Cochin** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Tossup
xcodegen generate
xcodebuild build-for-testing -scheme Tossup -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.tossup.ticket/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Tossup -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.tossup.ticket/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Tossup -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.tossup.ticket/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
