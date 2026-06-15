# Lookback Time Simulator (Accessible HTML5)

An accessible, self-contained HTML5 rebuild of the NAAP/KL-UNL **Lookback Time
Simulator**, built on the shared KL-UNL foundation files.

## It must be served over HTTP — double-clicking `index.html` will NOT work

Open it from a web server, not from a `file://` path. The KL-UNL masthead
component (`foundation/kl-unl-masthead.js`) loads its title / Help / About text
with `fetch('foundation/contents.json')`, and browsers **block `fetch()` over
the `file://` protocol** (same-origin policy). Opening `index.html` by
double-clicking it therefore shows an empty or broken masthead. Served over
HTTP the fetch succeeds and the sim loads normally.

## How to run it locally

Run one of these **from inside this `html5/` folder**, then open the URL:

```bash
# Python 3
python3 -m http.server 8123
#   then open  http://localhost:8123/

# Node
npx serve
#   (or)  npx http-server
```

Or use the **VS Code "Live Server"** extension.

Because you serve from inside `html5/`, the sim is at the server **root** —
the URL is `http://localhost:8123/`, not `.../html5/index.html`.

## Production

When deployed to the cloud host (served over HTTP/HTTPS) it just works; the
`file://` limitation only affects local double-clicking. Nothing leaves the
host at runtime: the only fetches are local (`foundation/contents.json` and the
locally vendored MathJax in `assets/mathjax/`). No build step, bundler,
framework, CDN, or analytics.

## What's in here

```
index.html            KL-UNL scaffold (masthead + panels), MathJax include
foundation/           KL-UNL shared files, copied in UNCHANGED
                      (kl-unl-masthead.js, kl-unl.css, kl-unl.js, contents.json*)
styles/styles.css     sim-specific styles only
simulation.js         all sim logic (state, render, behavior)
assets/
  observer.png        reused exported art (the observer)
  star/1..18.png      reused exported art (the star + supernova blow-up frames)
  mathjax/            locally vendored MathJax (SVG output)
CONVERSION_NOTES.md   behavior model, AS->HTML5 mapping, deviations
ACCESSIBILITY.md      WCAG affordances and screen-reader notes
```

\*Only the local copy of `contents.json` was edited — this sim's `lookbackTime`
entry was added. The foundation `.js`/`.css` files are byte-for-byte unchanged.
