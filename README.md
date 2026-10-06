# Tossup

Tossup is a daily trivia ticket for people who want one honest question and a deliberate commit. You stake one choice, seal it, and file a scored card on a streak timeline. Everything stays on this device.

## Architecture

The day is a Stake ADT fold: Open, Staked, Sealed, Scored. The ticket is that fold over the four Choices for a daykey (YYYYMMDD from the start of the local day). Stake writes a StakeMark on one live Choice and folds Open to Staked. A second stake while Staked writes a WaverMark and keeps the original mark. Seal writes a SealMark and folds Staked to Sealed. Score runs in the same commit as Seal so the why line stays hidden: a correct StakeMark adds difficulty plus min(streak, 10) and then increments the streak; a miss writes a MissMark and zeros the streak unless a ShieldMark is spent. Every seventh consecutive correct day writes one ShieldMark. Seal on Open writes an EarlyMark and is refused. Stake on Sealed is refused. Peel drops the StakeMark only while the ticket is still Staked. An empty pool writes Blank.

This fits the product because the answer must stay sealed until the player commits, and a restake must not quietly swap the pick. One TicketChart record holds the tickets, marks, cards, and streak. The screens call the fold. They never touch UserDefaults. A debounced save follows each mark, with a flush when the scene leaves active.

## Why someone would pick it

Stake, then seal. Home is today's admission ticket: the stem, four uneven choices, and a docked Swift Charts timeline of streak length and daily points. Journal, Stats, Trophies, and Settings arrive as sheets. There is no tab bar and no lives shop.

## Art

Style: Art Deco poster collage. Symmetrical cut-paper planes, stepped arches, a sunburst fan, chevron engraving, and a solid central subject with torn paper edges on a flat poster ground. Hard edges, no glass, no clay, no photograph, no lettering.

Image sets are named and left empty for the asset pass:

- tsp_AppIcon: Art Deco poster collage emblem of a turnstile arm crossing a sealed admission ticket, one solid subject filling the canvas edge to edge, no lettering, no rounded mask, no shadow outside the canvas.
- tsp_Splash: Art Deco poster collage, vertical, stepped arches and a sunburst, a wide quiet centre band with no lettering so a wordmark can sit on it, filling the frame.
- tsp_Onboarding1: Art Deco poster collage cutout of one admission ticket, solid paper subject centred on a transparent ground.
- tsp_Onboarding2: Art Deco poster collage cutout of a hand pressing a seal onto a ticket corner, mid gesture, solid subject centred.
- tsp_Onboarding3: Art Deco poster collage cutout of a short stack of scored cards bound by a ribbon, solid subject centred.
- tsp_EmptyHome: Art Deco poster collage cutout of a folded blank ticket, solid opaque paper, calm and waiting.
- tsp_EmptyList: Art Deco poster collage cutout of an empty open journal folio with blank pages, solid subject centred.
- tsp_CardBackdrop: Art Deco poster collage abstract frieze of fans and chevrons filling the canvas, low contrast so type stays readable, no lettering.
- tsp_ControlFace: Art Deco poster collage of a solid seal-stamp disc with an engraved fan on its face, thick and centred, not a hollow ring.
- tsp_TwistHero: Art Deco poster collage emblem of one choice marked on a four-choice ticket and then sealed, solid central subject, no lettering.
- tsp_SuccessMark: Art Deco poster collage of a solid filled medallion, thick metal or ceramic, opaque in the centre of the canvas, not a thin outline and not a hollow ring.
- tsp_HeaderDecor: Art Deco poster collage wide ornamental band, a fan flanked by chevrons, no lettering.

## How it differs

Other daily trivia apps in the batch cull three slips or cross out two wrong choices. Tossup requires an explicit stake on one choice and a separate seal before the score. Navigation keeps today's ticket and the streak strip on screen. The look is a Vodafone-like red chapter band and monumental Cochin display on a masonry of uneven tiles, with Art Deco collage art.

## Build

```bash
cd apps/Tossup
xcodegen generate
xcodebuild build-for-testing -scheme Tossup -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```
