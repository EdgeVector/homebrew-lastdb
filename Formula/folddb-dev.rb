class FolddbDev < Formula
  desc "FoldDB developer node — local dev/test node for building FoldDB apps"
  homepage "https://thelastdb.com"
  version "0.3.0"

  # Assets live on this repo's `folddb-dev-v*` mirror releases (the source
  # repo, EdgeVector/fold_dev_node, is private — its release job mirrors the
  # tarballs here; see that repo's .github/workflows/release.yml).
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
    bin.install "folddb-dev"
  end

  def caveats
    <<~EOS
      folddb-dev is the FoldDB developer node (dev/test tool — not the
      end-user FoldDB daemon; that's `brew install edgevector/folddb/folddb`).

      Start here:
        folddb-dev --help
        https://github.com/EdgeVector/homebrew-lastdb/releases/download/folddb-dev-v#{version}/developer-onboarding.md

      Publishing apps/schemas needs an Exemem dev API key (invite-only
      during the alpha) — see the onboarding doc for how to request one.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/folddb-dev --version")
  end
end
