class Folddb < Formula
  # Back-compat alias of the `lastdb` formula. FoldDB was renamed to LastDB
  # (rebrand Phase 2, 2026-06-20); this keeps existing
  # `brew install edgevector/folddb/folddb` users working. New installs should
  # prefer `brew install edgevector/lastdb/lastdb`. Both install the same
  # binaries (the release tarball ships `lastdb`/`lastdb_server` and the legacy
  # `folddb`/`folddb_server` names).
  desc "Local-first database for personal data sovereignty (renamed to lastdb)"
  homepage "https://thelastdb.com"
  version "0.20.3"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.20.3/lastdb-aarch64-apple-darwin.tar.gz"
      sha256 "e0e0aa836a51c83101a04bce289aecd6742360c79705c3ca3771bd418b305244"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.20.3/lastdb-x86_64-apple-darwin.tar.gz"
      sha256 "63f45e3cd956bf69e75eccba60722fda31f827456b343b426e8dcd23a428eac7"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.20.3/lastdb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a9ec4a40e0f5604fe4f9dc00bf68fd89b6ed54fe99f1ba67a52401327960ef0d"
    end
  end

  conflicts_with "edgevector/lastdb/lastdb",
                 because: "both formulas install lastdb, lastdb_server, folddb, and folddb_server"

  def install
    # IMPORTANT: install the REAL `lastdb` / `lastdb_server` binaries, not the
    # tiny `folddb*` shims. The release tarball ships both: `folddb*` are
    # back-compat shims that re-exec their same-directory `lastdb*` sibling.
    # Installing the shim as `folddb` and then symlinking `lastdb -> folddb`
    # (the previous, broken layout) made the shim re-exec itself forever — an
    # infinite `exec` loop that hung silently on every invocation, including
    # `folddb --version` (brew 0.15.0/0.16.x headless-start hang). Mirror the
    # `lastdb` formula: install the real binaries, then point the old `folddb*`
    # names at them via symlink.
    bin.install "lastdb"
    bin.install "lastdb_server"

    # Back-compat: keep the old `folddb` / `folddb_server` command names working.
    bin.install_symlink "lastdb" => "folddb"
    bin.install_symlink "lastdb_server" => "folddb_server"
  end

  service do
    run [opt_bin/"folddb_server", "--port", "9001"]
    keep_alive true
    run_at_load true
    log_path var/"log/folddb/folddb.log"
    error_log_path var/"log/folddb/folddb.err.log"
    environment_variables HOME: Dir.home, PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      NOTE: FoldDB has been renamed to LastDB. This `folddb` formula is a
      back-compat alias; new installs should use:
           brew install edgevector/lastdb/lastdb

      Quickstart:

      1. Start the node — pick ONE (running more than one fights over port 9001):
           folddb daemon start          # simple; stop with `folddb daemon stop`
           brew services start folddb   # background service, restarts at login
           folddb daemon install        # always-on LaunchAgent. Add --durable to
                                        #   start before login with no keychain prompt
         `folddb daemon install` stops the others for you, so it's the safe pick
         if you're not sure what's already running.

      2. Finish first-time setup (creates your identity + 24-word recovery phrase):
           folddb setup                 # or open the dashboard and follow the prompts

      3. Open the dashboard:
           http://localhost:9001

      SAVE your 24-word recovery phrase somewhere safe — it is the ONLY way to
      recover your data on another device. Reprint it any time with:
           folddb recovery-phrase

      After `brew upgrade folddb`, the running daemon keeps serving the OLD binary
      on port 9001 — Homebrew does not restart it. Restart it the way you started it:
           brew services restart folddb                  # if started via `brew services`
           folddb daemon stop && folddb daemon start     # if started manually
           folddb daemon install                          # if installed as a LaunchAgent (re-run)
      A restart drops in-memory loaded schemas, so app clients (e.g. fbrain,
      fkanban) may need to re-run their `init` afterward.

      Second-device bootstrap (restore from your recovery phrase):
        https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/second-device.md

      If you upgraded from fold_db_node < 0.5.1, your data may live at the
      literal-tilde path $HOME/~/.folddb/data instead of $HOME/.folddb/data.
      To check / migrate:
        folddb migrate-tilde-data            # dry-run
        folddb migrate-tilde-data --apply    # actually move it
      Runbook: https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/tilde-data-migration.md
    EOS
  end

  test do
    assert_match "LastDB CLI", shell_output("#{bin}/folddb --help")
  end
end
