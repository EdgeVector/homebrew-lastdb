class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.4.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.4.0/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "0b2d49d12b232bf208f2c08c93d01a63550d95555cd277e96407d27a9e6313a8"
    else
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.4.0/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "1357f87136c0150917bc0f44b5a90fb36de61ac421a6c0410c1fb03f688bc0fd"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.4.0/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "6c3824d1e2e0918cafe0f63d0d600ce3a0d65951963f5bf4cdddb9483cd09dd1"
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
    EOS
  end

  test do
    assert_match "FoldDB CLI", shell_output("#{bin}/folddb --help")
  end
end
