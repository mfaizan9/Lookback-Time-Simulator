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
- The lookback relation and **every** numeric readout (timeline tick labels,
  distance, observed year, current year) are typeset by **MathJax** (LaTeX,
  SVG output). Right-clicking any of them opens MathJax's own context menu
  (*Show Math As → TeX / MathML*); the menu is left enabled and the
  `contextmenu` event is not trapped.
- The lookback equation is paired with a spoken description string
  (`#lookback-eqn-sr`) so the math is also read aloud.
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
- Verify announcement wording/timing with NVDA/JAWS/VoiceOver (the live regions
  fire on commit, not per animation frame).
- Confirm the dark display panel's decorative canvas is correctly ignored by
  screen readers while the live descriptions convey its state.
