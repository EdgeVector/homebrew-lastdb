class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.3.16"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.16/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "a3edeca03e39558768857e7a0d04669b5eb638d1f7e6999e37b45e49ed7d160e"
    else
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.16/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "e708ce7bbbb7c8963f7c1cc3746627779e130cf8d945c8bb2ae7c445f95042cf"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.16/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "eba12a914e154b8f73fd762deff69275d780dd45181f1eba65b4e32964cbf6f3"
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
        https://github.com/EdgeVector/fold_db_node/blob/main/docs/dogfood/second-device.md
    EOS
  end

  test do
    assert_match "FoldDB CLI", shell_output("#{bin}/folddb --help")
  end
end
