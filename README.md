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

## Formula bumps

`Formula/folddb.rb` is updated automatically on each `fold_db_node`
release. **Do not hand-edit it** — your change will be overwritten on
the next release.

- **Source**: [`EdgeVector/fold_db_node`](https://github.com/EdgeVector/fold_db_node) workflow `.github/workflows/release.yml`, job `bump-tap`.
- **Trigger**: push of a release tag matching `v*` to `fold_db_node` (prereleases — tags containing `-`, e.g. `v0.3.0-alpha`, are skipped so they don't overwrite the stable formula).
- **Mechanism**: the workflow regenerates `Formula/folddb.rb` (version + per-platform sha256s), pushes a branch named `auto-bump/v${VERSION}`, opens a PR titled `bump: folddb → v${VERSION}`, and enables GitHub auto-merge. The PR lands once `ci-required` and `Auto-merge` go green (typically <60s).
- **Manual cadence**: none. If a tap PR sits open, it's a CI/branch-protection issue on this repo, not a missing release step. Check the [Actions tab on `fold_db_node`](https://github.com/EdgeVector/fold_db_node/actions/workflows/release.yml) for the failing `bump-tap` job.
- **Local clones drift**: the bot pushes directly to `main` here. A long-lived local clone of `homebrew-folddb` will go stale between releases — `git pull` to catch up. End users get fresh formulas via `brew update`; nobody needs to pull this repo to install.

## Links

- [FoldDB Website](https://folddb.com)
- [GitHub](https://github.com/EdgeVector/fold_db_node)
- [Documentation](https://edgevector.com/docs)
