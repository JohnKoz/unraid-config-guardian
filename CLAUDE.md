# unraid-config-guardian (fork) — project notes for Claude

This is **my personal fork** of [stephondoestech/unraid-config-guardian](https://github.com/stephondoestech/unraid-config-guardian). Written for a future Claude session so you don't re-derive the setup every time.

## Deployment target

- Docker image: **`johnkoz/unraid-config-guardian:latest`** on Docker Hub.
- **Auto-published** by `.github/workflows/fork-publish.yml` on every push to my fork's `main`.
- Deployed on my Unraid server as container `UnraidConfigGuardian-fix-binhex-qbittorrentvpn` (deliberately named to distinguish from the upstream image, which is also installed but stopped as a rollback).
- After a merge to `main`, the workflow rebuilds `:latest` on Docker Hub — Unraid does *not* auto-pull, so a "Check for Updates" (or Auto Update Applications plugin) is needed to actually pick it up on the server.

## Local dev

- Python 3.10 venv at `./venv/` — invoke Python as `./venv/Scripts/python.exe` (Windows Git Bash).
- Tests: `./venv/Scripts/python.exe -m pytest tests/ -q`
- Lint (matches CI): `./venv/Scripts/python.exe -m black --check src/ tests/` and `./venv/Scripts/python.exe -m flake8 src/ tests/ --max-line-length=100 --extend-ignore=E203,W503`
- CI (`.github/workflows/ci-cd.yml`) pins Python 3.11, so filesystem-root path assumptions can pass locally on Windows and silently fail in CI — see the `Path("/output/...")` incident in commit `dfc6c13`. Always use the `output_dir` parameter, not hardcoded paths.

## Git remotes

- `origin` → `stephondoestech/unraid-config-guardian` (upstream; the source of truth for shared history)
- `fork` → `JohnKoz/unraid-config-guardian` (my fork; **push here to trigger the Docker publish workflow**)
- `fezster` → `fezster/unraid-config-guardian` (a third-party fork we cherry-picked the `mask_passwords` param from)

## Branch strategy — important

- **`bug/ISSUE#42-mask-vpn-socks-credentials`** is the branch for the **upstream PR only** (masking fix). **Do not** add personal-only fixes (TemplateResponse compat, UTF-8, Docker visibility, cached-templates cleanup, entrypoint fixes) to this branch. Keep it scoped to the credential-masking issue alone.
- **`main` and `personal/docker-build`** on the `fork` remote are for fork-only fixes. Everything shipped this session (ed2a277 cron fix, 70e125a restart cleanup, a3727fe log bridge, a50c91b sudoers, dfc6c13 CI fix) lives here.
- **Standing rule: PR not direct push.** Push feature branches, open PRs against `fork/main`, never push straight to `fork/main`.

## Related documentation

Full running history of this fork (bugs found, incidents, why-decisions) lives in a separate private homelab-docs repo, not here. If Claude has access to that repo through memory or configured MCP, refer there for the long-form context; otherwise treat this file as the authoritative reference.

## Watch out for

- The masking keyword list is finite. Anything the app doesn't recognize (`MY_CUSTOM_TOKEN`, arbitrary future vars) still leaks. Not fixed yet.
- The `MASK_PASSWORDS`-toggle-corruption fix was reverted mid-development and is **not** in the running image. After any restore involving this container's own template, verify `MASK_PASSWORDS=true` didn't get corrupted to `***MASKED***`.
