class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.5.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.5.0/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "f714bc82ae99f9d29087f6318504df5b3c343a5cee1450353ea6bb04d56bd09e"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.5.0/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "3333ddfa73d5a32de7226cc01a76eae412e053c323aee68f70e29762aa89fdda"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.5.0/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "2c34efdd1b4b2b6d1f2a832cd777918dc1c0e5171058e80d1a39ab66d9e8a451"
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
