class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.5.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.5.1/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "244bcf1a36934d8bf78aa3ffa629c76aebaa53f7d31ee6775fda1919df714607"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.5.1/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "d753fb9ad73435bf0c05e6eba6e9b6523666ac889c0dd1dbe94a94cf7f71bd13"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.5.1/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "adc274e73a3f6a761a69ff3d17448c7f788cc5e8dae6ba91df1f051eecf17dc6"
    end
  end

  def install
    bin.install "folddb"
    bin.install "folddb_server"
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
