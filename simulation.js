/* =====================================================================
   Lookback Time Simulator -- HTML5 port
   ---------------------------------------------------------------------
   Behavioral ground truth: the decompiled AS1 in ../scripts/
     - Lookback Simulator.as      (state machine, animation)
     - Timeline.as                (year <-> position, cursor, SN labels)
     - Star And Observer Display.as (star, observer, expanding light)
   Constants, formulas and number formatting are copied verbatim from the
   source.  Presentation follows the KL-UNL foundation + WCAG rules; the
   absolute on-stage pixel coordinates are re-chosen for the responsive
   canvas (see CONVERSION_NOTES.md) but every RELATIONSHIP and FORMULA is
   preserved exactly.
   ===================================================================== */

(function () {
  'use strict';

  // ------------------------------------------------------------------
  // Constants -- VERBATIM from the ActionScript source
  // ------------------------------------------------------------------

  // Lookback Simulator.as
  var ANIM_RATE        = 0.6;       // years advanced per millisecond
  var INIT_DISTANCE    = 3000;      // initial observerDistance (ly)
  var INIT_SN_YEAR     = 1200;      // initial supernova / displayed year

  // Timeline.as
  var MIN_CURSOR_X     = 0;
  var MAX_CURSOR_X     = 540;
  var MIN_TL_YEAR      = -7999;
  var MAX_TL_YEAR      = 10000;
  var TL_SCALE         = (MAX_TL_YEAR - MIN_TL_YEAR) / (MAX_CURSOR_X - MIN_CURSOR_X); // 17999/540
  var MAX_SN_YEAR      = MAX_TL_YEAR; // LookbackSimulatorClass.maxSupernovaYear

  // Star And Observer Display.as
  var MIN_DISTANCE     = 1000;      // minDistanceValue
  var MAX_DISTANCE     = 10000;     // maxDistanceValue
  var MAX_OBSERVER_X   = 560;       // maxObserverX (display-local stage x)
  var LIGHT_SCALE_CAP  = 1500;      // setLightDistance caps the scale at 1500

  // ------------------------------------------------------------------
  // Display-canvas internal geometry (presentation; see notes).
  // starX is chosen for layout; displayScale / minObserverX then follow
  // the EXACT AS formulas so the pedagogy is unchanged:
  //   - observer x  = starX + displayScale * distance
  //   - light radius (px) = min(displayScale * lightDistance, 1500)
  //   => the light front reaches the observer exactly when the light has
  //      travelled `observerDistance` light-years.  (Lookback time.)
  // ------------------------------------------------------------------
  var DISPLAY_W   = 604, DISPLAY_H = 240;
  var STAR_X      = 46;
  var STAR_Y      = 118;
  var OBS_BASE_Y  = 190;            // observer's feet
  var OBS_H       = 72;             // drawn observer height (px)
  var DISPLAY_SCALE = (MAX_OBSERVER_X - STAR_X) / MAX_DISTANCE;
  var MIN_OBSERVER_X = STAR_X + (MIN_DISTANCE / MAX_DISTANCE) * (MAX_OBSERVER_X - STAR_X);
  var BRACE_Y     = 206;            // distance brace; numeric label sits below it

  // Timeline-canvas internal geometry.
  var TIMELINE_W  = 600, TIMELINE_H = 120;
  var AXIS_LEFT   = 30;             // screen x of cursor-local x = 0
  var AXIS_Y      = 58;
  function cursorScreenX(year) { return AXIS_LEFT + (year - MIN_TL_YEAR) / TL_SCALE; }

  var TICKS = [
    { year: -7999, num: '8000', era: 'BC' },
    { year: -5999, num: '6000', era: 'BC' },
    { year: -3999, num: '4000', era: 'BC' },
    { year: -1999, num: '2000', era: 'BC' },
    { year:     1, num: '1',    era: 'AD' },
    { year:  2000, num: '2000', era: 'AD' },
    { year:  4000, num: '4000', era: 'AD' },
    { year:  6000, num: '6000', era: 'AD' },
    { year:  8000, num: '8000', era: 'AD' },
    { year: 10000, num: '10000', era: 'AD' }
  ];

  // ------------------------------------------------------------------
  // Number formatting -- VERBATIM from Timeline.as setSupernovaYear /
  // setObservedYear: positive years are "N AD", others "abs(N-1) BC".
  // ------------------------------------------------------------------
  function fmtYear(year) {
    year = Math.round(year);
    if (year > 0) { return year + ' AD'; }
    return Math.abs(year - 1) + ' BC';
  }
  // LaTeX form (numbers/units typeset by MathJax).
  function fmtYearTex(year) {
    year = Math.round(year);
    if (year > 0) { return year + '\\,\\text{AD}'; }
    return Math.abs(year - 1) + '\\,\\text{BC}';
  }

  // parseForYear -- VERBATIM from Timeline.as (handles AD / BC / CE).
  function parseForYear(arg) {
    var s = String(arg).toLowerCase();
    var n = Math.round(parseFloat(s));
    if (isNaN(n) || n < MIN_TL_YEAR || n > MAX_TL_YEAR) { return NaN; }
    var hasBC = s.indexOf('bc') !== -1;
    var isAD  = s.indexOf('ad') !== -1 || (s.indexOf('ce') !== -1 && !hasBC);
    if (n === 0) { return 0; }
    if (hasBC) { return -(Math.abs(n) - 1); }
    if (isAD) { return Math.abs(n); }
    return n;
  }

  // ------------------------------------------------------------------
  // Reduced motion
  // ------------------------------------------------------------------
  var reduceMotionMQ = window.matchMedia('(prefers-reduced-motion: reduce)');
  function reducedMotion() { return reduceMotionMQ.matches; }

  // ------------------------------------------------------------------
  // Assets (reused exported art -- NOT redrawn)
  // ------------------------------------------------------------------
  // Redraw once art finishes loading (the on-demand loop is idle at rest, so
  // images that arrive after the first render must trigger a repaint).
  function onAssetLoad() { if (dispCtx) { drawDisplay(perfNow()); } }

  var observerImg = new Image();
  observerImg.onload = onAssetLoad;
  observerImg.src = 'assets/observer.png';      // sprites/DefineSprite_123
  var starFrames = [];                          // sprites/DefineSprite_118 1..18
  for (var i = 1; i <= 18; i++) {
    var im = new Image();
    im.onload = onAssetLoad;
    im.src = 'assets/star/' + i + '.png';
    starFrames.push(im);
  }
  var STAR_FRAME_MS = 40;                        // ~25 fps playback of the blowup
  var STAR_LAST = starFrames.length;            // frame 18 == "endBlowup" (gone)

  // A reusable star whose blow-up animation reuses the exported frames.
  function StarSprite() {
    this.mode = 'star';     // 'star' | 'exploding' | 'gone'
    this.t0 = 0;
  }
  StarSprite.prototype.setStar      = function ()    { this.mode = 'star'; };
  StarSprite.prototype.setGone      = function ()    { this.mode = 'gone'; };
  StarSprite.prototype.playBlowup   = function (now) {
    if (reducedMotion()) { this.mode = 'gone'; return; }
    this.mode = 'exploding'; this.t0 = now;
  };
  StarSprite.prototype.currentFrame = function (now) {
    if (this.mode === 'star') { return 1; }
    if (this.mode === 'gone') { return STAR_LAST; }
    var f = 1 + Math.floor((now - this.t0) / STAR_FRAME_MS);
    if (f >= STAR_LAST) { this.mode = 'gone'; return STAR_LAST; }
    return f;
  };
  StarSprite.prototype.draw = function (ctx, now, cx, cy, size) {
    var frame = this.currentFrame(now);
    if (frame >= STAR_LAST) { return; } // gone: draw nothing
    var img = starFrames[frame - 1];
    if (img.complete && img.naturalWidth) {
      ctx.drawImage(img, cx - size / 2, cy - size / 2, size, size);
    }
  };

  // ==================================================================
  // STATE  (single source of truth)
  // ==================================================================
  var S = {
    state: 0,               // 0 setup | 1 running | 2 paused | 3 ended
    observerDistance: INIT_DISTANCE,
    supernovaYear: INIT_SN_YEAR,
    displayedYear: INIT_SN_YEAR,
    observedVisible: false, // Timeline.setObservedLabelVisible
    timeLast: 0,
    animating: false,
    stopAt: 0,              // timestamp to auto-stop after the light is observed
    stopPending: false,
    mainStar: new StarSprite(),
    thoughtStar: new StarSprite()
  };

  // Derived
  function observedYear() { return S.supernovaYear + S.observerDistance; }
  function lightDistance() { return S.displayedYear - S.supernovaYear; }
  function snFieldEditable() { return S.state === 0; }

  // ==================================================================
  // BEHAVIOR  (ported method-for-method from Lookback Simulator.as)
  // ==================================================================

  function reset() {
    S.observerDistance = INIT_DISTANCE;
    S.displayedYear = S.supernovaYear = INIT_SN_YEAR;
    setState(0);
    announce('Simulation reset.');
  }

  function animateStep(now) {
    var wasPreSN = S.displayedYear < S.supernovaYear;
    var beforeObserved = S.displayedYear < S.supernovaYear + S.observerDistance;

    S.displayedYear += (now - S.timeLast) * ANIM_RATE;

    if (beforeObserved && S.displayedYear >= S.supernovaYear + S.observerDistance) {
      // light reaches the observer -> star blows up inside the thought bubble
      S.thoughtStar.playBlowup(now);
      // Schedule an automatic stop 2 seconds after the light is observed.
      S.stopPending = true;
      S.stopAt = now + 2000;
      announce('The light has reached the observer in ' + fmtYear(observedYear()) +
               '. The observer now sees the supernova. Stopping shortly.');
    }
    if (wasPreSN && S.displayedYear >= S.supernovaYear) {
      S.mainStar.playBlowup(now);
    }
    if (S.displayedYear > MAX_TL_YEAR) {
      S.displayedYear = MAX_TL_YEAR;
      setState(3);
    } else if (S.stopPending && now >= S.stopAt) {
      // 2 s after the supernova was observed: stop (pause) the animation.
      S.stopPending = false;
      S.timeLast = now;
      updateSim();
      setState(2);
      announce('Stopped, 2 seconds after the observer saw the supernova (' +
               fmtYear(observedYear()) + '). Press resume to continue or reset.');
      return;
    }
    updateSim();
    S.timeLast = now;
  }

  function updateSim() {
    // setLightDistance: toggle the main star between visible / gone.
    var ld = DISPLAY_SCALE * lightDistance();
    if (ld < 1e-10) {
      S.mainStar.setStar();
    } else if (S.mainStar.mode === 'star') {
      S.mainStar.setGone();
    }
    if (S.displayedYear > S.supernovaYear + S.observerDistance) {
      S.observedVisible = true;
    }
    render();
    syncReadouts();      // cheap plain-text feedback (MathJax typesets on commit)
    positionOverlay();
  }

  // Keep the controls in sync with state during drags/frames, as plain text;
  // MathJax re-typesets the same values on commit (updateMathReadouts).  We
  // mirror the moving cursor onto the year slider and, in setup, the supernova
  // field + distance onto their controls -- but never overwrite the control the
  // user is actively holding.
  function syncReadouts() {
    if (!el.yearValue) { return; }
    setPlain(el.yearValue, fmtYear(S.displayedYear));
    // Screen-reader spoken value of the year slider: "1200 AD" / "8000 BC"
    // (never the raw signed number). The slider's <label> supplies the name.
    el.yearRange.setAttribute('aria-valuetext', fmtYear(S.displayedYear));
    // Spoken equivalent of the boxed "is observed" value.
    if (el.observedSr) { el.observedSr.textContent = fmtYear(observedYear()); }
    if (document.activeElement !== el.yearRange) {
      el.yearRange.value = String(Math.round(S.displayedYear));
    }
    if (S.state === 0) {
      if (document.activeElement !== el.snInput) {
        el.snInput.value = fmtYear(S.supernovaYear);
      }
      if (document.activeElement !== el.distRange) {
        el.distRange.value = String(Math.round(S.observerDistance));
      }
      setPlain(el.distValue, S.observerDistance + ' ly');
      setPlain(el.distLabel, S.observerDistance + ' ly');
    }
    // Spoken value of the distance slider: "3000 light years" (unit as words).
    el.distRange.setAttribute('aria-valuetext', S.observerDistance + ' light years');
    positionDisplayOverlay();
  }

  // Write plain text into a readout and invalidate its MathJax change-guard so
  // the next commit re-typesets it even if the value is unchanged.
  function setPlain(node, text) {
    if (!node) { return; }
    node.textContent = text;
    if (node.id) { _mjLast[node.id] = null; }
  }

  function onYearCursorDragged(yr) {
    if (isNaN(yr)) {
      updateSim();
      return;
    }
    if (S.state === 1) { return; }
    if (S.state === 0) {
      if (yr > MAX_SN_YEAR) { yr = MAX_SN_YEAR; }
      S.displayedYear = S.supernovaYear = yr;
    } else if (S.state === 2) {
      S.displayedYear = yr;
      if (S.displayedYear >= MAX_TL_YEAR - 1e-10) { setState(3); }
    } else if (S.state === 3) {
      S.displayedYear = yr;
      if (S.displayedYear < MAX_TL_YEAR - 1e-10) { setState(2); }
    }
    if (S.state === 2 || S.state === 3) {
      // showStarInThought(displayedYear < supernovaYear + observerDistance)
      showStarInThought(S.displayedYear < S.supernovaYear + S.observerDistance);
    }
    updateSim();
  }

  function onObserverDragged(dist) {
    if (S.state === 0) {
      dist = 100 * Math.round(dist / 100);   // snap to nearest 100 ly (verbatim)
      S.observerDistance = dist;
      updateSim();
    }
  }

  function showStarInThought(showNormal) {
    if (showNormal) { S.thoughtStar.setStar(); }
    else { S.thoughtStar.setGone(); }
  }

  function onStartResetButtonPressed() {
    if (S.state === 0) {
      if (reducedMotion()) { jumpToEnd(); return; }
      setState(1);
    } else {
      setState(0);
    }
  }

  function onPauseResumeButtonPressed() {
    if (S.state === 1) { setState(2); }
    else if (S.state === 2) { setState(1); }
  }

  // Reduced-motion equivalent of running the whole animation: jump to the
  // end state with the light fully expanded and "observed" revealed.
  function jumpToEnd() {
    // mirror the state-1 entry side effects, then settle at the end
    S.thoughtStar.setStar();
    S.mainStar.setGone();
    S.displayedYear = MAX_TL_YEAR;
    S.observedVisible = true;
    showStarInThought(S.displayedYear < S.supernovaYear + S.observerDistance);
    if (!(S.displayedYear < S.supernovaYear + S.observerDistance)) {
      S.thoughtStar.setGone();
    }
    setState(3);
    announce('Supernova triggered. Showing the final state: the star exploded in ' +
             fmtYear(S.supernovaYear) + ' and its light was seen by the observer in ' +
             fmtYear(observedYear()) + '.');
  }

  // setState -- VERBATIM port (button labels/enabled, draggability, anim).
  function setState(newState) {
    var prev = S.state;
    if (newState === 0) {
      S.mainStar.setStar();
      S.thoughtStar.setStar();
      S.observedVisible = false;
      S.displayedYear = S.supernovaYear;
      S.animating = false;
      S.stopPending = false;
    } else if (newState === 1 && prev === 0) {
      // timeline.setSupernovaYear / setObservedYear handled by render
      // display.onAnimationStart(): star blows up, light starts at 0
      S.stopPending = false;
      S.mainStar.playBlowup(perfNow());
      S.timeLast = perfNow();
      S.animating = true;
      announce('Supernova triggered. The star is exploding; watch the light expand toward the observer.');
    } else if (newState === 1 && prev === 2) {
      S.timeLast = perfNow();
      S.animating = true;
      announce('Resumed.');
    } else if (newState === 2 && prev === 1) {
      S.animating = false;
      announce('Paused.');
    } else if (newState === 3) {
      S.animating = false;
      if (prev === 1 || prev === 2) {
        announce('The animation reached the end of the timeline.');
      }
    }
    S.state = newState;
    syncControls();
    updateSim();
    updateMathReadouts();   // once per state change (not per animation frame)
    ensureLoop();           // start the rAF loop if we just began animating
  }

  function perfNow() { return performance.now(); }

  // ==================================================================
  // CONTROLS  (native, accessible) <-> state
  // ==================================================================
  var el = {};
  function grab() {
    el.startReset   = document.getElementById('start-reset-button');
    el.pauseResume  = document.getElementById('pause-resume-button');
    el.snInput      = document.getElementById('sn-year-input');
    el.yearRange    = document.getElementById('year-range');
    el.yearValue    = document.getElementById('year-range-value');
    el.observed     = document.getElementById('observed-output');
    el.distRange    = document.getElementById('dist-range');
    el.distValue    = document.getElementById('dist-value');
    el.observedSr   = document.getElementById('observed-sr');
    el.displayCanvas= document.getElementById('display-canvas');
    el.displayOverlay = document.getElementById('display-overlay');
    el.distLabel    = document.getElementById('dist-brace-label');
    el.timelineCanvas = document.getElementById('timeline-canvas');
    el.overlay      = document.getElementById('timeline-overlay');
    el.displayDesc  = document.getElementById('display-desc');
    el.timelineDesc = document.getElementById('timeline-desc');
    el.status       = document.getElementById('sr-status');
  }

  // Reflect state into the controls (labels, enabled, values).
  function syncControls() {
    // Button labels / enabled -- VERBATIM strings from Lookback Simulator.as
    if (S.state === 0) {
      el.startReset.textContent = 'go supernova';
      el.startReset.disabled = false;
      el.pauseResume.textContent = '...';
      el.pauseResume.disabled = true;
    } else if (S.state === 1) {
      el.startReset.textContent = 'reset';
      el.startReset.disabled = true;
      el.pauseResume.textContent = 'pause';
      el.pauseResume.disabled = false;
    } else if (S.state === 2) {
      el.startReset.textContent = 'reset';
      el.startReset.disabled = false;
      el.pauseResume.textContent = 'resume';
      el.pauseResume.disabled = false;
    } else if (S.state === 3) {
      el.startReset.textContent = 'reset';
      el.startReset.disabled = false;
      el.pauseResume.textContent = '...';
      el.pauseResume.disabled = true;
    }
    // The pause/resume button shows "..." when unavailable; give it a spoken
    // name instead of "dot dot dot".
    if (el.pauseResume.textContent === '...') {
      el.pauseResume.setAttribute('aria-label', 'pause or resume, currently unavailable');
    } else {
      el.pauseResume.removeAttribute('aria-label');
    }

    // Draggability: observer only in state 0; cursor whenever state != 1.
    el.distRange.disabled = (S.state !== 0);
    el.snInput.disabled = !snFieldEditable();
    el.snInput.readOnly = !snFieldEditable();
    el.yearRange.disabled = (S.state === 1);

    // Keep the year slider + SN field text in sync with state
    el.yearRange.value = String(Math.round(S.displayedYear));
    el.distRange.value = String(Math.round(S.observerDistance));
    if (document.activeElement !== el.snInput) {
      el.snInput.value = fmtYear(S.supernovaYear);
    }
  }

  function wireControls() {
    el.startReset.addEventListener('click', function () {
      onStartResetButtonPressed();
    });
    el.pauseResume.addEventListener('click', function () {
      onPauseResumeButtonPressed();
    });

    // Year slider: live feedback on input, MathJax + announce on commit.
    el.yearRange.addEventListener('input', function () {
      onYearCursorDragged(parseInt(el.yearRange.value, 10));
      setPlain(el.yearValue, fmtYear(S.displayedYear));
    });
    el.yearRange.addEventListener('change', function () {
      updateMathReadouts();
      announce(timelineSentence());
    });

    // Distance slider
    el.distRange.addEventListener('input', function () {
      onObserverDragged(parseInt(el.distRange.value, 10));
      setPlain(el.distValue, S.observerDistance + ' ly');
    });
    el.distRange.addEventListener('change', function () {
      updateMathReadouts();
      announce(distanceSentence());
    });

    // SN year text field: commit on Enter or blur (mirrors commitSNOccursFieldChanges)
    el.snInput.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') { commitSNField(); el.snInput.blur(); }
    });
    el.snInput.addEventListener('blur', commitSNField);

    // Reduced-motion live toggle: keep button labels sensible.
    reduceMotionMQ.addEventListener('change', syncControls);
  }

  function commitSNField() {
    if (!snFieldEditable()) { el.snInput.value = fmtYear(S.supernovaYear); return; }
    var parsed = parseForYear(el.snInput.value);
    onYearCursorDragged(parsed);            // NaN -> revert via updateSim
    el.snInput.value = fmtYear(S.supernovaYear);
    updateMathReadouts();
    announce(timelineSentence());
  }

  // ==================================================================
  // MathJax readouts  (typeset on commit / state change, not per tick)
  // ==================================================================
  // ---- Serialized MathJax typesetting ----------------------------------
  // MathJax v3 crashes ("replaceChild of null") if typesetPromise() runs
  // concurrently on overlapping content, or if a node's innerHTML is replaced
  // without typesetClear().  The foundation's klunlShowEquation() typesets the
  // equation immediately and non-serialized, which collides with our readout
  // typesets.  So we funnel EVERY math node (equation + readouts + tick labels)
  // through ONE promise chain that does a single typesetClear + typesetPromise
  // per flush.  (Foundation files remain untouched; see CONVERSION_NOTES.md.)
  // Order matters: typesetClear() must run on the OLD content BEFORE we swap
  // innerHTML, otherwise MathJax keeps refs to detached nodes and its next
  // pass throws "replaceChild of null".  So we defer the innerHTML swap into
  // the serialized flush, where each batch runs:  clear -> set html -> typeset.
  var _mjLast = {};
  var _mjPending = [];      // [{ node, html }]
  var _mjChain = null;
  var _mjScheduled = false;

  function _mjChainHead() {
    if (!_mjChain) { _mjChain = Promise.resolve(); }
    return _mjChain;
  }
  // Scheduled via setTimeout (NOT requestAnimationFrame) so equation/readout
  // typesetting still happens when the tab is backgrounded -- rAF is paused
  // while hidden, but math rendering must not depend on visibility.
  function _mjEnqueue(node, html) {
    if (!node) { return; }
    for (var i = 0; i < _mjPending.length; i++) {
      if (_mjPending[i].node === node) { _mjPending[i].html = html; node = null; break; }
    }
    if (node) { _mjPending.push({ node: node, html: html }); }
    if (_mjScheduled) { return; }
    _mjScheduled = true;
    setTimeout(_mjFlush, 16);
  }
  function _mjFlush() {
    _mjScheduled = false;
    if (!(window.MathJax && MathJax.typesetPromise)) {   // not ready yet -> retry
      _mjScheduled = true; setTimeout(_mjFlush, 50); return;
    }
    var batch = _mjPending.slice(); _mjPending.length = 0;
    if (!batch.length) { return; }
    var nodes = batch.map(function (b) { return b.node; });
    _mjChain = _mjChainHead().then(function () {
      try { if (MathJax.typesetClear) { MathJax.typesetClear(nodes); } } catch (e) {}
      batch.forEach(function (b) { b.node.innerHTML = b.html; });
      return MathJax.typesetPromise(nodes);
    }).then(function () {
      positionOverlay();   // tick labels exist only after typeset; reposition
    }).catch(function (e) { console.error(e); });
  }
  // Queue a readout as \(latex\), only when its content changed.
  function mjMath(node, latex) {
    if (!node) { return; }
    var key = node.id || '';
    var html = '\\(' + latex + '\\)';
    if (_mjLast[key] === html) { return; }
    _mjLast[key] = html;
    _mjEnqueue(node, html);
  }
  // Queue raw HTML (already containing \(...\) spans), e.g. the tick overlay.
  function mjRaw(node, html) { _mjEnqueue(node, html); }

  function updateMathReadouts() {
    var d = S.observerDistance, obs = observedYear();

    mjMath(el.yearValue, fmtYearTex(S.displayedYear));
    mjMath(el.distValue, d + '\\,\\text{ly}');
    mjMath(el.observed, fmtYearTex(obs));
    mjMath(el.distLabel, d + '\\,\\text{ly}');   // label centered under the brace

    updateDescriptions();
    positionOverlay();
    positionDisplayOverlay();
  }

  // ==================================================================
  // Screen-reader descriptions / announcements
  // ==================================================================
  // The ONE live region: announce committed changes (units-complete). The
  // canvas descriptions (#display-desc / #timeline-desc) are NOT live -- they
  // are read on navigation via aria-describedby -- so a single commit produces
  // a single spoken announcement, never a double/triple.
  function announce(msg) { if (el.status) { el.status.textContent = msg; } }

  // Units-complete one-line timeline status (years spoken as "1200 AD"/"8000 BC").
  function timelineSentence() {
    return 'Cursor at ' + fmtYear(S.displayedYear) + '. Supernova occurs ' +
      fmtYear(S.supernovaYear) + '. Light is observed in ' + fmtYear(observedYear()) + '.';
  }
  function distanceSentence() {
    return 'Observer distance ' + S.observerDistance + ' light years. Light is observed in ' +
      fmtYear(observedYear()) + '.';
  }

  // Update the (non-live) timeline description used by aria-describedby.
  function announceTimeline() {
    el.timelineDesc.textContent = timelineSentence();
  }

  function updateDescriptions() {
    var ld = Math.max(0, Math.round(lightDistance()));
    var sceneState;
    if (S.state === 0) {
      sceneState = 'The star has not yet exploded. Press go supernova to start.';
    } else if (S.displayedYear < S.supernovaYear) {
      sceneState = 'Before the supernova.';
    } else if (!S.observedVisible) {
      sceneState = 'The star has exploded; its light has expanded to about ' + ld +
                   ' light-years and has not yet reached the observer.';
    } else {
      sceneState = 'The light has passed the observer, who has now seen the supernova.';
    }
    el.displayDesc.textContent =
      'A star at the left and an observer ' + S.observerDistance +
      ' light-years to the right. ' + sceneState;
    announceTimeline();
  }

  // ==================================================================
  // RENDERING
  // ==================================================================
  var dispCtx, tlCtx, dpr = 1;

  function setupCanvas(canvas, w, h) {
    dpr = Math.max(1, window.devicePixelRatio || 1);
    canvas.width = Math.round(w * dpr);
    canvas.height = Math.round(h * dpr);
    var ctx = canvas.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    return ctx;
  }

  function setupCanvases() {
    dispCtx = setupCanvas(el.displayCanvas, DISPLAY_W, DISPLAY_H);
    tlCtx   = setupCanvas(el.timelineCanvas, TIMELINE_W, TIMELINE_H);
  }

  function render() {
    if (!dispCtx) { return; }
    drawDisplay(perfNow());
    drawTimeline();
  }

  function drawDisplay(now) {
    var ctx = dispCtx;
    ctx.clearRect(0, 0, DISPLAY_W, DISPLAY_H);

    var obsX = STAR_X + DISPLAY_SCALE * S.observerDistance;

    // --- expanding light circle (centered on the star) ---
    var radius = DISPLAY_SCALE * lightDistance();
    if (radius > LIGHT_SCALE_CAP) { radius = LIGHT_SCALE_CAP; }
    if (radius > 1e-6 && S.displayedYear >= S.supernovaYear) {
      ctx.save();
      ctx.beginPath();
      ctx.arc(STAR_X, STAR_Y, radius, 0, Math.PI * 2);
      ctx.lineWidth = 2;
      ctx.strokeStyle = 'rgba(235, 240, 255, 0.85)';
      ctx.stroke();
      ctx.restore();
    }

    // --- distance brace (star <-> observer) ---
    drawBrace(ctx, STAR_X, obsX, BRACE_Y, S.state === 0);

    // --- main star (reused exported frames) ---
    S.mainStar.draw(ctx, now, STAR_X, STAR_Y, 26);

    // --- observer (reused exported bitmap) ---
    if (observerImg.complete && observerImg.naturalWidth) {
      var ratio = observerImg.naturalWidth / observerImg.naturalHeight;
      var ow = OBS_H * ratio;
      ctx.drawImage(observerImg, obsX - ow / 2, OBS_BASE_Y - OBS_H, ow, OBS_H);
    }

    // --- thought bubble above the observer ---
    drawThoughtBubble(ctx, now, obsX, 48);
  }

  function drawBrace(ctx, x1, x2, y, draggable) {
    ctx.save();
    ctx.strokeStyle = draggable ? '#FAFABA' : '#909090';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    // simple square brace: end ticks + spanning line + center notch
    ctx.moveTo(x1, y - 5); ctx.lineTo(x1, y);
    ctx.lineTo((x1 + x2) / 2 - 4, y);
    ctx.lineTo((x1 + x2) / 2, y + 5);
    ctx.lineTo((x1 + x2) / 2 + 4, y);
    ctx.lineTo(x2, y);
    ctx.lineTo(x2, y - 5);
    ctx.stroke();
    ctx.restore();
  }

  function drawThoughtBubble(ctx, now, cx, cy) {
    ctx.save();
    ctx.strokeStyle = '#d6d9e4';
    ctx.fillStyle = 'rgba(255,255,255,0.06)';
    ctx.lineWidth = 1.4;
    // cloud: a few overlapping ellipses
    var lobes = [
      [cx - 34, cy + 4, 18, 14], [cx - 14, cy - 8, 22, 16],
      [cx + 12, cy - 6, 20, 15], [cx + 32, cy + 4, 16, 13],
      [cx - 2, cy + 12, 26, 14]
    ];
    ctx.beginPath();
    lobes.forEach(function (l) {
      ctx.moveTo(l[0] + l[2], l[1]);
      ctx.ellipse(l[0], l[1], l[2], l[3], 0, 0, Math.PI * 2);
    });
    ctx.fill();
    ctx.stroke();
    // little trailing bubbles toward the observer's head
    ctx.beginPath();
    ctx.ellipse(cx + 6, cy + 30, 5, 4, 0, 0, Math.PI * 2);
    ctx.ellipse(cx + 12, cy + 42, 3.5, 3, 0, 0, Math.PI * 2);
    ctx.fill(); ctx.stroke();
    ctx.restore();
    // the star the observer currently "sees"
    S.thoughtStar.draw(ctx, now, cx, cy, 16);
  }

  function drawTimeline() {
    var ctx = tlCtx;
    ctx.clearRect(0, 0, TIMELINE_W, TIMELINE_H);
    ctx.save();
    ctx.strokeStyle = '#1a1a1a';
    ctx.fillStyle = '#1a1a1a';
    ctx.lineWidth = 1.5;

    var x0 = AXIS_LEFT, x1 = AXIS_LEFT + MAX_CURSOR_X;
    // axis with arrowheads
    ctx.beginPath();
    ctx.moveTo(x0 - 18, AXIS_Y); ctx.lineTo(x1 + 18, AXIS_Y); ctx.stroke();
    arrow(ctx, x0 - 18, AXIS_Y, -1);
    arrow(ctx, x1 + 18, AXIS_Y, 1);

    // ticks
    TICKS.forEach(function (t) {
      var x = cursorScreenX(t.year);
      ctx.beginPath(); ctx.moveTo(x, AXIS_Y - 5); ctx.lineTo(x, AXIS_Y + 5); ctx.stroke();
    });

    // SN occurs marker: a dashed vertical line from its label down to the axis
    // (drawn ABOVE the axis so it never covers the year labels below it).
    var snX = cursorScreenX(S.supernovaYear);
    dashedMarker(ctx, snX, '#555');

    // SN observed marker: dashed vertical line (red), once the light is observed
    if (S.observedVisible) {
      var obX = cursorScreenX(observedYear());
      dashedMarker(ctx, obX, '#8a1500');
    }

    // cursor (downward triangle pointing at the axis)
    var cX = cursorScreenX(S.displayedYear);
    var draggable = (S.state !== 1);
    triangleMarker(ctx, cX, AXIS_Y, draggable ? '#2a6f97' : '#9aa0a6', 'down');

    ctx.restore();
  }

  // Dashed vertical line from just under the top label down to the axis.
  function dashedMarker(ctx, x, color) {
    ctx.save();
    ctx.setLineDash([3, 3]);
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(x, 18);
    ctx.lineTo(x, AXIS_Y);
    ctx.stroke();
    ctx.restore();
  }

  function arrow(ctx, x, y, dir) {
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x - dir * 8, y - 4);
    ctx.lineTo(x - dir * 8, y + 4);
    ctx.closePath();
    ctx.fill();
  }

  function triangleMarker(ctx, x, y, color, dir) {
    ctx.save();
    ctx.fillStyle = color;
    ctx.strokeStyle = 'rgba(0,0,0,0.35)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    if (dir === 'down') {           // ▽ sitting above the axis
      ctx.moveTo(x - 8, y - 16);
      ctx.lineTo(x + 8, y - 16);
      ctx.lineTo(x, y - 3);
    } else {                        // △ sitting below the axis
      ctx.moveTo(x - 7, y + 16);
      ctx.lineTo(x + 7, y + 16);
      ctx.lineTo(x, y + 3);
    }
    ctx.closePath();
    ctx.fill(); ctx.stroke();
    ctx.restore();
  }

  // ------------------------------------------------------------------
  // HTML overlay (MathJax tick labels + moving SN labels), positioned
  // by mapping internal coords through the live canvas scale.
  // ------------------------------------------------------------------
  var overlayBuilt = false;
  function buildOverlay() {
    var html = '';
    TICKS.forEach(function (t, idx) {
      html += '<span class="sim-tick-label" data-tick="' + idx + '">\\(' +
              t.num + '\\,\\text{' + t.era + '}\\)</span>';
    });
    html += '<span class="sim-marker-label" id="occurs-label">SN occurs</span>';
    html += '<span class="sim-marker-label sim-marker-label--observed" id="observed-label">SN observed</span>';
    overlayBuilt = true;
    mjRaw(el.overlay, html);  // clear -> set html -> typeset, via serialized queue
  }

  function positionOverlay() {
    if (!overlayBuilt) { return; }
    var rect = el.timelineCanvas.getBoundingClientRect();
    var sx = rect.width / TIMELINE_W;
    var sy = rect.height / TIMELINE_H;
    var ticks = el.overlay.querySelectorAll('.sim-tick-label');
    for (var k = 0; k < ticks.length; k++) {
      var idx = +ticks[k].getAttribute('data-tick');
      var x = cursorScreenX(TICKS[idx].year);
      ticks[k].style.left = (x * sx) + 'px';
      ticks[k].style.top = ((AXIS_Y + 12) * sy) + 'px';
    }
    var occ = document.getElementById('occurs-label');
    if (occ) {
      occ.style.left = (cursorScreenX(S.supernovaYear) * sx) + 'px';
      occ.style.top = (2 * sy) + 'px';
      occ.style.display = (S.state !== 0 || true) ? 'block' : 'none';
    }
    var obs = document.getElementById('observed-label');
    if (obs) {
      obs.style.display = S.observedVisible ? 'block' : 'none';
      obs.style.left = (cursorScreenX(observedYear()) * sx) + 'px';
      obs.style.top = (2 * sy) + 'px';
    }
  }

  // Position the distance label centered under the brace, mapping the brace
  // midpoint through the live display-canvas scale.
  function positionDisplayOverlay() {
    if (!el.distLabel || !el.displayCanvas) { return; }
    var rect = el.displayCanvas.getBoundingClientRect();
    if (!rect.width) { return; }
    var sx = rect.width / DISPLAY_W;
    var sy = rect.height / DISPLAY_H;
    var obsX = STAR_X + DISPLAY_SCALE * S.observerDistance;
    var midX = (STAR_X + obsX) / 2;
    el.distLabel.style.left = (midX * sx) + 'px';
    el.distLabel.style.top = ((BRACE_Y + 9) * sy) + 'px';
  }

  // ==================================================================
  // Animation loop  (on-demand: runs only while the sim is animating or a
  // star blow-up is still playing; otherwise the canvas is drawn on demand
  // from render(), so the page goes idle -- no perpetual rAF.)
  // ==================================================================
  var rafId = null;
  function spritesBusy() {
    return S.mainStar.mode === 'exploding' || S.thoughtStar.mode === 'exploding';
  }
  function loopNeeded() {
    return (S.animating && !reducedMotion()) || spritesBusy();
  }
  function ensureLoop() {
    if (rafId === null && loopNeeded()) { rafId = requestAnimationFrame(frame); }
  }
  function frame(now) {
    rafId = null;
    if (S.animating && !reducedMotion()) {
      animateStep(now);
    } else {
      drawDisplay(now);   // finish in-progress sprite blow-ups
    }
    if (loopNeeded()) { rafId = requestAnimationFrame(frame); }
    else { drawDisplay(perfNow()); }   // settle final frame
  }

  // ==================================================================
  // Init
  // ==================================================================
  function init() {
    grab();
    setupCanvases();
    wireControls();

    // pointer drags on the canvases (share one path with mouse + touch)
    attachDisplayDrag();
    attachTimelineDrag();

    // masthead Reset
    document.addEventListener('sim-reset', function () { reset(); });

    // responsive: re-fit backing store + overlay on resize / zoom
    window.addEventListener('resize', function () {
      setupCanvases();
      render();
      positionOverlay();
      positionDisplayOverlay();
    });

    // initial state
    setState(0);
    buildOverlay();
    render();
  }

  // ---- Pointer drag: observer (display canvas), state 0 only ----
  function attachDisplayDrag() {
    var c = el.displayCanvas, dragging = false;
    function toInternalX(e) {
      var r = c.getBoundingClientRect();
      return (e.clientX - r.left) * (DISPLAY_W / r.width);
    }
    function near(e) {
      var x = toInternalX(e);
      var obsX = STAR_X + DISPLAY_SCALE * S.observerDistance;
      return Math.abs(x - obsX) < 28;
    }
    c.addEventListener('pointerdown', function (e) {
      if (S.state !== 0 || !near(e)) { return; }
      dragging = true; c.setPointerCapture(e.pointerId); e.preventDefault();
    });
    c.addEventListener('pointermove', function (e) {
      if (!dragging) { return; }
      var x = toInternalX(e);
      if (x < MIN_OBSERVER_X) { x = MIN_OBSERVER_X; }
      else if (x > MAX_OBSERVER_X) { x = MAX_OBSERVER_X; }
      var dist = Math.round((x - STAR_X) / DISPLAY_SCALE);
      onObserverDragged(dist);
    });
    function end(e) {
      if (!dragging) { return; }
      dragging = false;
      try { c.releasePointerCapture(e.pointerId); } catch (x) {}
      updateMathReadouts();
      announce(distanceSentence());
    }
    c.addEventListener('pointerup', end);
    c.addEventListener('pointercancel', end);
  }

  // ---- Pointer drag: timeline cursor, state != 1 ----
  function attachTimelineDrag() {
    var c = el.timelineCanvas, dragging = false;
    function toCursorLocal(e) {
      var r = c.getBoundingClientRect();
      var sx = (e.clientX - r.left) * (TIMELINE_W / r.width);
      return sx - AXIS_LEFT;                // cursor-local x
    }
    c.addEventListener('pointerdown', function (e) {
      if (S.state === 1) { return; }
      dragging = true; c.setPointerCapture(e.pointerId); e.preventDefault();
      moveTo(e);
    });
    c.addEventListener('pointermove', function (e) { if (dragging) { moveTo(e); } });
    function moveTo(e) {
      var lx = toCursorLocal(e);
      if (lx < MIN_CURSOR_X) { lx = MIN_CURSOR_X; }
      else if (lx > MAX_CURSOR_X) { lx = MAX_CURSOR_X; }
      var year = Math.round(MIN_TL_YEAR + lx * TL_SCALE);
      if (year < MIN_TL_YEAR) { year = MIN_TL_YEAR; }
      else if (year > MAX_TL_YEAR) { year = MAX_TL_YEAR; }
      onYearCursorDragged(year);
      setPlain(el.yearValue, fmtYear(S.displayedYear));
    }
    function end(e) {
      if (!dragging) { return; }
      dragging = false;
      try { c.releasePointerCapture(e.pointerId); } catch (x) {}
      updateMathReadouts();
      announce(timelineSentence());
    }
    c.addEventListener('pointerup', end);
    c.addEventListener('pointercancel', end);
  }

  // ------------------------------------------------------------------
  // klunlInitEqn is called by the foundation on load; redefine it to set
  // up our equation + initial readouts once MathJax/DOM are ready.
  // ------------------------------------------------------------------
  window.klunlInitEqn = function () { updateMathReadouts(); };

  var booted = false;
  function boot() {
    if (booted) { return; }
    booted = true;
    init();
  }

  // Run init once the DOM is ready; re-typeset once MathJax has loaded so
  // the equation, readouts and tick labels are all typeset (no CDN; async).
  function whenDomReady(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else { fn(); }
  }
  whenDomReady(function () {
    boot();
    if (window.MathJax && window.MathJax.startup && window.MathJax.startup.promise) {
      window.MathJax.startup.promise.then(function () {
        buildOverlay();          // re-typeset tick labels
        updateMathReadouts();    // re-typeset equation + readouts
      }, function () {});
    }
  });
})();
