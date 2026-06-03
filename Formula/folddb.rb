class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.8.2"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.8.2/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "cd910c7d6176a84d267d11855445ce5faf9c396f2e11844a53033d40b611194e"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.8.2/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "3279dbabca9baa97c220a5066a803a5ba3aae73a8aad57e82add094da76636ae"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.8.2/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "4dc49afc1e159cdbe33e6a26b75ab1ee4195aa005fb58551e7be04192e310d3d"
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

      After `brew upgrade folddb`, restart the daemon to run the new version
      (otherwise the old daemon keeps serving on port 9001):
        folddb daemon stop && folddb daemon start

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
