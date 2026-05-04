class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.3.18"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.18/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "16f2a17d9a392101561efc1e6cfb8c73b210e90657b2dcfff02cd3a2a097ab66"
    else
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.18/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "4962d239bee32b231b2c88058f1053a35f3bd20a9790dae8ff15d1d1fbdde6f0"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.18/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "b480153a307b0fd88d0c2795b47e9453d1aeee2aeb618c1d380b4f5f15dfbc09"
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
