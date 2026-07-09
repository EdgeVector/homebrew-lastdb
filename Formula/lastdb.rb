# frozen_string_literal: true

# Homebrew formula for the LastDB release artifacts.
class Lastdb < Formula
  desc "LastDB Mini local-first database daemon"
  homepage "https://thelastdb.com"
  version "0.22.0"
  license "Apache-2.0"

  on_macos do
    # Apple Silicon only (2026-07-05): the release pipeline no longer builds
    # Intel-mac or Linux tarballs. Re-add a block here if a consumer appears.
    url "https://github.com/EdgeVector/homebrew-lastdb/releases/download/v0.22.0/lastdb-aarch64-apple-darwin.tar.gz"
    sha256 "89ecf9aa931f6080618a611ee09f1a00483728fd202942a086c3d1fe6b9d8a7b"
  end


  conflicts_with "edgevector/lastdb/folddb",
                 because: "both formulas install lastdb, lastdbd, and the folddb compatibility command"

  def install
    bin.install "lastdb"
    bin.install "lastdbd"

    # Back-compat: keep the old `folddb` command name working for anyone
    # migrating from `edgevector/folddb/folddb`. The LastDB Mini tarball no longer
    # ships or installs the full-node `*_server` binaries.
    bin.install_symlink "lastdb" => "folddb"
  end

  # `brew services start lastdb` runs LastDB Mini: core DB
  # (schema declare/query/mutate), app-identity, native search, and cloud
  # sync (dormant until `lastdbd connect`) served over the owner Unix socket
  # at ~/.lastdb/data/folddb.sock — no web UI, no ingestion, no discovery.
  # Pin LASTDB_HOME so the LastDB Mini service never falls back to an existing
  # full-node ~/.folddb home on mixed desktop/service machines.
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
      Quickstart (LastDB Mini — the brew-services default):

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

      Inspect LastDB Mini:
           lastdb status
           lastdbd service-home show

      Manual `lastdbd` runs are not service-pinned. On a machine with an
      existing ~/.folddb full-node home, run LastDB Mini and connect
      flow with an explicit LastDB home:
           lastdbd --data-dir ~/.lastdb
           lastdbd --data-dir ~/.lastdb connect
      or set LASTDB_HOME=~/.lastdb before invoking `lastdbd`.

      SAVE your 24-word recovery phrase somewhere safe — it is the ONLY way to
      recover your data on another device.

      The old `folddb` command name still works (symlinked to `lastdb`) for
      back-compat while you migrate.

      If you already have the old `edgevector/folddb/folddb` formula installed,
      uninstall it before installing `lastdb`; both formulas own the same command
      names, so Homebrew cannot link them side-by-side:
           brew uninstall edgevector/folddb/folddb
           brew install edgevector/lastdb/lastdb

      After `brew upgrade lastdb`, the running daemon keeps serving the OLD
      binary — Homebrew does not restart it. Restart it the way you started it:
           brew services restart lastdb                  # if started via `brew services`
      A restart drops in-memory loaded schemas, so app clients (e.g. fbrain,
      fkanban) may need to re-run their `init` afterward.

      Second-device bootstrap (restore from your recovery phrase):
        https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/second-device.md

      This formula intentionally does not ship the full server/UI/ingestion CLI.
      Install LastDB Desktop for the GUI and full-node workflows.
    EOS
  end

  test do
    assert_match "lastdb", shell_output("#{bin}/lastdb --help").downcase
  end
end
