# Runout — Build Specification

> Portfolio app 136, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Track daily units against your limit on the gauge.

| Field | Value |
| --- | --- |
| Product name | Runout |
| Bundle identifier | `com.runout.limit` |
| Domain | https://runout-limit.pro |
| Contact URL | https://runout-limit.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `rou_` |
| User-Agent | `Runout/1.0 (iOS; +https://runout-limit.pro)` |

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
   `xcodegen generate && xcodebuild -scheme Runout -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

An operator seats the bezel then ticks the runout counter so today's measure stays inside the limit gauge.

### 2.1 User flow

1. Hold Seat on the cluster bezel to unlock one tick in the bracing band
2. Tap Tick to file one unit toward today's limit
3. Open Calendar to see braced, wobble, and overrun days
4. Read Charts for runout trend against your limit
5. Set the daily limit and unit label in Settings

### 2.2 Essential behaviour

- Locked UIStackView instrument cluster with needle readout and bracing band
- Tick and Seat verbs with WobbleMark when Tick fires unbraced in warning
- Configurable daily Limit and unit label
- Calendar day marks for SeatMark, WobbleMark, and OverMark
- Charts for rolling adherence and bracing frequency
- UserDefaults+Codable single snapshot keyed by YYYYMMDD daykey
- Simulator seed at 84% of Limit so the first home verb is seat-then-tick

---

## 3. Uniqueness assignment for Runout

| Axis | Assigned value |
| --- | --- |
| Architecture | **Quota ADT fold (Open | Braced | Over); the cluster is a fold over Ticks; Tick writes a RunMark when today's total stays below the Limit and keeps Open below Bracing; crossing Bracing at 85% of Limit folds Open to Braced; Seat writes a SeatMark when Braced and folds Braced to Open for exactly one Tick; Tick while Braced without a preceding Seat in the same pulse writes WobbleMark and keeps Braced; Tick at or above Limit writes OverMark and folds to Over; Seat on Open is refused; a third SeatMark in one day is refused; empty cluster writes Bare** |
| UI approach | **UIKit UIStackView layout · material** |
| Naming convention | **Runout / limit-gauge lexicon** |
| File organization | **By quota role (Cluster, Limit, Bracing, Tick, Seat, RunMark, WobbleMark, OverMark, SeatMark)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **gradient · instrument-cluster · mid** |
| Typography | **Georgia** |
| Navigation pattern | **Gauge-locked chrome (the instrument cluster never leaves; Calendar and Charts arrive as sheets; tick and seat fuse on Cluster)** |
| AI art style | **Neon outline glowing line art · collage** |
| Functional twist | **Seat-then-tick at bracing (from 85% of Limit, Tick is refused until a two-second Seat hold writes SeatMark and unlocks one Tick; unbraced Tick writes WobbleMark; at or over Limit Tick is refused)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — metric_capacity

**Core** — An operator seats the bezel then ticks the runout counter so today's measure stays inside the limit gauge.

**Audience** — People who blow past soft daily caps and need the warning band to change the verb, not just the color.

**User flow**

1. Hold Seat on the cluster bezel to unlock one tick in the bracing band
2. Tap Tick to file one unit toward today's limit
3. Open Calendar to see braced, wobble, and overrun days
4. Read Charts for runout trend against your limit
5. Set the daily limit and unit label in Settings

**Essential features**

- Locked UIStackView instrument cluster with needle readout and bracing band
- Tick and Seat verbs with WobbleMark when Tick fires unbraced in warning
- Configurable daily Limit and unit label
- Calendar day marks for SeatMark, WobbleMark, and OverMark
- Charts for rolling adherence and bracing frequency
- UserDefaults+Codable single snapshot keyed by YYYYMMDD daykey
- Simulator seed at 84% of Limit so the first home verb is seat-then-tick

**Twist** — Seat-then-tick at bracing. Home is the cluster. Below 85% of Limit, Tick writes a RunMark and adds one unit. From 85% upward, Tick alone writes WobbleMark and is refused. Seat is a two-second hold on the bezel; it writes SeatMark and unlocks exactly one Tick. Tick at or above Limit writes OverMark and is refused. Seat on Open is refused. A third SeatMark in one day is refused. Seed already totals 84% of Limit so the opening Tick crosses into Bracing and demands Seat first. Home verb: seat-then-tick — not log-a-unit and not crest-the-weir. Calendar and Charts arrive as sheets. Local only.

**Why this is not a repeat** — First metric_capacity app in the ledger. Home is a fused gauge with a second verb (Seat) that only appears in the bracing band — not Castellum/Phreatic hydration, not Stackfreed lost-beat mend, and not the generic five-tab today-vs-capacity chrome flagged in craft.py. Uses all assigned free axes including UIKit UIStackView · material, gradient instrument-cluster design, and Neon outline collage art.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Today metric vs capacity — only if you add a real second verb. Prefer another family.
- Invariant: If you must: one unit log, capacity formula, calendar. Do not ship the 5-tab chrome (Home/Calendar/History/Charts/Settings) as the uniqueness.
- Never: This family is a clone cluster. Pick a rare verb or a different family.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The cluster is a quota fold over today's Ticks, with states Open, Braced, and Over, and Bare when the cluster holds nothing. Tick writes a RunMark and adds one unit while the total stays under both the Limit and Bracing, 85 percent of Limit, keeping the fold Open, and the Tick that crosses Bracing still writes that RunMark then folds Open to Braced. Seat is legal only while Braced: it writes a SeatMark and folds Braced to Open for exactly one following Tick, after which the total is folded again. A Tick in Braced with no Seat in that same pulse writes a WobbleMark, adds nothing, and stays Braced. A Tick at or above Limit writes an OverMark, adds nothing, and folds to Over, and Seat on Open or Over is refused, as is a third SeatMark on the same daykey.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Home is a UIKit view controller whose instrument is arranged only with UIStackView: a vertical stack for the needle readout, the bracing band, and the bezel, and a horizontal stack that fuses Seat and Tick. Seat is a two-second press on the bezel, not a tap. The needle and bracing band are the one custom-drawn hero, a single UIView inside that stack using Core Graphics. Calendar, Charts, History, and Settings are stock UIKit lists and forms. Surfaces use the section 7.4 radius and the single soft shadow, and primary actions use the bordered prominent control. The material extra is the instrument mass itself, bezel, band, and plate, as filled shapes. Bracing is a word on the band as well as a mark, and every control is at least 44 points, hits the whole chrome, and has a VoiceOver label. Reduce Motion fades the cluster in at once. Otherwise grouped reveals step 40 to 60 milliseconds and finish within 360 milliseconds.

### 3.3 Naming contract

Convention: Runout / limit-gauge lexicon.

Examples to follow: ClusterFold for the Open, Braced, Over fold. BracingBand for the 85 percent threshold. SeatHold for the two-second bezel gesture. RunMark, SeatMark, WobbleMark, and OverMark for the four persisted outcomes.

### 3.4 Dependency contract

No external dependencies. No Swift package, no CocoaPods, and no vendored source. The product is built with UIKit and Core Graphics. AVFoundation and URLSession are the framework ceiling and stay unused, because this product has no capture session and does not call cgi search.pl. All user data stays on the device.

### 3.5 Navigation contract

The instrument cluster never leaves. There is no TabView and no push that replaces Home. Calendar, Charts, History, and Settings arrive as sheets over the cluster. Seat and Tick are controls on the cluster, not destinations. After onboarding, read ProcessInfo arguments once. The launch key today shows the cluster, log presents Calendar, goals presents Charts, history presents History, and settings presents Settings. Each key shows a different screen. Sheet presentation has no haptic. A successful Seat or Tick is the one haptic.

### 3.6 Screen composition contract

Cluster-root fused instrument panel (Cluster holds the bezel Seat hold and Tick button; Calendar and Charts arrive as sheets; Settings as sheet; no TabView)

Physical screens: Cluster, Calendar, Charts, History, Settings. Cluster is Home. Name the home type ClusterHomeScreen. It holds the needle readout, the bracing band, the bezel Seat hold, and the Tick button, and it fills the phone and the iPad width. Bare, nothing logged today, is a full-page empty state with cutout art, one headline, one line, and a full-width bottom CTA. Calendar is a sheet of daykeys marked SeatMark, WobbleMark, or OverMark. Charts is a sheet of stock rows for rolling adherence and bracing frequency, with NumberFormatter figures, and it is not a second custom canvas. History is a sheet of marks for the open day and recent days. Settings is a sheet for the daily Limit, the unit label, re-run onboarding, a confirmed reset that removes every mark and the Limit, and the contact link https://runout-limit.pro/contact-us. Onboarding is three or four pages. Continue or Next is full width at the bottom. Skip writes a default Limit and unit label. The Simulator seed runs once, marks onboarding complete, and files several prior days plus today at 84 percent of Limit so Tick is enabled. A device is never seeded.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By quota role (Cluster, Limit, Bracing, Tick, Seat, RunMark, WobbleMark, OverMark, SeatMark)**

```
Runout/
  Cluster/ClusterFold.swift
Cluster/ClusterHomeScreen.swift
Limit/LimitGauge.swift
Bracing/BracingBand.swift
Tick/TickVerb.swift
Seat/SeatHold.swift
RunMark/RunMark.swift
WobbleMark/WobbleMark.swift
OverMark/OverMark.swift
SeatMark/SeatMark.swift
Calendar/CalendarScreen.swift
Charts/ChartsScreen.swift
History/HistoryScreen.swift
Settings/SettingsScreen.swift
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

### 5.2 Home
A first-class screen for **Home**. Must render empty, populated and error states.

### 5.3 Calendar
A first-class screen for **Calendar**. Must render empty, populated and error states.

### 5.4 Charts
A first-class screen for **Charts**. Must render empty, populated and error states.

### 5.5 History
A first-class screen for **History**. Must render empty, populated and error states.

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

- **MetricRecord** — named per this app's convention.
- **CapacityRecord** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **gradient · instrument-cluster · mid**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#284833` | Screen background |
| `surface` | `#385742` | Cards, rows, sheets |
| `ink` | `#F4F6F4` | Primary text and icons |
| `accent` | `#79D898` | Primary action, key figure, progress fill |
| `muted` | `#B6C3BA` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Georgia**

Georgia is the only face, reached through one accessor with at most six steps: display, title, headline, body, callout, and caption. Display and title use Georgia-Bold for the gauge figure and short headlines. Body, callout, and caption use Georgia. The live total, the Limit, and percents go through NumberFormatter with monospaced digits. Sizes track Dynamic Type, stay at least 12pt, and follow the content size category. At the largest accessibility size the gauge figure drops a step so the headline stays intact. Day edges use Calendar.current.startOfDay before the YYYYMMDD fold.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **20pt** for cards, sheets and primary surfaces; **12pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **bordered prominent** — primary actions use `.buttonStyle(.borderedProminent)` or an equivalent filled, bordered shape.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **UIKit UIStackView layout · material**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **UIKit UIStackView layout · material** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **warm** (Warm soft: friendly radii, comfortable pad, one playful moment.)

Reference system: **gradient** — steal rhythm and restraint, not their colours or logos.

Mood: **Smooth color transitions and gradient-rich surfaces for modern, playful interfaces with visual depth.**.

Home rhythm (`instrument-cluster`, comfortable): Gauges and readouts. The verb is a calibration, not a list.

Warm soft: friendly radii, comfortable pad, one playful moment. Layout `instrument-cluster`, density comfortable. Kit 20/12, shadow, bordered prominent. Palette recipe `mid`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Serif display once; body stays the UI face. Reference type feel: warm.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

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

UserDefaults stores one Codable root under a single key, with schemaVersion 1. The root holds the Limit, the unit label, and one record per daykey. A daykey is an Int in YYYYMMDD form, derived from Calendar.current.startOfDay. Each day record holds the fold state, the unit total, and the marks RunMark, SeatMark, WobbleMark, and OverMark. Encoding is debounced about half a second after each mark, and it flushes when the scene becomes inactive or background and after reset. Views never touch UserDefaults. Decoding failure keeps the previous good payload and otherwise starts empty. resetAllData() removes the key and is reachable from Settings. The in-memory fold is the source of truth.

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


Set `User-Agent: Runout/1.0 (iOS; +https://runout-limit.pro)` on every request. Never reuse another app's string.
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


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Seat-then-tick at bracing (from 85% of Limit, Tick is refused until a two-second Seat hold writes SeatMark and unlocks one Tick; unbraced Tick writes WobbleMark; at or over Limit Tick is refused)

From 85 percent of Limit upward, Tick is refused until the operator holds the bezel for two seconds. That hold is Seat: it writes a SeatMark and unlocks exactly one Tick, which adds one unit when the total is still under Limit. A Tick in the bracing band with no Seat in the same pulse writes a WobbleMark and does not add a unit. At or over Limit, Tick writes an OverMark and is refused, and the cluster folds to Over. Seat on an Open cluster is refused, and a third SeatMark in one day is refused. The Simulator seed stores today at 84 percent of Limit so the opening Tick is enabled, crosses into Bracing, and the following verb is Seat then one Tick.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Neon outline glowing line art · collage**


Base prompt, reused and extended for every asset:

```
Neon outline glowing line art assembled as a collage. Solid filled subjects with a bright contour, layered as overlapping cut scraps. Instrument forms only: bezel, needle, band, and tick notch. No letters, no digits, and no words. Cutouts keep a solid subject in the center with transparent corners. Full-bleed pieces fill the canvas. A hollow ring or an empty wireframe is out of the technique.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `rou_` prefix.

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
| 1 | `rou_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `rou_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `rou_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `rou_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `rou_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `rou_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `rou_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `rou_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `rou_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `rou_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Seat-then-tick at bracing (from 85% of Limit, Tick is refused until a two-second Seat hold writes SeatMark and unlocks one Tick; unbraced Tick writes WobbleMark; at or over Limit Tick is refused)' feature screen. |
| 11 | `rou_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `rou_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`rou_AppIcon`** — 1024x1024

```
A solid limit-gauge bezel with a needle, neon outline glowing line art, collage layers, subject centered and filling the middle of a full-bleed canvas, no letters, no digits, no words, no rounded mask
```

**`rou_Splash`** — 1290x2796

```
Vertical full-bleed collage of a gauge cluster, neon outline glowing line art, quiet uncluttered center band, no letters and no digits in the artwork
```

**`rou_Onboarding1`** — 1024x1536

```
A solid figure seating a gauge bezel, neon outline glowing line art collage, opaque subject in the center, transparent corners, no letters

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rou_Onboarding2`** — 1024x1536

```
A solid hand pressing a bezel and a separate tick notch beside it, neon outline glowing line art collage, opaque subject, transparent corners, no letters

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rou_Onboarding3`** — 1024x1536

```
A solid stack of marked day plates beside a filled gauge housing, neon outline glowing line art collage, opaque subject, transparent corners, no letters and no digits

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rou_EmptyHome`** — 1024x1024

```
A solid closed gauge housing, fully filled mass, neon contour collage, waiting, opaque subject, transparent corners only, not a hollow ring

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rou_EmptyList`** — 1024x1024

```
A solid closed plate with no rows, neon outline glowing line art collage, opaque subject, transparent corners, no letters

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rou_CardBackdrop`** — 1200x800

```
Abstract collage texture of soft instrument contours filling the frame edge to edge, quiet center, low contrast so type can sit on it, no letters and no subject cutout
```

**`rou_ControlFace`** — 512x512

```
A solid bezel disc used as the Seat control face, filled center, neon outline glowing line art collage, transparent corners, no letters

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rou_TwistHero`** — 1024x1024

```
A solid emblem of a bezel being held and then one tick notch admitted, neon outline glowing line art collage, opaque subject, transparent corners, no letters

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rou_SuccessMark`** — 512x512

```
A solid confirmation plaque with one tick notch, neon outline glowing line art collage, opaque subject, transparent corners, no letters

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rou_HeaderDecor`** — 1200x600

```
A wide solid ornament of layered tick notches and a bracing arc, neon outline glowing line art collage, transparent corners, no letters

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
`rou.demo.v1`.

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

Add a unit test target `RunoutTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
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
- [ ] `xcodebuild -scheme Runout -destination 'generic/platform=iOS' build` succeeds.
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
- [ ] Architecture matches **Quota ADT fold (Open | Braced | Over); the cluster is a fold over Ticks; Tick writes a RunMark when today's total stays below the Limit and keeps Open below Bracing; crossing Bracing at 85% of Limit folds Open to Braced; Seat writes a SeatMark when Braced and folds Braced to Open for exactly one Tick; Tick while Braced without a preceding Seat in the same pulse writes WobbleMark and keeps Braced; Tick at or above Limit writes OverMark and folds to Over; Seat on Open is refused; a third SeatMark in one day is refused; empty cluster writes Bare** with no leakage across layers.
- [ ] UI approach matches **UIKit UIStackView layout · material**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Gauge-locked chrome (the instrument cluster never leaves; Calendar and Charts arrive as sheets; tick and seat fuse on Cluster)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Georgia** and nothing else.
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
cd Runout
xcodegen generate
xcodebuild build-for-testing -scheme Runout -destination 'generic/platform=iOS Simulator' -jobs 2 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.runout.limit/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Runout -destination 'generic/platform=iOS' -jobs 2 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.runout.limit/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Runout -destination 'platform=iOS Simulator,id=<UDID>' -jobs 2 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.runout.limit/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
