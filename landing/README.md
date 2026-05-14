# 2048 Mac — Landing

Production single-page marketing site for the 2048 Mac app.
Locked design: Variant A · "Split & Trusted" (see `../ux-spec-2026-05-14-game2048-landing.md` §9.5).

- **Target domain:** `https://games.moone.dev/`
- **Stack:** static HTML + CSS + vanilla JS → nginx:alpine container
- **Footprint:** ~30 KB HTML + ~60 KB icon, no webfonts, no external requests

```
landing/
├── index.html          # the page
├── assets/
│   ├── icon-256.png    # favicon + wordmark glyph
│   └── icon-512.png    # apple-touch-icon + og:image fallback
├── Dockerfile          # nginx:alpine, ~10 lines
├── nginx.conf          # gzip + security headers + cache policy
├── robots.txt
├── .dockerignore
└── README.md           # this file
```

---

## Local preview

```bash
# Just open the file
open landing/index.html

# Or serve via a local http server (matches production path layout)
cd landing && python3 -m http.server 8080
# → http://localhost:8080/
```

## Local Docker build (sanity-check the production container)

```bash
cd landing
docker build -t game2048-landing .
docker run --rm -p 8080:80 game2048-landing
# → http://localhost:8080/
```

---

## Deploy to Dokploy

The landing is shipped as a **Docker Application** in Dokploy. Two paths depending on whether the GitHub repo is wired up.

### Path A · Git source (recommended)

1. Push this repo to GitHub (or your self-hosted git). The Dockerfile lives at `landing/Dockerfile`.
   ```bash
   # from the project root
   git remote add origin git@github.com:kyzdes/ios-2048.git   # adjust to your URL
   git add landing
   git commit -m "feat(landing): production Variant A — Dockerized for Dokploy"
   git push -u origin main
   ```

2. **Dokploy UI → Projects → ➕ Create Project → Application**
   - **Source:** Github / Git (paste the repo URL + token if private)
   - **Branch:** `main`
   - **Build path:** `landing` ← important, this is the subfolder containing the Dockerfile
   - **Build type:** Dockerfile
   - **Dockerfile path:** `Dockerfile` (relative to Build path)
   - **Port:** `80`

3. **Domains tab → ➕ Add domain**
   - **Host:** `games.moone.dev`
   - **Path:** `/`
   - **Port:** `80` (the container's internal port)
   - **HTTPS:** ON
   - **Certificate provider:** Let's Encrypt
   - (Dokploy's Traefik provisions the cert on first request — make sure the DNS A record for `games.moone.dev` points at the VPS first.)

4. **Deploy → Deploy now.** First build takes ~30 s (nginx:alpine is small).

5. Verify:
   ```bash
   curl -sI https://games.moone.dev/ | head -5
   curl -s  https://games.moone.dev/ | grep -o '<title>.*</title>'
   ```

### Path B · Manual upload (no git)

If the repo isn't on a public/connected git host yet:

1. Tar the build context:
   ```bash
   cd landing
   tar --exclude='.DS_Store' -czf ../landing-dist.tar.gz .
   ```

2. **Dokploy UI → Create Application → Source: "Drop"** (or "Upload" depending on Dokploy version) → upload `landing-dist.tar.gz`.

3. Same Build type / Port / Domain config as Path A.

### Auto-deploy on push

Once Path A is working, enable Dokploy's webhook:
1. **Application → Settings → Auto deploy → Webhook URL** (copy it)
2. GitHub repo → **Settings → Webhooks → ➕ Add webhook** — paste the URL, content type `application/json`, push events
3. Every `git push origin main` that touches `landing/**` will trigger a rebuild

---

## DNS setup (one-time)

Before Dokploy can issue a cert for `games.moone.dev`, point DNS at your VPS:

```
games.moone.dev.    A    <YOUR_VPS_IPv4>
games.moone.dev.    AAAA <YOUR_VPS_IPv6>   # optional
```

Wait for propagation (`dig games.moone.dev +short` returns your VPS IP), then trigger Dokploy's "Issue certificate" if it didn't auto-fire.

---

## Updating content

- **Copy / layout changes** → edit `landing/index.html`, push, Dokploy auto-rebuilds.
- **New release** → bump the version label in two places inside `index.html`:
  - hero CTA `<span class="meta">DMG · v1.0</span>`
  - footer build block (`v1.0 (build 1)`)
  - download cards (`<span>v1.0</span>` and SHA-256 hint)
- **GitHub Release link** stays stable — both CTA and ZIP point at GitHub's `/releases/latest/download/` redirect, no per-version edit needed.

To auto-inject the version at build time, add a `sed` step before `nginx`:

```dockerfile
ARG APP_VERSION=v1.0
RUN sed -i "s|v1\\.0|${APP_VERSION}|g" /usr/share/nginx/html/index.html
```

and pass `--build-arg APP_VERSION=v1.1` from Dokploy's Build args section.

---

## Known TODOs

- [ ] **GitHub URL** — `index.html` currently links to `https://github.com/kyzdes/ios-2048`. Replace if your final repo URL differs.
- [ ] **OG image** — currently uses `icon-512.png` (square). A proper 1200×630 share image would render better in Twitter / Slack previews; render via a `/og-template.html` + Playwright screenshot.
- [ ] **SHA-256 hashes** — placeholder text in `<details class="sha">` blocks. Inject real hashes via `sed` at release time, or pull from the GitHub Release body via build-time fetch.
- [ ] **Analytics** — none. The footer copy says "We collect nothing." If that changes, add a minimal privacy line.
