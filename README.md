# Runout

Runout is for people who blow past a soft daily cap. The home screen is a limit gauge. You tick one unit at a time. When the needle enters the bracing band, the verb changes: hold Seat, then Tick.

## Architecture

The cluster is a quota fold over today's ticks, with phases Bare, Open, Braced, and Over. The unit total is the count of RunMarks, not a stored counter. Tick writes a RunMark while the total stays under the limit and under bracing (85 percent), and the tick that crosses bracing still files that RunMark and folds Open to Braced. Seat is legal only while Braced: it writes a SeatMark and opens the fold for exactly one following Tick. A Tick in Braced with no Seat in that pulse writes a WobbleMark and adds nothing. A Tick at the limit writes an OverMark and folds to Over. Seat on Open or Over is refused, and a third SeatMark on the same day is refused.

A fold fits this product because the legal verb depends on the phase, not on a list of rows. The chart cabinet keeps that fold in memory and projects it to UserDefaults under one Codable key.

## Why you would pick it

From 85 percent of the limit, Tick alone does not add a unit. You hold the bezel for two seconds. That Seat writes a SeatMark and unlocks one Tick. An unbraced Tick writes a WobbleMark. At the limit, Tick writes an OverMark and is refused. The simulator opens at 84 percent so the first Tick is enabled and the next verb is Seat, then one Tick.

## Art

Style: neon outline glowing line art, collage. Base prompt:

Neon outline glowing line art assembled as a collage. Solid filled subjects with a bright contour, layered as overlapping cut scraps. Instrument forms only: bezel, needle, band, and tick notch. No letters, no digits, and no words. Cutouts keep a solid subject in the center with transparent corners. Full-bleed pieces fill the canvas. A hollow ring or an empty wireframe is out of the technique.

- `rou_AppIcon`: A solid limit-gauge bezel with a needle, neon outline glowing line art, collage layers, subject centered and filling the middle of a full-bleed canvas, no letters, no digits, no words, no rounded mask
- `rou_Splash`: Vertical full-bleed collage of a gauge cluster, neon outline glowing line art, quiet uncluttered center band, no letters and no digits in the artwork
- `rou_Onboarding1`: A solid figure seating a gauge bezel, neon outline glowing line art collage, opaque subject in the center, transparent corners, no letters
- `rou_Onboarding2`: A solid hand pressing a bezel and a separate tick notch beside it, neon outline glowing line art collage, opaque subject, transparent corners, no letters
- `rou_Onboarding3`: A solid stack of marked day plates beside a filled gauge housing, neon outline glowing line art collage, opaque subject, transparent corners, no letters and no digits
- `rou_EmptyHome`: A solid closed gauge housing, fully filled mass, neon contour collage, waiting, opaque subject, transparent corners only, not a hollow ring
- `rou_EmptyList`: A solid closed plate with no rows, neon outline glowing line art collage, opaque subject, transparent corners, no letters
- `rou_CardBackdrop`: Abstract collage texture of soft instrument contours filling the frame edge to edge, quiet center, low contrast so type can sit on it, no letters and no subject cutout
- `rou_ControlFace`: A solid bezel disc used as the Seat control face, filled center, neon outline glowing line art collage, transparent corners, no letters
- `rou_TwistHero`: A solid emblem of a bezel being held and then one tick notch admitted, neon outline glowing line art collage, opaque subject, transparent corners, no letters
- `rou_SuccessMark`: A solid confirmation plaque with one tick notch, neon outline glowing line art collage, opaque subject, transparent corners, no letters
- `rou_HeaderDecor`: A wide solid ornament of layered tick notches and a bracing arc, neon outline glowing line art collage, transparent corners, no letters

## How it differs

Home is the fused gauge with Seat and Tick on one cluster. Calendar, Charts, History, and Settings arrive as sheets. There is no tab bar. The second verb exists only in the bracing band.

## Build

```bash
xcodegen generate
xcodebuild build-for-testing -scheme Runout -destination 'generic/platform=iOS Simulator' -jobs 2 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.runout.limit/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```
