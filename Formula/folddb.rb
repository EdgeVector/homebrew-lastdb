class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.9.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.1/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "87fa2d4319d172e8b71667a1e9858f533da308157911547654d2bf5c541185e3"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.1/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "f42fb337193b931bce476e996c5c18bfe31940b41762c8986855b9174f5ba2c1"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.9.1/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "1553609d16eb83928bf684ada75fe9ad237328847328140705e980e269270337"
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
