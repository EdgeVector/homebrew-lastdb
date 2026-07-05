# ⛔ ARCHIVED — moved to `edgevector/lastdb`

This tap is **archived** (2026-07-05). LastDB's Homebrew home is now:

```bash
brew install edgevector/lastdb/lastdb
```

The brew version of LastDB is the **minimal headless daemon** (`lastdbd`):
core database over a Unix socket — no web UI, no ingestion. See
[EdgeVector/homebrew-lastdb](https://github.com/EdgeVector/homebrew-lastdb).

## If you installed from this tap

```bash
brew uninstall edgevector/folddb/folddb   # or folddb-dev
brew untap edgevector/folddb
brew install edgevector/lastdb/lastdb
```

Your data is untouched by the reinstall (it lives in `~/.folddb` /
`~/.lastdb`, not in the keg).

Release assets up to v0.20.13 remain downloadable here for old pinned
installs; all newer releases publish to `homebrew-lastdb`.
