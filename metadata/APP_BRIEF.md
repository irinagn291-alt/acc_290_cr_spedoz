<!-- gf-brief source=add0bc832fc58bed56291ae22e9eaee59d04551f84fa30bc4690ef6d5311ccf8 written=2026-09-29T18:51:44+03:00 -->
# Runout

## What it is
Runout is a personal daily counter. You file one unit at a time so today's measure stays inside a Daily limit you choose, and you watch the needle on the cluster. It is for anyone who overruns a soft daily cap and wants the bracing band to change the next action — hold Seat, then Tick — not only to change a colour.

## Launch and onboarding
A cold launch on a device that has never finished onboarding shows three pages. There is no tab bar. Copy is English only.

**Page 1.** Illustration. Headline: “Seat the bezel, then tick the day”. Line: “Runout keeps today's measure inside a limit you choose.” Buttons: “Next”, “Skip”.

**Page 2.** Illustration. Headline: “Hold Seat, then Tick”. Line: “From the bracing band, a two second hold files a seat and opens one Tick.” Buttons: “Next”, “Skip”.

**Page 3.** Illustration. Headline: “The cluster stays on this device”. Line: “Calendar and charts read the same marks. Nothing leaves the phone.” Buttons: “Continue”, “Skip”.

“Next” advances one page. “Continue” or “Skip” on any page ends onboarding, writes a Daily limit of 10 and a Unit label of “units”, and opens the cluster. A later launch that has already finished onboarding skips these pages and opens the cluster (or today's empty state if nothing is filed yet).

## Screens

### Cluster (home)
This is the first screen after onboarding. It has no navigation title. There is no tab bar. Calendar, Charts, History, Settings, and Bracing arrive as sheets over this screen. Every sheet shows a grabber and an X control whose spoken label is “Close”. Swiping down also dismisses a sheet.

**When nothing is filed today** the cluster is hidden. The full page is:

- “Nothing logged today”
- “Tick once to start today's measure inside the limit.”
- “Tick” — files the first unit today and then reveals the cluster. Calendar, Charts, History, Settings, and “How bracing works” cannot be opened until this first Tick.

**When today has at least one unit** the cluster shows, top to bottom:

- “Keep today's measure inside the limit”
- A live figure in the form “{count} of {limit} {unit label}”. If wobbles exist it appends “, {count} wobble” or “, {count} wobbles”. With the default limit that looks like “1 of 10 units”. With a filled Simulator chart it looks like “84 of 100 units”.
- A needle plate. The word “Bracing” is drawn on the plate. The needle sits at today's total against the Daily limit. Short stubs appear when wobbles have been filed.
- A next-tap line, one of:
  - “Next tap: Tick. File one {unit label} while you are still under bracing.” (default: “File one units while you are still under bracing.”)
  - “Next tap: Tick. That unit enters the bracing band and asks for Seat.”
  - “You are in the bracing band. Hold Seat for two seconds, then Tick.”
  - “{count} wobble filed and no unit added. Hold Seat for two seconds, then Tick.” or the plural “wobbles”
  - “Seat is filed. Next tap: Tick, one unit.”
  - “Today is at the limit. Tick stays closed until tomorrow.”
- “Tick” — files one unit toward today's limit when the day is still under the limit and not yet in the bracing band, or when a Seat has just been filed. In the bracing band without a Seat it does not add a unit; it files a wobble, the figure/needle/next-tap line dim briefly, and the figure gains a wobble count. At the limit the button is faded and does nothing.
- “Seat” — not a tap. Hold for two seconds. When the hold is accepted it files a seat and unlocks exactly one following Tick. A short tap does nothing. The button is faded unless you are in the bracing band, you have not just filed a Seat, and you have filed fewer than two seats today.
- Optional notice, only after a bad save or a recovered chart:
  - “The chart could not be saved. Your latest mark is still on this screen. Try the verb again.”
  - “Recovered the last good chart after a bad save.”
  - “The saved chart could not be read, so today starts empty.”
- Status card:
  - “Bracing starts at {count} {unit label}. Hold Seat, then Tick.” The count is 85 percent of the Daily limit (8 when the limit is 10; 85 when the limit is 100).
  - “Yesterday has no marks yet.” or “Yesterday filed {count} {unit label}.”
  - “How bracing works” — opens the Bracing sheet.
- Destination rows:
  - “Calendar” — opens the Calendar sheet.
  - “Charts” — opens the Charts sheet.
  - “History” — opens the History sheet.
  - “Settings” — opens the Settings sheet.

A successful Tick or Seat plays a short haptic. There is no on-screen success title.

### Calendar
Title: “Calendar”.

- Legend: “Seat is a two-second hold that opens one Tick. Wobble is a Tick in the bracing band with no Seat, and it adds no unit. Over is a Tick at the limit, and it adds no unit.”
- A grid for the current month only. There is no month name on the grid, and there is no control to move to another month. The top row is the device calendar's weekday initials. Each day is a number. Today is selected when the sheet opens.
- A day with at least one Seat, Wobble, or Over is highlighted. A day that only has ordinary Ticks looks the same as an empty day until you tap it.
- Tapping a day updates the detail. It does not leave Calendar. The detail is “{medium date}. {count} {unit label} filed. Seat {count}: {phrase}. Wobble {count}: {phrase}. Over {count}: {phrase}.”
  - Seat phrase: “no hold opened a Tick” or “a two-second hold opened one Tick”
  - Wobble phrase: “no Tick was refused in the bracing band” or “a Tick in the band added no unit”
  - Over phrase: “no Tick hit the limit” or “a Tick at the limit added no unit”
- “Next tap: a day, or Back to Tick to file today's measure.”
- “Back to Tick” — closes the sheet and returns to the cluster.

### Charts
Title: “Charts”.

- A bar drawing. Visible words on the drawing: “Limit {count}” and “Bracing”. Each bar is one stored day, labeled with month/day numbers such as “9/25”. A mint limit line sits at the Daily limit. A pale band starts at the bracing threshold. A marked bar is a day that entered the band. The bars are not buttons.
- When no days are stored:
  - “No trend yet. Tick a few days and the bars will show units against the limit.”
  - “Bracing frequency appears once a day enters the band.”
- When days are stored:
  - “Rolling adherence {percent}. Each bar is one day. The mint line is the {count} {unit label} limit. Bars that stop under it stayed inside.”
  - “Bracing frequency {percent}. The pale band starts at {count} {unit label}. A marked bar entered that band.”
  Rolling adherence is the share of days that filed at least one unit and stayed strictly under the Daily limit. A day that lands on the limit does not count as inside.
- If the chart could not be saved:
  - “Charts could not read a saved chart”
  - “Stay with the cluster and file the next mark after the save recovers.”
- “Next tap: Back to Tick. That returns you to today's measure.”
- “Back to Tick” — closes the sheet and returns to the cluster.

### History
Title: “History”. Rows are not tappable.

- Empty: “No marks filed” / “Today's ticks, seats, wobbles, and overruns will list here.”
- Filled: one row per mark, newest first, at most forty rows. Titles are exactly “Run mark”, “Seat mark”, “Wobble mark”, “Over mark”. The subtitle is the device's medium date and short time.
- If the chart could not be saved: “History is waiting on the save” / “The cluster still holds today's marks. Try again after the next Tick.”

### Settings
Title: “Settings”. Three section headers: “Limit”, “Care”, “Contact”.

**Limit**

- If the chart could not be saved, a first row: “The chart could not be saved” / “Your limit is still here. Edit it, then leave the field to try again.”
- If there are no stored days and the limit is not valid: “Set a limit to start the cluster” in place of the fields.
- Otherwise:
  - “Daily limit” — number field (digits only). Spoken label: “Daily limit”. Leaving the field saves a whole number greater than 0. Empty, zero, or non-numeric input snaps back to the previous value.
  - “Unit label” — text field. Spoken label: “Unit label”. Leaving the field saves the trimmed text. A blank label snaps back to the previous value.
- Both fields have a keyboard bar with “Done” (spoken: “Done editing”). Tapping outside the field or tapping “Done” dismisses the keyboard. The Unit label field's return key is also Done.

**Care**

- “Show onboarding again” — closes Settings and shows the three onboarding pages again. “Skip” or “Continue” returns to the cluster. Existing marks and the current limit stay; onboarding does not wipe the chart.
- “Erase every mark and the limit” — opens an alert titled “Erase the chart?” with message “This removes every mark and the daily limit. You cannot undo it.” Buttons: “Keep marks” (cancels) and “Erase chart” (wipes every mark, restores Daily limit 10 and Unit label “units”, leaves onboarding complete, and the next cluster view is “Nothing logged today”).

**Contact**

- “Contact Runout” — opens the support page.

### Bracing
Title: “Bracing”. Rows are not tappable.

- If the chart could not be saved, both rows read “Bracing notes are waiting” / “The cluster still shows the band. Save will catch up on the next mark.”
- Otherwise, first row: “Hold Seat, then Tick” / “Bracing starts at {count} {unit label}. A two second hold files a seat and opens one Tick.”
- Second row when today is empty: “The band is quiet” / “Tick under the limit until the needle reaches bracing.”
- Second row when today has marks: “Today” / “{count} filed, {count} seats, {count} wobbles.” Those words stay plural even when the count is 1.

## Features
- Daily limit and Unit label you choose (defaults after onboarding: 10 and “units”)
- Tick — file one unit toward today's measure
- Seat — two-second hold that files a seat and opens one Tick once you are in the bracing band
- Bracing band — shown as “Bracing starts at {count} {unit label}” and as the word “Bracing” on the needle and on Charts
- Wobble — a Tick in the bracing band with no Seat; it adds no unit
- Over — a Tick at the Daily limit; it adds no unit and Tick stays closed until tomorrow
- Needle on the cluster for today's total against the limit
- Next-tap copy that names Tick or Seat
- Yesterday line on the cluster
- Calendar for the current month, with Seat, Wobble, and Over named on the day you tap
- Charts for rolling adherence and bracing frequency
- History of Run mark, Seat mark, Wobble mark, and Over mark
- How bracing works / Bracing
- Three-page onboarding, with Skip, that can be shown again from Settings
- Erase every mark and the limit, after confirmation
- Contact Runout
- Marks stay on this phone; onboarding says “Nothing leaves the phone.”

## Behaviours that can look like bugs
- After a clean onboarding the home page is only “Nothing logged today”, the line “Tick once to start today's measure inside the limit.”, and “Tick”. Calendar, Charts, History, Settings, and “How bracing works” are missing until you tap “Tick” once. The same empty page returns at the start of a new local day, and after “Erase chart”.
- “Seat” ignores a tap. Hold it for two seconds. The spoken label is “Seat. Hold for two seconds.”
- “Seat” is faded until the next-tap line says you are in the bracing band (or that a wobble was filed). Below that band, holding Seat does not file a seat.
- After a successful Seat the next-tap line is “Seat is filed. Next tap: Tick, one unit.” and Seat is faded until you Tick.
- In the bracing band, “Tick” stays enabled. Tapping it without a Seat does not raise the figure; it adds “1 wobble” (or more) and the cluster dims once. That is a Wobble, not a failed tap. Hold Seat, then Tick, to add a unit.
- Only two seats are allowed in one day. After the second Seat-then-Tick, Seat stays faded. Tick still accepts taps but only files more wobbles. You cannot add another unit that day even when the figure is still under the limit. With Daily limit 10, two seats are enough to reach 10. With Daily limit 100 you can be left on 87 of 100 units. The next-tap line may still say “Hold Seat for two seconds, then Tick.” Wait until tomorrow.
- When the figure reaches the Daily limit, “Tick” fades and the line is “Today is at the limit. Tick stays closed until tomorrow.” Further Ticks do not add units. Tomorrow the empty page or a fresh count appears.
- Lowering Daily limit below today's already-filed total immediately shows “Today is at the limit. Tick stays closed until tomorrow.”
- A blank, zero, or non-digit Daily limit, or a blank Unit label, snaps back when you leave the field. The value does not change.
- “Show onboarding again” closes Settings on purpose and returns you to “Seat the bezel, then tick the day”.
- Calendar does not turn the page to other months. Days that only have Ticks (no Seat, Wobble, or Over) are not highlighted.
- History shows at most the latest forty marks. Older Run mark rows drop off the list; Calendar and Charts still know those days.
- Faded buttons (about half opacity) are disabled on purpose. They become solid when the next-tap line says that verb is next, or after tomorrow's reset.
- If a save notice appears, the marks you just filed are still on the cluster. Tick or Seat again, or edit Daily limit and leave the field.

## Starter content and resume
On a physical iPhone or iPad, none. After onboarding the chart is empty, Daily limit is 10, Unit label is “units”, and home is “Nothing logged today”.

On the iOS Simulator, a first launch can already skip onboarding and show a filled cluster: Daily limit 100, Unit label “units”, today at 84 of 100 units (next-tap line: “Next tap: Tick. That unit enters the bracing band and asks for Seat.”), yesterday filed 86 units, and two earlier days with marks (one day that entered the band, one day with 40 units). History then opens on a long list of “Run mark” rows.

Today's unfinished measure, seats, wobbles, overs, the Daily limit, and the Unit label come back after you leave and return. “Show onboarding again” does not erase them. “Erase chart” does.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content, an account deletion flow, and an App Tracking Transparency prompt are all absent. “Erase every mark and the limit” only clears the local chart; there is no account to delete.

## Data and support
Onboarding states “The cluster stays on this device” and “Nothing leaves the phone.” Marks, the Daily limit, and the Unit label stay on this device. The on-screen control is “Contact Runout”; it opens the support page.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information, dosages, or recommendations. The Unit label is whatever you type (default “units”). There are no citations. It is a personal log only.

## Platform
Copy does not change by region. Weekday initials, medium dates, short times, grouping separators, and percents follow the device calendar and locale. Portrait only on iPhone and iPad. Both device families, full screen (no Split View). Dark appearance. Minimum iOS 17.0.

## Category
Lifestyle
