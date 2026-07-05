# frozen_string_literal: true

# Homebrew formula for the LastDB release artifacts.
class Lastdb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://thelastdb.com"
  version "0.20.13"
  license "Apache-2.0"
  deprecate! date: "2026-07-05", because: "this tap is archived; use edgevector/lastdb/lastdb"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.20.13/lastdb-aarch64-apple-darwin.tar.gz"
      sha256 "cb51d502cba804e3fb6939e8cbb4e89d91639d45505732f54c96807de26380ec"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.20.13/lastdb-x86_64-apple-darwin.tar.gz"
      sha256 "a27aef3fee4e477ff3f72634600175a2b48105d7cde4636fcfedd4af4d28d55b"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.20.13/lastdb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "93ea013a62819bf5099e86278c29487ff62d3e79c8e5579ebf038007515ba454"
    end
  end

  conflicts_with "edgevector/lastdb/folddb",
                 because: "both formulas install lastdb, lastdb_server, folddb, and folddb_server"

  def install
    bin.install "lastdb"
    bin.install "lastdb_server"
    # Minimal headless daemon (socket-only, no UI) — the brew-services
    # default since v0.20.14. Guarded: tarballs before that tag don't ship
    # it, and the formula must stay installable at the pinned version until
    # the auto-bump moves past it.
    bin.install "lastdbd" if File.exist?("lastdbd")

    # Back-compat: keep the old `folddb` / `folddb_server` command names working
    # for anyone migrating from `edgevector/folddb/folddb`. The release tarball
    # also ships these binaries, but symlinking keeps a single source of truth.
    bin.install_symlink "lastdb" => "folddb"
    bin.install_symlink "lastdb_server" => "folddb_server"
  end

  # `brew services start lastdb` runs the MINIMAL headless daemon: core DB
  # (schema declare/query/mutate), app-identity, native search, and cloud
  # sync (dormant until `lastdbd connect`) served over the owner Unix socket
  # at ~/.lastdb/data/folddb.sock — no web UI, no ingestion, no discovery.
  # Pin LASTDB_HOME so the minimal service never falls back to an existing
  # full-node ~/.folddb home on mixed desktop/service machines.
  # The full node (`lastdb_server`, :9001 dashboard) stays installed for
  # manual use: `lastdb daemon start`.
  service do
    run [opt_bin/"lastdbd"]
    keep_alive true
    run_at_load true
    log_path var/"log/lastdb/lastdbd.log"
    error_log_path var/"log/lastdb/lastdbd.err.log"
    environment_variables HOME:        Dir.home,
                          LASTDB_HOME: "#{Dir.home}/.lastdb",
                          PATH:        std_service_path_env
  end

  def caveats
    <<~EOS
      Quickstart (minimal daemon — the brew-services default):

      1. brew services start lastdb
         Runs `lastdbd`: the headless core database on the Unix socket
         ~/.lastdb/data/folddb.sock. No web UI, no ingestion — apps like
         fbrain and fkanban connect straight to the socket. A fresh install
         generates its identity keyfile on first boot. The Homebrew service
         pins LASTDB_HOME=~/.lastdb so it never attaches to an existing
         full-node ~/.folddb home.

      2. Joining an EXISTING LastDB account as a second device (e.g. your
         desktop node's data, synced through the cloud):
           lastdbd connect              # paste your 24-word recovery phrase
           brew services restart lastdb # first boot pulls your data

      Prefer the FULL node (web dashboard on :9001, ingestion, discovery)?
      It ships in this same package — run it manually instead:
           lastdb daemon start          # stop with `lastdb daemon stop`
           lastdb setup                 # first-time identity setup
           open http://localhost:9001   # dashboard
      (Don't run both against the same data dir at once.)

      Manual `lastdbd` runs are not service-pinned. On a machine with an
      existing ~/.folddb full-node home, run the minimal daemon and connect
      flow with an explicit LastDB home:
           lastdbd --data-dir ~/.lastdb
           lastdbd connect --data-dir ~/.lastdb
      or set LASTDB_HOME=~/.lastdb before invoking `lastdbd`.

      SAVE your 24-word recovery phrase somewhere safe — it is the ONLY way to
      recover your data on another device. Reprint it any time with:
           lastdb recovery-phrase

      The old `folddb` / `folddb_server` command names still work (symlinked to
      `lastdb` / `lastdb_server`) for back-compat while you migrate.

      If you already have the old `edgevector/folddb/folddb` formula installed,
      uninstall it before installing `lastdb`; both formulas own the same command
      names, so Homebrew cannot link them side-by-side:
           brew uninstall edgevector/folddb/folddb
           brew install edgevector/lastdb/lastdb

      After `brew upgrade lastdb`, the running daemon keeps serving the OLD binary
      on port 9001 — Homebrew does not restart it. Restart it the way you started it:
           brew services restart lastdb                  # if started via `brew services`
           lastdb daemon stop && lastdb daemon start     # if started manually
           lastdb daemon install                          # if installed as a LaunchAgent (re-run)
      A restart drops in-memory loaded schemas, so app clients (e.g. fbrain,
      fkanban) may need to re-run their `init` afterward.

      Second-device bootstrap (restore from your recovery phrase):
        https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/second-device.md

      If you upgraded from fold_db_node < 0.5.1, your data may live at the
      literal-tilde path $HOME/~/.folddb/data instead of $HOME/.folddb/data.
      To check / migrate:
        lastdb migrate-tilde-data            # dry-run
        lastdb migrate-tilde-data --apply    # actually move it
      Runbook: https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/tilde-data-migration.md
    EOS
  end

  test do
    assert_match "LastDB CLI", shell_output("#{bin}/lastdb --help")
  end
end
