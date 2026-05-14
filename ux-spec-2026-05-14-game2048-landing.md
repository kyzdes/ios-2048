# 2048 Mac · UX Spec

> Generated: 2026-05-14 · Source language: ru
> Archetype: landing

## 1. Product Framing

- **Type:** Landing / marketing site (single page)
- **Audience:** Casual puzzle players who know 2048 and want a native Mac client; secondarily devs/HN-crowd who appreciate signed, notarized, ad-free desktop apps. Referred via Twitter / HN / Reddit / a GitHub Release link. Tech comfort: medium–high. They do not need a "what is 2048" explainer; they need to confirm this is the real 2048 + trust the binary + download.
- **Core JTBD:** "When I want to play 2048 without browser tabs, telemetry, or ads, I want a native Mac app I can trust, so I can install it in 10 seconds and play offline."
- **Success metric:** Download conversion (DMG click / unique visit), target 25%. Secondary: time-to-download < 30 seconds.
- **Out of scope:** Account creation, leaderboards, in-app purchases, cross-device sync, blog, changelog page. iOS distribution is mentioned ("coming soon") but not the focus — App Store gating is undecided.

## 2. Functional Scope

### Must-have features (v1)

- Hero with the 2048 mark (golden tile) + 1-line headline + primary "Download for Mac" CTA above the fold
- Live game board preview (animated auto-play or playable in-page) using the real 2048 palette and tile gradient
- Feature row: Native macOS · 60 fps · Free · Open source · No ads · Light + Dark · Keyboard + Trackpad
- How-to-play 3-step explainer (Swipe / Merge / Reach 2048) with tiny tile illustrations
- Download section with two artifacts: signed-notarized DMG (primary) and ZIP (fallback / Sparkle-ready), each with size + macOS version requirement
- "Notarized by Apple · Developer ID Viacheslav Kuznetsov" trust badge near the download
- iOS "Coming soon" placeholder card (no link yet)
- Footer: version label, GitHub repo link, license, copyright

### Nice-to-have (v1.5+)

- Auto-detect macOS version + warn if < 14.0
- Total downloads counter (read from GitHub Releases API)
- Embedded gameplay GIF / short MP4 as a fallback when the live board fails to load
- Russian / English locale toggle (UI is already EN-only in the app)

### Explicitly out of scope

- Sign-up / email capture — there is no email list, would feel like overreach for a free game
- Pricing table — single free tier, table would be ceremony
- Customer testimonials — no users yet, fake testimonials hurt trust more than they help
- Cookie banner — site collects nothing; if analytics gets added later, add then

## 3. User Flows

### Flow 1: Cold visitor → Mac download [primary]

1. **Entry:** External link (Twitter, HN, GitHub Release, search) → land at hero
2. Recognize the 2048 visual identity in ~2 seconds (golden tile mark, warm cream background)
3. Read the headline + glance at the live board to confirm it's a working 2048 client
4. Scroll a screen-height — features + how-to-play reinforce trust + completeness
5. Click "Download for Mac" → browser starts DMG download
6. **Outcome:** DMG in the user's Downloads folder; landing shows a small "Thanks — open the DMG and drag 2048 to Applications" inline confirmation under the button

**Failure paths:**
- User is on Windows / Linux → primary CTA detects platform and shows "Mac only for now — star the repo for iOS / Windows updates" with the GitHub link
- User is on iPhone / Android → CTA swaps to "iOS coming soon — get notified" → opens a `mailto:` link (no list infra needed for v1)
- DMG link 404 / GitHub Release unreachable → button shows "Mirror unavailable — try the ZIP" with the second artifact

### Flow 2: Returning visitor checking for an update

1. **Entry:** Direct URL or bookmark
2. Scroll past hero to footer (or look at the version label near the download)
3. Compare displayed version vs. their installed version
4. Re-download if newer
5. **Outcome:** New DMG downloaded; user replaces /Applications/2048 Mac.app

**Failure paths:**
- No version info on page → user can't tell if there's an update; mitigated by always rendering `v<MARKETING_VERSION>` next to the download button and in the footer

## 4. Screen Inventory

| ID | Screen | Purpose | Entry points | Key actions |
|----|--------|---------|--------------|-------------|
| S1 | Landing (single page) | Convey 2048 identity, prove trust, hand over a notarized Mac binary | External links, GitHub Release, search, direct URL | Read hero, watch / play live board, click Download DMG, fallback to ZIP, follow GitHub link |

(Single-page site — sections within S1, not separate screens.)

## 5. Per-Screen Briefs

### S1 · Landing

- **Information hierarchy:**
  - H1: Hero headline ("Join the tiles. Get to **2048**." — 2 lines max, the "2048" lockup uses the golden-tile mark)
  - H2: One-line sub-headline ("A native, notarized, ad-free 2048 for macOS.")
  - H3: Primary "Download for Mac · DMG · v1.0" button
  - H4: Live board (right of hero on desktop, below CTA on mobile)
  - H5: Feature row, how-to-play, download section, footer
- **Key elements (top to bottom):**
  - Sticky top bar — wordmark "2048" (golden tile glyph) + minimal nav (Features · Download · GitHub). Stays warm-cream with a 1px hairline border on scroll.
  - Hero — left column: H1 + sub-headline + primary CTA + "Notarized by Apple" trust micro-badge. Right column: live board (4×4) actively playing itself with a soft drop-shadow on the board card.
  - Feature chips — 6–7 inline chips (Native macOS · 60 fps · Free · Open source · No ads · Light + Dark · Keyboard + Trackpad), each tile-styled with the cell-background warm-grey.
  - How-to-play — 3 numbered cards, each with a tiny board illustration showing the action (swipe direction arrows / two equal tiles merging / a 2048 tile celebrated).
  - Download section — two cards side-by-side: **DMG (primary, golden)** and **ZIP (secondary, beige)**. Each card shows artifact size, macOS 14.0+ requirement, SHA-256 in a `<details>` toggle. Below them, a third muted card "iOS · coming soon".
  - Footer — three columns on desktop / stacked on mobile: (1) wordmark + 1-line tagline; (2) Links — GitHub repo, License (MIT or whichever), Privacy ("We collect nothing."); (3) Build — `v1.0 (build 1)` · Notarized · Built with SwiftUI.
- **Mobile adaptation:** Hero stacks vertically — H1 + sub-headline + CTA on top, live board below at full width inside a 16px-padded card; sticky top bar collapses to wordmark only with a `Download` chip on the right; feature chips wrap into 2 rows; download cards stack; FAQ-like sections (how-to-play) become a vertical list. No hamburger — links live in the footer.
- **States:**
  - **Empty:** N/A — content is static + the auto-play board is deterministic (a recorded sequence of moves loops every ~20s)
  - **Loading:** Above-fold critical CSS inlined; the live board hydrates after first paint with a low-effort placeholder (static 4×4 grid in cell-background colour, no tiles); fonts load with `font-display: swap` so the "2048" lockup never gets re-flowed
  - **Error:** Live board JS fails → fall back to an inlined static SVG showing a mid-game position; Download GitHub Release unreachable → button label changes to "Mirror unavailable — try ZIP →" and visually de-emphasizes the DMG card
  - **Success:** Click on Download → button morphs to "✓ Downloading…" for 2s, then to "Open Downloads ↓" linking to `chrome://downloads` semantically (just text — no actual deep-link)
- **Interactions:**
  - Sticky top bar appears with a hairline border after ~80px of scroll
  - Live board auto-plays a 20s loop by default; on click/tap, switches to a real playable mini-game (keyboard arrows on desktop, swipe on touch) with a small "Reset" link
  - How-to-play cards have a subtle hover lift (2px shadow)
  - Download buttons: hover = `+2%` scale + warm shadow; active = `–2%` scale; focus ring uses the accent gold
  - Smooth scroll on top-bar anchor clicks; the URL fragment updates (#features / #download)
  - Light/dark toggle in the footer (or auto, prefers-color-scheme); palette mirrors the app's `GamePalette`

## 6. Constraints & Context

- **Platform & breakpoints:** Web responsive, static site (no backend).
  - Desktop ≥1280px
  - Tablet 768–1279px
  - Mobile 375–767px
- **Per-breakpoint feature parity** (always required):

| Screen | Mobile (375–767) | Tablet (768–1279) | Desktop (≥1280) |
|--------|------------------|--------------------|------------------|
| S1 | full (stacked, live board below CTA, sticky bar collapsed to wordmark + Download chip, footer stacked) | full (single-column hero with live board centered; feature chips in one row; download cards side-by-side) | full (two-column hero, live board to the right, feature chips in one row, download cards side-by-side, three-column footer) |

- **Accessibility:** WCAG 2.1 AA. All CTAs keyboard-accessible with a visible focus ring in accent gold. Live board is decorative — `aria-hidden="true"` when auto-playing; if a user activates Play mode, the board exposes role="application" with arrow-key controls and labelled tiles. Colour contrast ≥4.5:1 everywhere (the warm cream/grey/text combination from `GamePalette` already satisfies this in light mode; dark-mode palette is also AA-compliant).
- **Localization:** English v1. Strings are inlined; no i18n framework. RU/EN toggle is a v1.5 idea.
- **Performance budget:** LCP < 1.2s on 4G; total page weight < 250 KB excluding the live board JS (which is < 50 KB minified); zero render-blocking JS; the live board hydrates lazily; one custom font max (system font preferred, falls back to SF Pro Rounded / Avenir / system-ui).
- **Auth model:** None. The download is anonymous. The CTA is a plain link to a GitHub Release asset.
- **Data sources:** None at runtime; build-time pulls `MARKETING_VERSION` + asset sizes from the GitHub Release tag (or hard-codes them per release).
- **Offline behavior:** Online-required marketing site. Service Worker is not in scope.

## 7. Design Context (for huashu)

- **Existing design system:** Yes — the iOS / macOS app's `GamePalette` (see `Game2048/GamePreferences.swift` in the same repo). The landing should feel like a continuation of the app, not a different brand.
- **Brand assets available:**
  - Logo / icon: 1024×1024 PNG at `Game2048/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` (golden tile with white "2048" on warm cream + faded 4×4 grid behind). Reuse this as the favicon and as the hero wordmark glyph.
  - Colors: use the app's palette verbatim —
    - Background `#FAF8EF` (light) / `#1A1A1E` (dark)
    - Primary text `#776E65` (light) / `#F2ECDF` (dark)
    - Board background `#BBADA0` (light) / `#3B3941` (dark)
    - Cell background `#CDC1B5` (light) / `#4D4A57` (dark)
    - Tile gold (the "2048" tile and accent): `#EDC22E`
    - Button background `#8F7A66` (light) / `#B29263` (dark)
  - Fonts: SF Pro Rounded as the primary face (matching the app's `.system(..., design: .rounded)`); fallback `Avenir, "SF Pro Rounded", system-ui, sans-serif`. No webfont download required.
  - Product images / UI screenshots: not yet — the live board is the product image. If huashu wants a hero screenshot, it can take one of the running app (already built at `build/release/Game2048Mac.app`).
- **References / inspiration:** play2048.co (the original web 2048 — the visual gold-standard), the in-app `ContentView.swift` layout (board card + score boxes + restart button — same warmth, same rhythm). Avoid Vercel/Linear-style hero-dark-gradient — that's the wrong vibe.
- **Design direction known:** Yes — extend the app's warm-paper palette to a web layout. No advisor mode needed; constraints are tight.
- **Brand voice / tone:** Friendly, low-ceremony, slightly nostalgic (2048 is a 2014 classic). No marketing jargon, no growth-hack language, no "elevate your puzzle experience" — just "It's 2048. For Mac. Free."

## 8. Hand-off to huashu-design

### 8.1 Recommended delivery format

- [ ] `cjm-canvas`
- [x] **`hi-fi-static`** — single-page landing, 1 screen in §4, 1 primary flow (cold visitor → DMG download). All 3 skip-conditions met: ≤2 screens, ≤1 flow, no anon↔authed transitions / multi-state branching beyond a single fallback CTA.

**Reasoning:** Single-page marketing site, no inter-screen navigation, no auth flow, the only branching state (Mac / non-Mac / iOS visitor) is a CTA label swap that doesn't justify a canvas. Tweaks worth exploring (hero composition, live-board treatment, download-card emphasis) are scoped to one screen and read better as side-by-side variants than as sidebar toggles.

### 8.2 Information density type

- [x] **Restrained** — give the gold tile room to breathe; landings convert by being scannable; the 2048 palette is loud enough already
- [ ] High-density

**Reasoning:** The audience is making a 10-second trust decision about a free game binary. Information overload destroys that trust. The product itself is minimal; the landing must echo that.

### 8.3 Per-screen position-4 answers

| Screen | Narrative role | Audience distance | Visual temperature | Capacity check |
|--------|---------------|-------------------|---------------------|----------------|
| S1 Landing | hero | 1m laptop | warm | OK (max breathing) |

### 8.4 Variation dimensions to explore

- **Dimension 1: Hero composition** — text-left + live board on the right / centered single-column with live board below the CTA / fullscreen live board with overlaid headline (board IS the hero)
- **Dimension 2: Live board treatment** — auto-playing loop only (no interaction) / click-to-play (auto-loop then becomes playable on tap) / fully playable from first paint (no loop, the user IS playing 2048 inside the landing)
- **Dimension 3: Download-card emphasis** — DMG-only (ZIP hidden in a "more options" disclosure) / DMG primary + ZIP secondary side-by-side (current default) / equal-weight DMG + ZIP + iOS-coming-soon as a 3-card row

**Variation count recommendation:** 3

**Reasoning:** Hero composition is the highest-impact decision for first-click conversion; the live board's role (decorative vs. playable) defines the entire emotional tone; download-card emphasis determines whether new users feel guided (DMG-only) or respected as power users (3-card row).

### 8.5 Tweaks worth exposing

- Theme (light / dark / auto-prefers-color-scheme) [scope: global]
- Hero composition (text-left+board-right / centered+board-below / board-as-hero) [scope: S1] — §8.4 DIM 1
- Live board behaviour (auto-loop / click-to-play / fully playable) [scope: S1] — §8.4 DIM 2
- Download-card emphasis (DMG-only / DMG+ZIP / DMG+ZIP+iOS) [scope: S1] — §8.4 DIM 3
- Top bar style (transparent over hero / always solid cream / hide on scroll-down) [scope: S1]
- "Notarized by Apple" badge position (next to CTA / inside DMG card / both) [scope: S1]
- How-to-play step illustrations (tile pairs / arrow gestures / animated GIF strip) [scope: S1]

(Even though §8.1 = `hi-fi-static`, tweaks carry `[scope]` tags for forward-compatibility — if the site ever grows a separate "iOS launch" page, the metadata is already cjm-canvas-ready.)

### 8.6 Brand asset checklist

- [x] Logo / icon provided (`Game2048/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`)
- [ ] Product images / UI screenshots — not provided; huashu can render its own from `build/release/Game2048Mac.app` or render an in-page board
- [x] Colors specified (see §7 — full palette inline)
- [x] Fonts specified (SF Pro Rounded fallback chain)
- [x] Reference inspiration provided (play2048.co + the app's `ContentView` warmth)
- [ ] **Recommend huashu run §1.a Core Asset Protocol** — not required; brand is internally consistent and the palette + icon cover all needs

### 8.7 Canvas construction hint (for huashu)

`hi-fi-static`: single full-fidelity HTML page (React + Babel via CDN is fine, plain HTML + CSS + a tiny vanilla-JS board controller is equally fine — pick what makes the live board readable). All sections in one scroll:

1. Sticky top bar
2. Hero (headline + sub + CTA + live board)
3. Feature chips row
4. How-to-play 3-step explainer
5. Download section (2 or 3 cards depending on §8.4 DIM 3)
6. Footer

Interactive behaviours:

- Live board: deterministic 20s auto-play loop using the same tile colour mapping as `TileView.swift` (re-derive the hex values from §7); on click, switches to a 4×4 playable mini-game with `ArrowUp/Down/Left/Right` + `WASD` + swipe support; show a tiny "Reset" link below the board
- Smooth scroll on anchor clicks
- Theme toggle: respects `prefers-color-scheme` by default; manual override stored in `localStorage`
- Download CTA hover/active states use the app's `buttonBackground` colour for the shadow tint
- All copy is English, plain, low-ceremony

`hi-fi-static` means no sidebar, no flow nav, no Copy lock-in prompt button.

### 8.8 Lock-in prompt template (for the cjm-canvas Copy button)

Not applicable for `hi-fi-static`. If the site is later promoted to `cjm-canvas` (e.g., when an iOS launch sub-page is added), the lock-in prompt template would target this spec at:

`/Users/viacheslavkuznetsov/Desktop/Projects/ios2048/ux-spec-2026-05-14-game2048-landing.md`

…and follow the standard multi-block format (`Global:` + per-screen `Screen S<id> · <Name>:` blocks) defined in `references/spec-template.md`.

## 9. Open Questions & Assumptions

### Assumptions made (verify these)

- **Assumption:** Downloads are hosted on a GitHub Release (`gh release create v1.0 ...` was the final step printed by `script/release.sh`). The CTA links to a GitHub Release asset URL.
- **Assumption:** The repo is public — visitors can click the GitHub link in the footer and see the source. If it's private, hide the GitHub footer link until the repo is opened.
- **Assumption:** License is MIT (standard for tiny indie games). If different, update the footer.
- **Assumption:** Total download counter is OK to skip in v1; it adds an API call and rate-limit complexity for marginal trust gain.
- **Assumption:** The landing is hosted as a static site (GitHub Pages, Vercel, Netlify, Cloudflare Pages — interchangeable). No backend required.

### Open questions (need user input later)

- **Q:** Where will this landing be hosted? — **why it matters:** affects how the version label is updated (build script vs. manual) and whether we wire a GitHub Action.
- **Q:** Domain / URL? `2048.kyzdes.dev` / GitHub Pages default / something else — **why it matters:** the page's `<title>`, OG meta, and the wordmark "click home" link target.
- **Q:** Should there be a privacy / legal page or is "We collect nothing." inline in the footer enough? — **why it matters:** EU visitors expect at least a tiny privacy notice; current plan is to keep it inline.
- **Q:** iOS plan — App Store, TestFlight, or "no iOS for now"? — **why it matters:** the "iOS · coming soon" card behaviour (mailto / TestFlight link / hidden).

### Inferred from archetype defaults

- Single-page structure (landing archetype default)
- Hero + features + how-it-works + CTA + footer composition (landing archetype default)
- Restrained density (landing archetype default for non-data products)
- No auth, no analytics, no cookies (smallest-footprint static landing default)

### Product Risks

- **Trust collapse on non-notarized perception:** Even though the binary is signed + notarized, some users will see a Gatekeeper prompt on first open and bounce. Mitigation — surface "Notarized by Apple · Developer ID Viacheslav Kuznetsov" near the CTA and inside the DMG card; consider a 1-line "If macOS asks, click Open — the app is notarized" hint in the success state under the button.
- **Wrong-platform visitors leave silently:** Windows / Linux / mobile users hit the page and there's nothing for them. Mitigation — platform-aware CTA label swap (Flow 1 failure paths) + a single GitHub link so they can star and come back for iOS.
- **GitHub Release URL drift:** Hard-coding `…/releases/download/v1.0/Game2048Mac.dmg` breaks the page on every release. Mitigation — point the CTA to `…/releases/latest/download/Game2048Mac.dmg` (GitHub's stable redirect) and render the version label dynamically at build time.
- **Live-board JS becomes the page's LCP:** If the live board imports a heavy game engine or animates immediately, it can dominate the load and tank the conversion. Mitigation — keep the board < 50 KB minified, hydrate after first paint, fall back to an SVG snapshot if JS fails.
- **macOS-version mismatch:** Users on macOS < 14.0 download the DMG and it refuses to launch. Mitigation — render the `macOS 14.0+` requirement inside the DMG card and (nice-to-have) detect via `navigator.userAgent`.
- **Mobile bounce on a desktop-first product:** A landing for a Mac-only app gets a lot of mobile referral traffic from iOS-only Twitter clients. Mitigation — mobile CTA explicitly says "iOS coming soon — get notified" instead of offering a download that won't work.

### Considered Alternatives (§9.5)

> Initially empty. Populated automatically when the user pastes a "lock-in prompt" from a cjm-canvas Copy button — non-chosen §8.4 variants are archived here per screen so future iterations remember what was tried and rejected. Format:
>
> - **S<id> · §8.4 DIM <n> <NAME>:** considered `<variant-A>`, `<variant-B>`; locked `<variant-C>` on YYYY-MM-DD.

- **S1 · §8.4 DIM 1 Hero composition:** considered `centered single-column with board below CTA`, `full-bleed board-as-hero with overlaid headline`; locked `text-left + live board on the right` on 2026-05-14.
- **S1 · §8.4 DIM 2 Live-board behaviour:** considered `click-to-play (auto-loop → playable on tap)`, `fully playable from first paint`; locked `auto-playing loop only (no interaction)` on 2026-05-14.
- **S1 · §8.4 DIM 3 Download-card emphasis:** considered `DMG-only (ZIP hidden in disclosure)`, `equal-weight DMG + ZIP + iOS-coming-soon 3-card row`; locked `DMG primary (gold) + ZIP secondary (beige) side-by-side` on 2026-05-14.

> Lock-in rationale (Variant A · "Split & Trusted"): conservative path that mirrors play2048.co's split composition while giving the gold tile breathing room; auto-loop avoids the LCP and a11y overhead of a real keyboard handler in v1; DMG-prominent + ZIP-secondary respects the dev/HN audience without burying the Sparkle-ready fallback. Variants B and C remain available in `landing-2026-05-14-game2048-variants.html` for future A/B testing.

## 10. Mobile / Responsive Design Block

### 10.1 Mobile-first principles for this product

- **Navigation pattern:** No real nav — single sticky bar collapses to wordmark + a single "Download" chip. Anchor links live in the footer.
- **Gesture model:** Vertical scroll only. The live board accepts horizontal/vertical swipes ONLY when the user has explicitly tapped it to switch into play mode; otherwise the board absorbs no gestures so page-scroll never gets hijacked.
- **Performance budget:** LCP < 1.5s on 4G; total page weight < 200 KB above the fold; the live board JS is deferred and may load at all on mobile only after the hero is fully painted.

### 10.2 Per-screen mobile adaptation

| ID | Desktop layout | Mobile adaptation | Hidden / collapsed | Mobile-specific gestures |
|----|----------------|-------------------|--------------------|---------------------------|
| S1 | Two-column hero (text left, live board right); feature chips in one row; download cards side-by-side; three-column footer | Single column. Hero stacks: headline → sub-headline → CTA → live board (full-width card, 16px padding). Feature chips wrap into 2 rows. Download cards stack vertically. Footer columns stack. | Top-bar nav links (Features · Download · GitHub) collapse — only wordmark + Download chip remain in the sticky bar. The SHA-256 `<details>` toggle inside the DMG card stays collapsed by default. | Swipe inside the live board ONLY when the user has tapped it to enter play mode; outside play mode the board does not capture touch events so vertical page-scroll always wins. |

### 10.3 Touch interactions vs pointer

- Hover-only patterns are replaced by: always-visible action buttons (no hover-to-reveal). The how-to-play "lift on hover" effect drops to a static card with a 1px hairline border on mobile.
- Tap targets ≥44×44pt — applies to Download buttons, the play-mode toggle inside the live board, the theme toggle, and footer links.
- The live board's "Reset" action becomes a 44pt text button below the board on mobile instead of an inline tiny link.

### 10.4 Mobile-only screens or modes (if any)

- **Wrong-platform mode (iOS / Android visitors):** the primary CTA label swaps from "Download for Mac · DMG" to "iOS coming soon — get notified" with a `mailto:` link. The download cards section is replaced by a single muted card explaining "2048 for Mac is desktop-only; iOS is in the works." No DMG link is offered on mobile to avoid wasted bandwidth.

### 10.5 Mobile column for §8.3 position-4

| Screen | Mobile audience distance | Mobile capacity check |
|--------|---------------------------|------------------------|
| S1 Landing | 10cm phone | OK |

---

**Hand-off phrase suggestion** (paste into huashu chat):

```
Read this UX spec at /Users/viacheslavkuznetsov/Desktop/Projects/ios2048/ux-spec-2026-05-14-game2048-landing.md. Produce a hi-fi-static landing exploring §8.4 dimensions (hero composition, live-board behaviour, download-card emphasis) as side-by-side variants. Density type: restrained. Honor §8.3 position-4 answers (narrative=hero, distance=1m laptop, temperature=warm) and reuse the §7 palette + icon verbatim — this landing must feel like a continuation of the macOS app it ships, not a separate brand. Honor §10 mobile/responsive specifications when designing the mobile breakpoint.
```
