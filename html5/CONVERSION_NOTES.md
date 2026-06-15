# Conversion Notes — Lookback Time Simulator

## Behavior model (one paragraph)

The sim teaches **lookback time**: because light travels at a finite speed, a
distant event is *seen* only after the light reaches us, so we observe distant
objects as they were in the past. A star sits at the left of the top panel and
an observer at the right, separated by an adjustable distance in light-years
(ly). A timeline below runs from 8000 BC to 10000 AD with a draggable cursor.
In **setup** you choose when the supernova occurs (drag the cursor, type a year,
or use the slider) and how far away the observer is (drag the observer or use
the distance slider). Pressing **go supernova** explodes the star and starts the
clock: an expanding circle (the light) grows outward from the star, the cursor
sweeps forward in time, and the observer only "sees" the explosion — shown in
the thought bubble over their head — at the instant the circle reaches them,
which happens in year `supernovaYear + distance`. The run can be **paused /
resumed**, scrubbed while paused, and **reset**.

## Source → port mapping (AS1 → HTML5)

| ActionScript (decompiled) | HTML5 port (`simulation.js`) |
|---|---|
| `LookbackSimulatorClass` (state machine, `animateOnEnterFrame`, `setState`, `onYearCursorDragged`, `onObserverDragged`, button handlers) | The `S` state object + functions `animateStep`, `setState`, `onYearCursorDragged`, `onObserverDragged`, `onStartResetButtonPressed`, `onPauseResumeButtonPressed`, ported method-for-method. |
| `TimelineClass` (`minCursorX=0`, `maxCursorX=540`, `minTimelineYear=-7999`, `maxTimelineYear=10000`, `timelineScale`, `getCursorYear`/`setCursorYear`, drag, `parseForYear`, `setSupernovaYear`/`setObservedYear`) | Same constants; `cursorScreenX`, the timeline canvas + drag handler, `parseForYear` (verbatim), `fmtYear`. |
| `StarAndObserverDisplayClass` (`minDistanceValue=1000`, `maxDistanceValue=10000`, `maxObserverX=560`, `displayScale`, `minObserverX`, `setObserverDistance`, `setLightDistance` with the `1500` cap, `showStarBlowingUp*`) | Same constants & formulas; `drawDisplay`, the observer drag handler, `StarSprite` for the star/blow-up, the expanding light circle. |
| `onEnterFrame` + `getTimer()` | one `requestAnimationFrame` loop + `performance.now()`; same `animRate = 0.6` years/ms, elapsed-time integration. |
| `Curly Brace Component` (code-drawn brace, color by draggable state) | `drawBrace()` on canvas; pale (`#FAFABA`) when draggable, grey (`#909090`) otherwise. |
| `Title Bar` / `Dialog Window v2` / `Mini About Link` (Flash chrome, About/Help) | **Not ported** — replaced by the shared `<kl-unl-masthead>` (Reset/Help/About). |
| `FPushButtonSymbol`, `FUIComponentSymbol`, `FLabelSymbol` (Flash UI framework) | **Not ported** — replaced by native `<button>`, `<input type=range>`, `<label>`. |

### Verbatim constants / formulas preserved
`animRate=0.6`, initial `observerDistance=3000`, initial supernova/displayed
year `1200`, `minTimelineYear=-7999`, `maxTimelineYear=10000`,
`minCursorX/maxCursorX=0/540`, `minDistanceValue/maxDistanceValue=1000/10000`,
`maxObserverX=560`, the light-scale cap `1500`, observer-distance snapping to
the nearest `100`, the year↔position mapping, and `parseForYear`'s AD/BC/CE
handling. Year text is formatted exactly as the source: `N AD` for positive
years, otherwise `abs(N-1) BC`.

### Reused exported assets (not redrawn)
- `assets/observer.png` — the observer figure (`sprites/DefineSprite_123`).
- `assets/star/1.png … 18.png` — the star and its supernova blow-up animation
  (`sprites/DefineSprite_118`, frame 1 = star, frame 18 = "endBlowup"/gone),
  played frame-by-frame and reused for both the main star and the thought
  bubble star.

### Genuinely code-drawn art (reproduced on canvas, per the AS)
The expanding light circle, the distance brace, the thought-bubble cloud, the
timeline axis/cursor/markers — these are drawn at runtime by the ActionScript
(`createEmptyMovieClip`/`lineTo`/scaling), so there is no exported file to reuse
and they are reproduced with the canvas 2D API.

## `contents.json` entry added

`contents.json` here is the **shared** KL-UNL file (it already contains
`newSim`, `hrExplorer`, `hydrogenatom`, `smallAngleDemo`). It is identical
across all sibling sims and each sim copies it into its own `html5/foundation/`.
Following that established model, the file was copied in and this sim's entry
was added (alphabetically). The Help text is verbatim from the original
(`texts/65.txt`); the About text reuses the sibling boilerplate (funding /
permission / astro.unl.edu) matching `texts/3,5,8,9`.

```json
"lookbackTime": {
  "meta": { "title": "Lookback Time Simulator", "version": "2.0 (Accessible HTML5)" },
  "masthead": {
    "help":  { "title": "Help and Instructions", "content": "<p>This simulator shows how the finite speed of light…</p>…" },
    "about": { "title": "About this Simulator",   "content": "<p>For additional astronomy education materials…</p>…" }
  }
}
```

## Deviations from the original (and why)

1. **Foundation folder location.** The Lookback source folder shipped *without*
   a `foundation/` subfolder, although every sibling sim in the workspace has an
   identical one (the four KL-UNL files are byte-for-byte identical across all
   sims; `contents.json` is the shared multi-sim file). The foundation was
   copied from a sibling unchanged. If a canonical foundation differs, re-copy
   it over `html5/foundation/` (keeping this sim's `lookbackTime` entry in
   `contents.json`).

2. **Chrome, layout, palette, fonts.** Per the KL-UNL/accessibility brief, the
   original Flash masthead, dialogs, pixel layout, colors and Verdana fonts are
   **not** reproduced. Structure and reading order (display panel, then timeline
   + controls) are preserved using KL-UNL classes.

3. **Absolute stage coordinates.** The original's exact on-stage pixel positions
   (e.g. `starMC._x`) were not present in the decompiled scripts. The display
   canvas uses re-chosen internal coordinates (`STAR_X`, canvas 604×220) but the
   AS **formulas and relationships are preserved exactly** — `displayScale` and
   `minObserverX` are computed from the original formulas, so the light front
   reaches the observer precisely when the light has travelled `observerDistance`
   light-years. The timeline keeps the original coordinate math verbatim.

4. **MathJax is the only math renderer, and is serialized.** Every number, unit
   and the lookback relation are typeset by MathJax (LaTeX). The foundation's
   `klunlShowEquation()` typesets immediately and non-serialized, which — when
   combined with the other readouts — triggers MathJax v3's "replaceChild of
   null" crash. To keep the console clean, **all** math nodes (equation,
   readouts, axis tick labels) are funneled through one serialized
   `typesetClear → set HTML → typesetPromise` queue, scheduled with `setTimeout`
   (not `requestAnimationFrame`, so typesetting still happens when the tab is
   backgrounded). The foundation files themselves are untouched; `svg.fontCache`
   is set to `none` in `index.html` to avoid the shared-`<defs>` variant of the
   same bug.

5. **Editable year field.** The "supernova occurs" value is a real `<input>`
   form control, so its text is not MathJax-typeset (form fields cannot be);
   the same year is shown MathJax-typeset in the live equation and announced.

6. **Reduced motion.** With `prefers-reduced-motion: reduce`, pressing
   *go supernova* jumps straight to the final state (light fully expanded,
   "SN observed" revealed) instead of animating. All physics/logic is unchanged;
   only the presentation of the motion is replaced by its end state.

7. **Auto-stop after the light is observed.** Per request, the animation now
   **pauses automatically 2 seconds after the supernova is observed** (when the
   expanding light reaches the observer), rather than always running on to the
   end of the timeline. The original ran until `maxTimelineYear`. After the
   auto-stop the user can **resume** (continue to the end of the timeline) or
   **reset**. If the supernova is configured so the light is never observed
   within the timeline, the animation runs to the end as before. This only
   changes when the motion stops, not any physics/logic.

8. **Reset.** The in-sim *go supernova / reset* button is a simulation control
   (state machine) and is kept. The global **Reset** is provided by the masthead
   via the `sim-reset` event, wired to restore the exact initial state. These
   are distinct, as in the original (which had both a sim control and a title-bar
   reset).
