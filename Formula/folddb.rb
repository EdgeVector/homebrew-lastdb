class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.3.15"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.15/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "fd170108c8a67aeb137e2d39e3c14b8307052e538ce724cadcfc3d24c8bd2911"
    else
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.15/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "faa0377988e5b91d1026d22f4c95b7a2def7142f520490d2ae4c77d349b9f0d9"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.15/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "67d3eb1dfdd0dd9c0b96d5b93e5bc648e3fdc9cb83d3148dca97a2a0d04803d5"
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
