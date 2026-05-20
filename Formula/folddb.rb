class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.3.17"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.17/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "8fac3c70737a09c1419219a89f4e3f0ee362e75e6b0f7e11138bf07c2b715c7c"
    else
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.17/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "449373ff47bb96142e3985d632683d3412957c765041b80aa3e7540d0181e6be"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/fold_db/releases/download/v0.3.17/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0fbf51650a0107d986f5b323de6ffbdd41b397a123ccf53dfbd0711ae48f0ac0"
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
