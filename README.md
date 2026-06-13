# Homebrew Tap for FoldDB

This is the official [Homebrew](https://brew.sh) tap for [FoldDB](https://folddb.com), a local-first database for personal data sovereignty.

## Installation

```bash
brew tap edgevector/folddb
brew install folddb
```

Or in a single command:

```bash
brew install edgevector/folddb/folddb
```

## Upgrade

```bash
brew upgrade folddb
```

## Included Binaries

- `folddb` -- CLI for interacting with your FoldDB instance
- `folddb_server` -- HTTP server for the FoldDB dashboard and API

This tap also ships a second, separate formula: `folddb-dev`, the FoldDB
developer node (a dev/test tool for building FoldDB apps — not the
end-user daemon):

```bash
brew install edgevector/folddb/folddb-dev
```

## Formula bumps

Both formulas are bot-maintained. **Do not hand-edit the
`version`/`url`/`sha256` lines of either** — they are regenerated on the
next release of the formula's source repo.

### `Formula/folddb.rb`

Updated automatically on each release of the
[`EdgeVector/fold`](https://github.com/EdgeVector/fold) monorepo (which
contains `fold_db_node`).

- **Source**: [`EdgeVector/fold`](https://github.com/EdgeVector/fold) workflow [`.github/workflows/release.yml`](https://github.com/EdgeVector/fold/blob/main/.github/workflows/release.yml), job `bump-tap`.
- **Trigger**: push of a release tag matching `v*` to `fold` (prereleases — tags containing `-`, e.g. `v0.3.0-alpha`, are skipped so they don't overwrite the stable formula; the workflow's `workflow_dispatch` and weekly-smoke runs never reach `bump-tap`).
- **Mechanism**: the workflow regenerates `Formula/folddb.rb` (version + per-platform sha256s), pushes a branch named `auto-bump/v${VERSION}`, opens a PR titled `bump: folddb → v${VERSION}`, and enables GitHub auto-merge (squash, via this repo's merge queue). The PR lands once CI goes green (typically <60s).
- **Manual cadence**: none. If a tap PR sits open, it's a CI/branch-protection issue on this repo, not a missing release step. Check the [Actions tab on `fold`](https://github.com/EdgeVector/fold/actions/workflows/release.yml) for the failing `bump-tap` job.
- **Local clones drift**: the bot pushes directly to `main` here. A long-lived local clone of `homebrew-folddb` will go stale between releases — `git pull` to catch up. End users get fresh formulas via `brew update`; nobody needs to pull this repo to install.

### `Formula/folddb-dev.rb`

Updated automatically on each release of
[`EdgeVector/fold_dev_node`](https://github.com/EdgeVector/fold_dev_node)
(private repo — the link 404s without org access).

- **Source**: `EdgeVector/fold_dev_node` workflow `.github/workflows/release.yml`, job `bump-tap` — a mirror of fold's job, same surgical-edit pattern.
- **Trigger**: push of a release tag matching `v*` to `fold_dev_node`. Prerelease tags (containing `-`, e.g. `v0.3.0-dev.1`) skip the bump; `workflow_dispatch` is a build-only dry run that publishes nothing.
- **Assets**: because the source repo is private, the release job first mirrors the tarballs (+ `SHA256SUMS.txt` and `developer-onboarding.md`) to a public release tagged `folddb-dev-v${VERSION}` **on this tap repo** — that's what the formula's `url`s point at. The `folddb-dev-` tag prefix and `--latest=false` keep these mirror releases from colliding with `folddb`'s.
- **Mechanism**: the workflow regenerates `Formula/folddb-dev.rb` (version + per-platform sha256s), pushes a branch named `auto-bump/folddb-dev-v${VERSION}`, opens a PR titled `bump: folddb-dev → v${VERSION}`, and enables auto-merge (squash, via this repo's merge queue).
- **Hand-edits**: not safe for `version`/`url`/`sha256` lines (overwritten on the next release). Structural edits (caveats, install block) are allowed — the bump is surgical and the workflow fails loudly if its diff touches anything beyond version/url/sha256 lines.

## Links

- [FoldDB Website](https://folddb.com)
- [GitHub](https://github.com/EdgeVector/fold)
- [Documentation](https://edgevector.com/docs)
