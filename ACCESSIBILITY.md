# Accessibility Notes — Lookback Time Simulator

Target: WCAG 2.1 AA (AAA where reasonable). Built on the KL-UNL foundation
(`kl-unl.css`/`kl-unl.js`/`kl-unl-masthead.js`), which supplies the palette,
focus-visible handling, responsive grid, and the masthead dialog (focus trap +
Escape + focus restore). **Automated/manual checks here do not replace human
screen-reader QA**, which is still required.

## Structure & semantics
- One `<h1>` comes from the `<kl-unl-masthead>` (the sim title); panels use
  `<h2>` (`Star and Observer`, `Timeline and Controls`) with no skipped levels.
- Landmarks: `<main>` for the app layout; `<section>` per panel with
  `aria-labelledby`; the masthead provides the `<header>`/nav region.
- `<html lang="en">`. A "Skip to controls" link is the first focusable element.

## Text alternatives for the canvas (1.1.1)
The canvases are `role="img"` with `aria-label`s and are backed by polite live
description regions that restate what the diagram currently shows:
- `#display-desc` — e.g. *"A star at the left and an observer 3000 light-years
  to the right. The star has exploded; its light has expanded to about N
  light-years and has not yet reached the observer."*
- `#timeline-desc` — e.g. *"Cursor at 1200 AD. Supernova occurs 1200 AD. Light
  is observed in 4200 AD."*
- `#sr-status` — event announcements on commit (supernova triggered, light
  reached the observer, paused, resumed, reached the end, reset).

## Math / equations (rules 8 & 8a)
- **Every** numeric readout (timeline tick labels, distance, observed year,
  current year, and the distance label under the brace) is typeset by
  **MathJax** (LaTeX, SVG output). Right-clicking any of them opens MathJax's
  own context menu (*Show Math As → TeX / MathML*); the menu is left enabled and
  the `contextmenu` event is not trapped.
  (The standalone lookback-relation equation box was removed at the user's
  request; the same relationship is still conveyed by the live "is observed"
  readout and the screen-reader descriptions.)
- **Not MathJax:** the editable "supernova occurs" `<input>` (form controls
  cannot host MathJax). The same year appears MathJax-typeset in the equation.
- Tick labels and the "SN occurs"/"SN observed" labels live in an **HTML
  overlay** above the timeline canvas (not painted on the canvas) so they zoom
  and expose the MathJax menu. The distance label centered under the brace is
  likewise an HTML/MathJax overlay over the display canvas (light text on the
  dark sky). No math is baked onto either canvas.

## Color & contrast (1.4.1/1.4.3/1.4.11)
- Palette via KL-UNL CSS variables; body text ≥ 4.5:1 on white.
- **No color-only signaling.** The draggable vs. locked distance brace differs
  in color *and* the observer slider/handle is enabled/disabled accordingly;
  the "SN observed" marker is distinguished by its **text label**, not only its
  color. State is also conveyed by button labels and the live regions.
- The display "sky" is dark by design (it's the night sky); all *information*
  (numbers, labels, status) is in the high-contrast HTML around it.

## Keyboard (2.1.1/2.1.2/2.4.7)
Everything is operable by keyboard with a visible focus ring (from `kl-unl.css`):
- **Sliders are native `<input type="range">`** — Left/Down decrement, Right/Up
  increment, PageUp/PageDown larger steps, Home/End min/max — all for free,
  with real `<label>`s. They are not blocked by canvas pointer handlers and Tab
  moves away normally (no traps).
  - *Observer distance*: 1000–10000 ly, step 100. Enabled only in setup (matches
    the original: the observer is draggable only before the supernova).
  - *Timeline year (cursor)*: −7999…10000, step 1. Disabled while running
    (matches `setCursorDraggable(state != 1)`).
- *Supernova occurs* is a text field accepting `1200 AD`, `500 BC`, `CE`, etc.,
  committed on Enter/blur (mirrors the original editable field + `parseForYear`).
- Buttons (`go supernova/reset`, `pause/resume`) are native `<button>`s; the
  masthead's Reset/Help/About are keyboard-operable via the component.

Pointer dragging of the observer and the timeline cursor is **also** supported
(Pointer Events; mouse + touch share one path), and every drag mutates the same
state object as the keyboard controls, so they stay in sync.

## Timing / motion (2.2.2/2.3.3)
- A **Pause** control is provided for the running animation (the in-sim
  pause/resume button). Reset is provided by the masthead.
- `prefers-reduced-motion: reduce` is honored: *go supernova* jumps to the final
  state instead of running the expanding-light animation (the star blow-up
  frames are also skipped to the end state). Nothing flashes more than 3×/sec.
- The animation loop is on-demand: it runs only while animating or a blow-up is
  finishing, then the page goes idle.

## Responsive / zoom (1.4.4 / 1.4.10)
- Body text is ≥ 1.125rem and sized in rem/em; the layout reflows without
  clipping at 200% zoom.
- Desktop → iPad → **phone portrait**: the two panels stack full-width in
  reading order and the control groups collapse to one column below the KL-UNL
  56rem breakpoint (sim breakpoints live only in `styles/styles.css`). No
  horizontal scrolling at 375px (verified). The canvases keep their internal
  coordinate system and scale via CSS with preserved aspect ratio; pointer
  coordinates are mapped back through the live scale so drag/snapping still
  match the source at any size.
- Touch: `touch-action: none` on the draggable canvases; interactive targets
  meet the ≥44px (2.75rem) minimum from the KL-UNL button/control styles; no
  hover-only affordances.

## Known items for human QA
- Verify announcement wording/timing with NVDA/JAWS/VoiceOver (the live region
  fires on commit, not per animation frame).
- Confirm the dark display panel's decorative canvas is correctly ignored by
  screen readers while the description conveys its state.

================================================================================

## AUDIO / SCREEN-READER PASS

A narration-only pass (no behavior/layout/visual/physics changes) to make the
sim usable by audio alone on **NVDA** (Windows; Chrome + Firefox) and
**VoiceOver** (macOS; Chrome + Safari). Standard ARIA only — no reader-specific
hacks. **Final confirmation still requires a human listening test on NVDA and
VoiceOver; screen-reader compatibility is NOT claimed as verified here.**

### Values made units-complete (quantity + number + unit, spoken)
All spoken strings use unit **words**, not symbols, and never expose a bare
signed number.

| Control / readout | How spoken value is exposed | Example spoken string |
|---|---|---|
| **Timeline year (cursor)** slider (`#year-range`) | `aria-valuetext`, updated on every change (the raw `value`/`aria-valuenow` stays the signed year) | label "timeline year (cursor)" + **"1200 AD"** / **"8000 BC"** |
| **Distance** slider (`#dist-range`) | `aria-valuetext`, updated on every change | label "distance" + **"3000 light years"** |
| **"is observed"** boxed readout (`#observed-output`) | MathJax box set `aria-hidden`; an adjacent `.sr-only` (`#observed-sr`) carries the value, read after the visible "is observed:" label | **"is observed: 4200 AD"** |
| **"supernova occurs"** input (`#sn-year-input`) | native `<label>` + `.sr-only` hint (`#sn-year-hint`) | "supernova occurs: 1200 AD … Type a year such as 1200 AD or 500 BC, then press Enter." |
| Year / distance MathJax outputs under the sliders | `aria-hidden="true"` (visual only); spoken value comes from the slider's `aria-valuetext`, so no garbled "l y" / duplicate reading | — |
| Distance label under the brace, timeline tick labels, SN markers | inside `aria-hidden` overlays (decorative duplicates of spoken values) | — |

### Unit-word mappings applied
- `ly` → **"light years"** (slider `aria-valuetext`, live region, canvas
  descriptions).
- Years are spoken with their era word-pair **"AD" / "BC"** (e.g. `-7999` →
  "8000 BC"), so a leading minus is never read — `fmtYear()` already formats
  this and it is reused for every spoken string.
- (No degrees / arcmin / eV / kelvin etc. occur in this sim.)

### Live region (the single status channel)
- One `aria-live="polite"` region: `#sr-status`. It announces **committed**
  changes only (slider release / Enter / drag end / state transitions), so there
  is no per-tick flooding and no double/triple announcement.
- Wording (units-complete), driven from state:
  - Cursor / supernova / observed: *"Cursor at 1200 AD. Supernova occurs 1200 AD.
    Light is observed in 4200 AD."*
  - Distance: *"Observer distance 3000 light years. Light is observed in 4200 AD."*
  - Animation events: *"Supernova triggered…"*, *"The light has reached the
    observer in 4200 AD. The observer now sees the supernova. Stopping shortly."*,
    *"Stopped, 2 seconds after the observer saw the supernova (4200 AD). Press
    resume to continue or reset."*, *"Paused."*, *"Resumed."*, *"Simulation reset."*

### Canvas description (read on navigation, not auto-announced)
- `#display-canvas` and `#timeline-canvas` are `role="img"` with `aria-label`
  and `aria-describedby` pointing at `.sr-only` paragraphs (`#display-desc`,
  `#timeline-desc`). These are **not** live regions (so they don't compete with
  `#sr-status`); they are updated from the single render/state path and are read
  when the reader reaches the canvas.
  - Display: *"A star at the left and an observer 3000 light years to the right.
    The star has not yet exploded. Press go supernova to start."* (state-dependent)
  - Timeline: same sentence as the timeline live announcement.
- Decorative overlays (tick labels, brace distance label, SN markers) are inside
  `aria-hidden="true"` containers, so they add no audio noise.

### Controls (keyboard + name/value/unit)
- Both sliders are native `<input type="range">` — fully operable by arrows /
  PageUp/Down / Home/End and not "stuck" — and announce label + `aria-valuetext`
  (with unit). Distance is enabled only in setup; the year cursor is disabled
  only while running (matching the sim's drag rules); Tab always moves away.
- Buttons have descriptive names. The pause/resume button gets
  `aria-label="pause or resume, currently unavailable"` while it shows "…" (so
  it is not read as "dot dot dot"); otherwise its name is the visible "pause" /
  "resume" / "go supernova" / "reset".
- Related controls are grouped with `<fieldset>/<legend>` ("Supernova",
  "Observer") so context is spoken.

### Unchanged
Behavior, numbers, physics, animation, layout, visuals, on-screen text, MathJax
usage, responsiveness and the 2-second auto-stop are all intact; this pass only
added/repaired ARIA, units in spoken strings, and the single live region.
