# Homebrew Tap for LastDB

This is the official [Homebrew](https://brew.sh) tap for LastDB (formerly
FoldDB), a local-first database for personal data sovereignty.

> **Renamed:** FoldDB → **LastDB** (rebrand, 2026-06). The new install path is
> `edgevector/lastdb/lastdb`. The old `edgevector/folddb/folddb` path still works
> (the tap repo keeps a GitHub redirect and a back-compat `folddb` formula), so
> existing installs are not broken — but new installs should prefer `lastdb`.

## Installation

```bash
brew tap edgevector/lastdb
brew install lastdb
```

Or in a single command:

```bash
brew install edgevector/lastdb/lastdb
```

### Migrating from `folddb`

The old formula still resolves for back-compat:

```bash
brew install edgevector/folddb/folddb   # still works (alias of lastdb)
```

Both install the same release tarball, which ships both the new `lastdb` /
`lastdb_server` binaries and the legacy `folddb` / `folddb_server` names, so
your existing scripts keep working. To switch over cleanly:

```bash
brew uninstall folddb
brew install edgevector/lastdb/lastdb
```

## Upgrade

```bash
brew upgrade lastdb
```

## Included Binaries

- `lastdb` -- CLI for interacting with your LastDB instance
- `lastdb_server` -- HTTP server for the LastDB dashboard and API

For back-compat, the `folddb` and `folddb_server` command names are also
available (symlinked to `lastdb` / `lastdb_server`).

This tap also ships a second, separate formula: `folddb-dev`, the developer
node (a dev/test tool for building LastDB apps — not the end-user daemon). It
keeps the `folddb-dev` name until its source repo and assets are renamed:

```bash
brew install edgevector/lastdb/folddb-dev
```

## Formula bumps

Both formulas are bot-maintained. **Do not hand-edit the
`version`/`url`/`sha256` lines of either** — they are regenerated on the
next release of the formula's source repo.

### `Formula/lastdb.rb` (and the `folddb.rb` back-compat alias)

Updated automatically on each release of the
[`EdgeVector/fold`](https://github.com/EdgeVector/fold) monorepo (which
contains `fold_db_node`).

- **Source**: [`EdgeVector/fold`](https://github.com/EdgeVector/fold) workflow [`.github/workflows/release.yml`](https://github.com/EdgeVector/fold/blob/main/.github/workflows/release.yml), job `bump-tap`.
- **Trigger**: push of a release tag matching `v*` to `fold` (prereleases — tags containing `-`, e.g. `v0.3.0-alpha`, are skipped so they don't overwrite the stable formula; the workflow's `workflow_dispatch` and weekly-smoke runs never reach `bump-tap`).
- **Assets**: `EdgeVector/fold` is a **private** repo, so its release tarballs aren't publicly fetchable. The release job mirrors the per-platform tarballs (`lastdb-*.tar.gz` + `folddb-*.tar.gz` + `SHA256SUMS.txt`) to a **public** release tagged `v${VERSION}` **on this tap repo** — that's what the formula's `url`s point at (`github.com/EdgeVector/homebrew-lastdb/releases/...`). Pointing a formula at the private `fold` release URLs would 404 for end users.
- **Mechanism**: the workflow regenerates the formula (version + per-platform sha256s), pushes a branch named `auto-bump/v${VERSION}`, opens a PR titled `bump: lastdb → v${VERSION}`, and enables GitHub auto-merge (squash, via this repo's merge queue). The PR lands once CI goes green (typically <60s).
- **Manual cadence**: none. If a tap PR sits open, it's a CI/branch-protection issue on this repo, not a missing release step. Check the [Actions tab on `fold`](https://github.com/EdgeVector/fold/actions/workflows/release.yml) for the failing `bump-tap` job.
- **Local clones drift**: the bot pushes directly to `main` here. A long-lived local clone will go stale between releases — `git pull` to catch up. End users get fresh formulas via `brew update`; nobody needs to pull this repo to install.

> **Bot follow-up (rebrand):** the `bump-tap` job on `fold` still regenerates
> `Formula/folddb.rb` against the `folddb-*` release assets. Until that job is
> taught to emit `Formula/lastdb.rb` against the `lastdb-*` assets, the next
> auto-bump may overwrite the `lastdb.rb` formula's source-of-truth status.
> Tracked as a Phase-3 follow-up.

### `Formula/folddb-dev.rb`

Updated automatically on each `folddb-dev-v*` release of the
[`EdgeVector/fold`](https://github.com/EdgeVector/fold) monorepo (which
contains `fold_dev_node` as the workspace members
`fold_dev_node/crates/{core,bin}`). The `fold_dev_node` repo was archived
and folded into `fold` (fold#911, 2026-06-20); its release pipeline now
lives in the monorepo on its own `folddb-dev-v*` tag line, separate from
`fold`'s `v*` tags that ship `folddb`/`lastdb`.

- **Source**: `EdgeVector/fold` workflow [`.github/workflows/folddb-dev-release.yml`](https://github.com/EdgeVector/fold/blob/main/.github/workflows/folddb-dev-release.yml), job `bump-tap` — a sibling of `release.yml`'s job, same surgical-edit pattern (it runs `scripts/release/bump-homebrew-formula-dev.rb`).
- **Trigger**: push of a release tag matching `folddb-dev-v*` to `fold` (e.g. `folddb-dev-v0.3.1`). Prerelease tags (a `-` in the version, e.g. `folddb-dev-v0.3.1-dev.1`) skip the bump; `workflow_dispatch` is a build-only dry run that publishes nothing.
- **Assets**: because the source repo is private, the release job first mirrors the tarballs (+ `SHA256SUMS.txt` and `developer-onboarding.md`) to a public release tagged `folddb-dev-v${VERSION}` **on this tap repo** — that's what the formula's `url`s point at. The `folddb-dev-` tag prefix and `--latest=false` keep these mirror releases from colliding with the main `folddb`/`lastdb` formula's `v*` releases that share this repo.
- **Mechanism**: the workflow regenerates `Formula/folddb-dev.rb` (version + per-platform sha256s), pushes a branch named `auto-bump/folddb-dev-v${VERSION}`, opens a PR titled `bump: folddb-dev → v${VERSION}`, and enables auto-merge (squash, via this repo's merge queue).
- **Hand-edits**: not safe for `version`/`url`/`sha256` lines (overwritten on the next release). Structural edits (caveats, install block) are allowed — the bump is surgical and the workflow fails loudly if its diff touches anything beyond version/url/sha256 lines.

## Links

- [LastDB Website](https://folddb.com)
- [GitHub](https://github.com/EdgeVector/fold)
- [Documentation](https://edgevector.com/docs)
