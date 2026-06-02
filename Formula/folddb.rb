class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.7.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.7.1/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "e7c9ed6ef2429a43da6d6a85f4c18343e8d17dc9fe2f8abaedfdb664db08d15b"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.7.1/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "aea13a6aa6826068f7fbd9e5372792f723000bd6add06a1c5f29a32a06f4181d"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.7.1/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "3b9d940d282d3b1378129f785abf103cb6856a231988a87199da90cccdbfe02a"
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
