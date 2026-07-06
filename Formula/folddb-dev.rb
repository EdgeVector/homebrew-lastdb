class FolddbDev < Formula
  desc "Deprecated shim for the retired folddb-dev binary"
  homepage "https://thelastdb.com"
  version "0.3.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-lastdb/releases/download/folddb-dev-v0.3.0/folddb-dev-aarch64-apple-darwin.tar.gz"
      sha256 "7a96c2d017f75c0dc305607d436d6cbed0ee96dd9a608c736c501262421656bd"
    else
      url "https://github.com/EdgeVector/homebrew-lastdb/releases/download/folddb-dev-v0.3.0/folddb-dev-x86_64-apple-darwin.tar.gz"
      sha256 "adf161f57fa10e0ae3a3f08576d1d7c2d96be0825481297769d1dd090848a866"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-lastdb/releases/download/folddb-dev-v0.3.0/folddb-dev-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "493f81019120f062ebafaa39bf5823fdb3d5c623fa228ca4e78d8e9eabfe6a4a"
    end
  end

  def install
    (bin/"folddb-dev").write <<~SH
      #!/bin/sh
      echo 'folddb-dev is now `folddb dev` — brew install edgevector/lastdb/folddb' >&2
      exit 1
    SH
  end

  def caveats
    <<~EOS
      folddb-dev is retired.
      Use `folddb dev` from the main folddb formula:
        brew install edgevector/lastdb/folddb
    EOS
  end

  test do
    assert_match "folddb-dev is now `folddb dev`", shell_output("#{bin}/folddb-dev 2>&1", 1)
  end
end
