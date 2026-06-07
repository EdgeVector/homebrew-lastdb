class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.9.2"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.2/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "3078e6223095da6f736bb1f4b31513378532220333740c038e3a6a822ed6596f"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.2/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "4418b8b85916d430f2c08d46829c78c80bbcced57e377d7499f2c27ae4b6ff3b"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.2/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "5fe5d5c410587b0efad24d1f226a55301de1e482fe7e16108e259815c2e9b724"
    end
  end

  def install
    bin.install "folddb"
    bin.install "folddb_server"
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
      To start the FoldDB daemon:
        folddb daemon start

      Then open the dashboard at:
        http://localhost:9001

      After `brew upgrade folddb`, the already-running daemon keeps serving the
      OLD binary on port 9001 — Homebrew does not restart it for you. Restart
      it so the new version takes effect:

        brew services restart folddb                  # if started via `brew services`
        folddb daemon stop && folddb daemon start     # if you run it manually

      A restart drops the daemon's in-memory loaded schemas, so app clients
      (e.g. fbrain, fkanban) may need to re-run their `init` afterward.

      Second-device bootstrap (restore from BIP39 recovery phrase):
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
    assert_match "FoldDB CLI", shell_output("#{bin}/folddb --help")
  end
end
