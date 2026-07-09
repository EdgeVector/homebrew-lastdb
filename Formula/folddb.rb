class Folddb < Formula
  # Back-compat alias of the `lastdb` formula. FoldDB was renamed to LastDB
  # (rebrand Phase 2, 2026-06-20); this keeps existing
  # `brew install edgevector/folddb/folddb` users working. New installs should
  # prefer `brew install edgevector/lastdb/lastdb`. Both install the same
  # LastDB Mini daemon + tiny control CLI.
  desc "LastDB Mini local-first database daemon (renamed to lastdb)"
  homepage "https://thelastdb.com"
  version "0.22.0"
  license "Apache-2.0"

  on_macos do
    # Apple Silicon only (2026-07-05): the release pipeline no longer builds
    # Intel-mac or Linux tarballs. Re-add a block here if a consumer appears.
    url "https://github.com/EdgeVector/homebrew-lastdb/releases/download/v0.22.0/lastdb-aarch64-apple-darwin.tar.gz"
    sha256 "89ecf9aa931f6080618a611ee09f1a00483728fd202942a086c3d1fe6b9d8a7b"
  end


  conflicts_with "edgevector/lastdb/lastdb",
                 because: "both formulas install lastdb, lastdbd, and folddb"

  def install
    # Install the canonical tiny `lastdb` control CLI and daemon, then keep the
    # old `folddb` command name as a compatibility symlink. The LastDB Mini tarball
    # no longer ships or installs the full-node `*_server` binaries.
    bin.install "lastdb"
    bin.install "lastdbd"

    bin.install_symlink "lastdb" => "folddb"
  end

  service do
    run [opt_bin/"lastdbd"]
    keep_alive true
    run_at_load true
    log_path var/"log/folddb/lastdbd.log"
    error_log_path var/"log/folddb/lastdbd.err.log"
    environment_variables HOME:        Dir.home,
                          LASTDB_HOME: "#{Dir.home}/.lastdb",
                          PATH:        std_service_path_env
  end

  def caveats
    <<~EOS
      NOTE: FoldDB has been renamed to LastDB. This `folddb` formula is a
      back-compat alias; new installs should use:
           brew install edgevector/lastdb/lastdb

      Quickstart (LastDB Mini):

      1. Start the daemon:
           brew services start folddb

      2. Inspect it:
           folddb status

      3. Join an existing LastDB account as a second device:
           lastdbd connect              # paste your 24-word recovery phrase
           brew services restart folddb # first boot pulls your data

      SAVE your 24-word recovery phrase somewhere safe — it is the ONLY way to
      recover your data on another device.

      After `brew upgrade folddb`, the running daemon keeps serving the OLD
      binary — Homebrew does not restart it. Restart it the way you started it:
           brew services restart folddb                  # if started via `brew services`
      A restart drops in-memory loaded schemas, so app clients (e.g. fbrain,
      fkanban) may need to re-run their `init` afterward.

      Second-device bootstrap (restore from your recovery phrase):
        https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/second-device.md

      This formula intentionally does not ship the full server/UI/ingestion CLI.
      Install LastDB Desktop for the GUI and full-node workflows.
    EOS
  end

  test do
    assert_match "lastdb", shell_output("#{bin}/folddb --help").downcase
  end
end
