class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.9.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.0/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "ae5c7ad3e63d69573787fc3972aab25c928b2180edf6a3a10ac91c1cf1339e9d"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.0/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "b3f4d63c2f9c635d27dc9b67bb4a8ee1b47b96e941603225c594e4451cc797fa"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.0/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c86dc2db176d7119c4505b1a5439c6a435389fa14a94c1dc13b6e2f535ee4d23"
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
