# frozen_string_literal: true

# Rendered by last-stack-brew-app-publish from templates/homebrew/loom.rb.tmpl.
# Edit the template in EdgeVector/last-stack, not this file: every release
# rewrites it.
class Loom < Formula
  desc "Loom: durable agent-graph runner for LastDB"
  homepage "https://thelastdb.com"
  version "0.1.1"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/EdgeVector/homebrew-lastdb/releases/download/loom-v0.1.1/loom-aarch64-apple-darwin.tar.gz"
  sha256 "069fcdb3a0e2d893b55281e1f1f774d8f381142a05b7144f299ea4b32ca1c4d9"

  def install
    # Loom finds scripts/ by walking up from its real executable, so the
    # binary, scripts/ and definitions/ keep their artifact layout.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"dist/loom"
  end

  def caveats
    <<~EOS
      Loom needs a running LastDB daemon and the routines app:
        brew install edgevector/lastdb/lastdb && brew services start lastdb
        last-stack-install-apps   # installs routines, kanban and the other apps

      Public graph definitions:
        #{opt_libexec}/definitions
      Publish one with:
        loom publish #{opt_libexec}/definitions/<graph>.json
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/loom --version")
  end
end
