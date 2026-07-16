# Homebrew Tap for LastDB

This is the official [Homebrew](https://brew.sh) tap for LastDB (formerly
FoldDB), a local-first database you build your own tool stack on — one local
database under all your tools, owned by you.

> **Repository workflow:** LastGit `lastdb:///homebrew-lastdb` is the source of
> truth for code review, CI, and merges. GitHub remains the public Homebrew tap
> and release-asset surface so `brew tap edgevector/lastdb`, formula URLs, and
> browser access keep working. The public GitHub `main` branch is a mirror of
> LastGit `main`; open change requests in LastGit, not GitHub.

> **Homebrew installs LastDB Mini.** `brew services start lastdb` runs
> `lastdbd`: the semantic daemon — schema declare/query/
> mutate, app-identity, native search, and cloud sync (dormant until
> `lastdbd connect`) — served over a Unix socket at
> `~/.lastdb/data/folddb.sock`. No web UI, no ingestion, no discovery. Apps
> like fbrain and fkanban connect straight to the socket. The tarball ships
> only `lastdb` and `lastdbd`; install LastDB Desktop for the full UI and
> ingestion workflows.

> **Renamed + consolidated:** FoldDB → **LastDB** (rebrand, 2026-06). The old
> `EdgeVector/homebrew-folddb` tap is **archived** (2026-07-05): release
> assets are published here, and this repo's formulas are the only maintained
> ones. If you still have the old tap: `brew untap edgevector/folddb` after
> migrating (see below).

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

Both install the same LastDB Mini tarball, which ships `lastdb` and `lastdbd`;
the `folddb` command name remains as a compatibility symlink to
`lastdb`. The formulas intentionally conflict because they own the same
commands; uninstall the old formula before installing the new one so `lastdb`
links cleanly and is not shadowed by an existing `folddb` keg:

```bash
brew uninstall edgevector/folddb/folddb
brew install edgevector/lastdb/lastdb
```

## Upgrade

```bash
brew upgrade lastdb
```

## Included Binaries

- `lastdb` -- tiny socket/control CLI for inspecting request ops, status, and
  cloud connection state
- `lastdbd` -- LastDB Mini semantic daemon served over the owner Unix socket

For back-compat, the `folddb` command name is also available, symlinked to
`lastdb`.

This tap also ships a second, separate formula: `folddb-dev`, the developer
node (a dev/test tool for building LastDB apps — not the end-user daemon). It
keeps the `folddb-dev` name until its source repo and assets are renamed:

```bash
brew install edgevector/lastdb/folddb-dev
```

## Formula bumps

Both formulas are bot-maintained. **Do not hand-edit the
`version`/`url`/`sha256` lines of either** — they are regenerated on the
next release of the formula's source repo. Release assets continue to be
published on GitHub because Homebrew consumers need anonymous HTTPS asset
URLs, but formula changes land through LastGit and are mirrored back to GitHub.

## Repository venue

This tap is dual-home by design:

- GitHub `EdgeVector/homebrew-lastdb` remains the public Homebrew tap, release
  object host, and end-user install surface.
- Agent-authored repository changes route through LastGit change requests via
  `.last-stack/pr-venue`.
- GitHub `main` must stay mirrored from LastGit `main` so `brew tap
  edgevector/lastdb` and formula release asset URLs keep working for public
  users.

The LastGit gate for this repository is intentionally small: `.lastgit/ci.sh`
checks formula Ruby syntax and verifies that formula URLs still point at this
public tap's release assets.

### `Formula/lastdb.rb` (and the `folddb.rb` back-compat alias)

Updated automatically on each release of the
[`EdgeVector/fold`](https://github.com/EdgeVector/fold) monorepo (which
contains `lastdb_node` and the full desktop app source).

- **Source**: [`EdgeVector/fold`](https://github.com/EdgeVector/fold) workflow [`.github/workflows/release.yml`](https://github.com/EdgeVector/fold/blob/main/.github/workflows/release.yml), job `bump-tap`.
- **Trigger**: push of a release tag matching `v*` to `fold` (prereleases — tags containing `-`, e.g. `v0.3.0-alpha`, are skipped so they don't overwrite the stable formula; the workflow's `workflow_dispatch` and weekly-smoke runs never reach `bump-tap`).
- **Assets**: `EdgeVector/fold` is a **private** repo, so its release tarballs aren't publicly fetchable. The release job mirrors the minimal Apple-Silicon tarball (`lastdb-aarch64-apple-darwin.tar.gz` + `SHA256SUMS.txt`) to a **public** release tagged `v${VERSION}` **on this tap repo** — that's what the formula's `url`s point at (`github.com/EdgeVector/homebrew-lastdb/releases/...`). Pointing a formula at the private `fold` release URLs would 404 for end users.
- **Mechanism**: the workflow regenerates the formula (version + per-platform sha256s), pushes a branch named `auto-bump/v${VERSION}`, opens a LastGit CR titled `bump: lastdb → v${VERSION}`, and lets the LastGit `ci-required` gate merge it. The mirror job then pushes the merged formula to the public GitHub tap.
- **Manual cadence**: none. If a tap PR sits open, it's a CI/branch-protection issue on this repo, not a missing release step. Check the [Actions tab on `fold`](https://github.com/EdgeVector/fold/actions/workflows/release.yml) for the failing `bump-tap` job.
- **Ops CLI floor**: release `v0.22.11` is the first Homebrew Mini release
  expected to expose `lastdb ops`; `Formula/lastdb.rb`'s `test do` block now
  asserts the subcommand so future bumps cannot silently regress to a tarball
  without request-ops telemetry.
- **Local clones drift**: the mirror job updates GitHub `main` after LastGit merges. A long-lived local clone will go stale between releases — `git pull` to catch up. End users get fresh formulas via `brew update`; nobody needs to pull this repo to install.

> **Release shape:** since `v0.21.6`, the main formula is intentionally
> LastDB Mini: no `lastdb_server`, no `folddb_server`, no web UI bundle, and no
> ingestion CLI in the Homebrew artifact.

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
- **Mechanism**: the workflow regenerates `Formula/folddb-dev.rb` (version + per-platform sha256s), pushes a branch named `auto-bump/folddb-dev-v${VERSION}`, opens a LastGit CR titled `bump: folddb-dev → v${VERSION}`, and lets the LastGit `ci-required` gate merge it before the public GitHub mirror updates.
- **Hand-edits**: not safe for `version`/`url`/`sha256` lines (overwritten on the next release). Structural edits (caveats, install block) are allowed — the bump is surgical and the workflow fails loudly if its diff touches anything beyond version/url/sha256 lines.

## Links

- [LastDB Website](https://thelastdb.com)
- [GitHub](https://github.com/EdgeVector/fold)
- [Documentation](https://edgevector.com/docs)
