<!-- gf-brief source=9de4ddc2eee2ea9928c5776d312ad1d249d7bdc0554da0e41af55a32de31f5e6 written=2026-10-06T20:27:15+03:00 -->
# Tigaroh
## What it is
Tigaroh is a daily trivia ticket. Each calendar day it deals one question from the decks you turned on. You stake a single choice, seal it, then read why the answer is what it is and file a card on your streak. It is for people who want one honest question a day and a deliberate commit, not an endless quiz.

## Launch and onboarding
A cold launch on a device shows a system launch screen with no words, then a three-page intro. There is no tab bar. Skip is on every page and turns every deck on, then opens Today.

1. Headline **"ONE TICKET."** Body **"One question a day. Stake a single choice before you see the answer."** Buttons **"Next"** and **"Skip"**.
2. Headline **"SEAL IT."** Body **"Seal freezes the stake. Peel only works before that seal."** Buttons **"Next"** and **"Skip"**.
3. Headline **"FILE THE CARD."** Body **"A correct seal adds difficulty plus the streak, capped at 10. A miss clears the run unless you spend a shield."** Three toggles, all on: **"World"**, **"Science"**, **"Arts"**. Buttons **"Continue"** and **"Skip"**.

**"Continue"** writes the decks that are on and opens Today. If every toggle is off, **"Continue"** still turns all three decks on. **"Skip"** also turns all three on.

A later launch that already finished the intro opens Today with the saved ticket. On Simulator only, the first launch can skip the intro, turn every deck on, file four prior correct cards, and leave today's ticket **Open** so the first tap is a choice.

If the saved ticket cannot be read, a full-page cover appears after the intro: **"Chart replaced."** / **"Saved ticket could not be read. Started a fresh chart."** / **"Continue"**. **"Continue"** dismisses the cover and shows a fresh Today.

## Screens
There is no tab bar. Today stays on screen. **"Journal"**, **"Stats"**, **"Trophies"**, and **"Settings"** open as sheets. Each sheet has an **X** close control. VoiceOver reads **"Close journal"**, **"Close stats"**, **"Close trophies"**, or **"Close settings"**.

### Today
Title band **"TODAY"**.

While today's ticket is loading, VoiceOver reads **"Loading today's ticket."** There is no other loading copy.

When a live ticket is ready, the hero shows the phase in capitals, a caption, the day's question, and three figures:

| Phase | Caption |
| --- | --- |
| **"OPEN"** | **"Tap a pick to stake."** |
| **"STAKED"** | **"Seal freezes the pick."** |
| **"SEALED"** | **"Seal is filing the card."** |
| **"SCORED"** | **"Card filed."** |

Figures: **"Difficulty"**, **"Streak"**, **"Shields"**.

Four answer tiles sit under the question. Each unused tile is labelled **"Choice"** plus the answer text. The staked tile is labelled **"Staked"** plus that answer. VoiceOver on a live tile is **"Stake [answer]"** or **"Staked [answer]"**. Tapping a **"Choice"** while **Open** stakes that answer. Tapping another tile after that does not change the pick.

Primary button by phase:

- **Open:** **"Stake"** (enabled). Tapping it does not stake. It only sets the status to **"Pick a choice."** Stake by tapping a **"Choice"** tile.
- **Staked:** **"Seal"** (enabled). Tapping it freezes the pick, scores the day, and files the card. The answer stays hidden until this tap finishes.
- While filing: **"Seal"** stays up with a spinner and will not take a second tap.
- **Scored:** **"Filed"** (disabled). The day is done.

While **Staked**, **"Peel to change."** appears with **"Peel"**. **"Peel"** returns the ticket to **Open** so you can stake again. **"Peel"** is not shown after **"Seal"**.

If at least one shield is ready, a toggle appears only while **Staked**: **"Spend shield on a miss. [n] ready."** It is off unless you turn it on.

After a score, a why plate appears. The kicker is **"Card filed"** on a correct seal, or **"Miss"** when the status contains **"Miss"**. The body is that question's why line (listed under Starter content).

Status line under the verb (VoiceOver reads the same words):

- **"Pick a choice."**
- **"Staked. Peel to change."**
- **"Already staked."**
- **"Stake refused. Ticket sealed."**
- **"Stake refused."**
- **"Seal refused. Stake first."**
- **"Score refused. Seal a staked ticket."**
- **"Stake sealed."**
- **"Miss. Shield spent."**
- **"Miss. Streak cleared."**
- **"Peel refused."**
- **"Open. Pick a choice."**
- **"Today's drop is waiting."**
- **"Chart reset."**

Below that, a timeline labelled **"STREAK"** with the live streak count, a chart legend **"Streak"** and **"Points"**, and **"Ink line is streak. Red line is points."** VoiceOver: **"Streak [n]. Timeline of points."**

Dock tiles (VoiceOver **"Journal, [n] Filed cards"**, **"Stats, [n] Points"**, **"Trophies, [n] Earned"**):

- **"Journal"** / count / **"Filed cards"** opens Journal.
- **"Stats"** / points total / **"Points"** opens Stats.
- **"Trophies"** / earned count / **"Earned"** opens Trophies.
- **"Settings"** opens Settings.

If every deck is off and today has no live question: **"Today's drop is waiting."** / **"Turn a deck on in Settings, then stake the next ticket."** / **"Settings"**.

If the question bank did not open: **"Bank unread."** / **"Question bank missing. The bundled file did not open."** / **"Retry"**.

### Journal
Title **"Journal"**.

Each row: **"Correct"** or **"Miss"**, the point total, the staked answer text, and the day in the device's medium date style. Newest day first. The question stem and the why line are not on this list.

Empty: **"No card filed yet."** / **"Stake today's choice, then seal it. The card lands here."** / **"Back to ticket"** (closes the sheet).

If the saved ticket could not be read and the list is empty: **"Journal unread."** / **"Saved ticket could not be read. Started a fresh chart."** / **"Retry"**.

### Stats
Title **"Stats"**. Section **"TIMELINE"**. The same streak-and-points chart as Today, taller, plus figures **"Points"** and **"Cards"**. Caption **"Ink line is streak. Red line is points."**

Empty: **"No card filed yet."** / **"Seal a ticket to plot streak length and daily points."** / **"Back to ticket"**.

If the saved ticket could not be read and the chart is empty: **"Stats unread."** / **"Saved ticket could not be read. Started a fresh chart."** / **"Retry"**.

### Trophies
Title **"Trophies"**. Section **"MARKS"**. Each mark is **"Earned"** or **"Locked"**, then the title and detail:

- **"First card"** — **"File one scored card."**
- **"Three day run"** — **"Hold three correct days."**
- **"Shield filed"** — **"Every seventh correct day grants one."**
- **"Double digits"** — **"Score at least 10 points on one card."**
- **"All decks on"** — **"Keep every themed deck in the pool."**

Empty (none earned): **"No trophy filed yet."** / **"A filed card, a three day run, and a shield each leave a mark."** / **"Back to ticket"**.

If the saved ticket could not be read and none are earned: **"Trophies unread."** / **"Saved ticket could not be read. Started a fresh chart."** / **"Retry"**.

### Settings
Title **"Settings"**. Section **"DECKS"**.

Toggles **"World"**, **"Science"**, **"Arts"**, each with **"3 drops"**. Turning a deck on or off changes which questions can be dealt. If today's ticket is still **Open**, today is re-dealt from the decks that remain on. If you already staked or sealed today, today's question stays.

**"Replay intro"** closes Settings and shows the three intro pages again. Filed cards and the streak stay. Finishing with **"Continue"** or **"Skip"** returns to Today.

**"Reset chart"** opens **"Reset the chart?"** with **"Reset erases [n] filed cards and streak [n]."** (the same sentence also sits under the buttons). **"Reset"** wipes the chart and returns you to the intro. **"Cancel"** leaves everything as it is.

**"Contact"** opens the support page.

If the decks did not open: **"Decks unread."** / **"The bundled bank did not open."** / **"Retry"**.

If Settings cannot be read after a failed load: **"Settings unread."** / **"Saved ticket could not be read. Started a fresh chart."** / **"Retry"**.

## Features
- One ticket a day: one question, four choices
- **"Stake"** a **"Choice"** before you see the answer
- **"Peel"** to change the stake, only before **"Seal"**
- **"Seal"** freezes the pick and files the **"Card"**
- Why line after the card is filed (**"Card filed"** or **"Miss"**)
- **"Difficulty"**, **"Streak"**, and **"Shields"** on today's ticket
- A correct seal adds difficulty plus the streak, capped at 10
- A miss clears the run unless you **"Spend shield on a miss"**
- A shield is granted on every seventh correct day
- **"Journal"** of **"Filed cards"** (**"Correct"** / **"Miss"**, points, staked answer, day)
- **"Stats"** **"TIMELINE"** of streak length and daily points (**"Ink line is streak. Red line is points."**)
- **"Trophies"** **"MARKS"**: **"First card"**, **"Three day run"**, **"Shield filed"**, **"Double digits"**, **"All decks on"**
- Themed decks **"World"**, **"Science"**, **"Arts"**
- **"Replay intro"**
- **"Reset chart"**
- **"Contact"**

## Behaviours that can look like bugs
- **"Stake"** on an **Open** ticket does not lock an answer. Status becomes **"Pick a choice."** Tap a **"Choice"** tile instead, then **"Seal"**.
- A second **"Choice"** tap after a stake does not move the pick. Status **"Already staked."** Tap **"Peel"**, then stake again.
- **"Peel"** is missing until the ticket is **Staked**, and it is gone after **"Seal"**. After a seal the day is scored. Status if peel cannot run: **"Peel refused."**
- **"Filed"** looks like a button and does nothing. Today's ticket is finished. A new question arrives on the next calendar day, including if you leave the app overnight and come back.
- **"Seal"** can sit disabled with a spinner while the card is filing. Wait until the phase is **"SCORED"** and the why line appears.
- Choice tiles do not accept taps after **"Seal"**. That is the freeze.
- Every deck off: **"Today's drop is waiting."** Open **"Settings"**, turn at least one deck on, then stake.
- **"Continue"** on the last intro page with every deck off still turns **"World"**, **"Science"**, and **"Arts"** all on. There is no intro path that starts with an empty pool.
- Turning decks off after you already staked or sealed today does not change today's question. Only an **Open** ticket is re-dealt.
- **"Journal"**, **"Stats"**, and **"Trophies"** are empty until the first **"Seal"**. Use **"Back to ticket"**, stake a **"Choice"**, then **"Seal"**.
- **"Spend shield on a miss. [n] ready."** is hidden until a shield exists. A shield arrives on the seventh consecutive correct day.
- **"Double digits"** needs at least 10 points on one card (difficulty plus streak, streak portion capped at 10). A first-day seal will not reach it.
- **"Replay intro"** loops back to **"ONE TICKET."** on purpose. **"Next"** / **"Continue"** or **"Skip"** returns to Today.
- **"Reset chart"** will not run until **"Reset"** on **"Reset the chart?"**. **"Cancel"** leaves the chart.
- **"Chart replaced."** after a failed load: tap **"Continue"**. The chart is already fresh.
- **"Bank unread."** / **"Decks unread."**: tap **"Retry"**.

## Starter content and resume
Bundled decks and every question the app can deal. Today's question is one item from the decks that are on, in this order, one per calendar day:

**World**
- **"Which river is the longest in Africa?"** **"Amazon"**, **"Nile"**, **"Congo"**, **"Niger"**. Difficulty 2. After a seal: **"The Nile runs north through northeastern Africa to the Mediterranean."**
- **"Which city is the capital of Japan?"** **"Tokyo"**, **"Osaka"**, **"Kyoto"**, **"Sapporo"**. Difficulty 1. After a seal: **"Tokyo has been the capital since the late nineteenth century."**
- **"The Andes run along which continent?"** **"Europe"**, **"Africa"**, **"South America"**, **"Australia"**. Difficulty 2. After a seal: **"The Andes follow the western edge of South America."**

**Science**
- **"What is the chemical symbol for water?"** **"CO2"**, **"H2O"**, **"NaCl"**, **"O2"**. Difficulty 1. After a seal: **"Water is two hydrogen atoms bonded to one oxygen atom."**
- **"Which planet is called the Red Planet?"** **"Venus"**, **"Jupiter"**, **"Mercury"**, **"Mars"**. Difficulty 1. After a seal: **"Iron oxide on the surface gives Mars its red color."**
- **"About how fast does light travel in a vacuum?"** **"300,000 km/s"**, **"300 km/s"**, **"3,000 km/s"**, **"30 km/s"**. Difficulty 3. After a seal: **"Light in a vacuum moves at about 300,000 kilometres per second."**

**Arts**
- **"Who painted the Mona Lisa?"** **"Michelangelo"**, **"Raphael"**, **"Leonardo da Vinci"**, **"Donatello"**. Difficulty 1. After a seal: **"Leonardo da Vinci painted it in the early sixteenth century."**
- **"How many symphonies did Beethoven complete?"** **"Seven"**, **"Nine"**, **"Twelve"**, **"Four"**. Difficulty 3. After a seal: **"Beethoven completed nine symphonies."**
- **"Who wrote Hamlet?"** **"William Shakespeare"**, **"Christopher Marlowe"**, **"Ben Jonson"**, **"John Milton"**. Difficulty 2. After a seal: **"William Shakespeare wrote Hamlet around 1600."**

Unfinished work resumes. A stake you have not sealed comes back as **Staked** with **"Staked. Peel to change."** A sealed day stays **"SCORED"** with **"Stake sealed."** and the why line. Filed cards, streak, shields, and deck toggles come back on the next launch.

**"Reset chart"** erases filed cards and the streak and returns you to the intro. That work cannot be resumed.

On Simulator only, the first launch can already hold four prior **"Correct"** cards, a streak of 4, **"First card"**, **"Three day run"**, and **"All decks on"** earned, and today's ticket **Open**. A device first launch has none of that.

## Permissions
None

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content, account deletion flow, and the App Tracking Transparency prompt are all absent.

## Data and support
Data stays on this device. **"Contact"** in **"Settings"** opens the support page. **"Reset chart"** erases local cards and the streak after **"Reset"** on **"Reset the chart?"**.

## Scanning and health
None

## Platform
Copy is English only. There is no country lock. Counts and day labels follow the device locale. Portrait only, iPhone and iPad, full screen on iPad. Light appearance. Minimum iOS 17.0. Home-screen name **Tigaroh**.

## Category
Education
