class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.8.3"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.8.3/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "cd4026975a570e13fe961c72bd6e3f815647da38d71b3c9b655d0281198eb1cf"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.8.3/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "dd46765f797d88e6433f65289d7358908796280eca06c27900a038a7afc10355"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.8.3/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "203f7940e7064948dfde6f623ea171fb4fa41c38422e46dc58ec72dfdc28f725"
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
