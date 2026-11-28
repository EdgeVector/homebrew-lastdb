# Back-compat alias of the `lastdb` formula. FoldDB was renamed to LastDB
# (2026-06-20); new installs should use `brew install edgevector/lastdb/lastdb`.
class Folddb < Formula
  desc "LastDB Mini local-first database daemon (renamed to lastdb)"
  homepage "https://thelastdb.com"
  version "0.23.50"
  license "Apache-2.0"

  on_macos do
    # Apple Silicon only (2026-07-05): the release pipeline no longer builds
    # Intel-mac or Linux tarballs. Re-add a block here if a consumer appears.
    url "https://github.com/EdgeVector/homebrew-lastdb/releases/download/v0.23.50/lastdb-aarch64-apple-darwin.tar.gz"
    sha256 "a20458dc35ea613248b24b957d5f0a1704d9605a2a694e93cd62772d22e5992f"
  end

  conflicts_with "edgevector/lastdb/lastdb",
                 because: "both formulas install lastdb, lastdbd, and the folddb compatibility command"

  def install
    bin.install "lastdb"
    bin.install "lastdbd"

    # Back-compat: keep the old `folddb` command name working for anyone
    # migrating from `edgevector/folddb/folddb`.
    bin.install_symlink "lastdb" => "folddb"
  end

  def caveats
    <<~EOS
      Run this once to set LastDB up as a login service:
           lastdb service install

      If LastDB already runs through `brew services`, do not stop it. This
      formula has no service block, so run this once instead. It keeps the
      same job and the same home, and points the job at the self-updating
      copy (the daemon must be running):
           lastdb service adopt --label homebrew.mxcl.lastdb
      After that, do not use `brew services` for LastDB.

      After that, LastDB updates itself. Check for an update, or install one
      now, with:
           lastdb upgrade --check
           lastdb upgrade

      `brew upgrade folddb` only refreshes the installer copy in the Homebrew
      Cellar. It does not restart or replace the running service. Run
      `lastdb status` to see the running version and the upgrade state.

      Keep your recovery phrase safe. Use the backup and restore help in the
      installed lastdb CLI to prepare recovery credentials and select an
      accepted backup for a fresh destination.

      The old `folddb` command name still works (symlinked to `lastdb`).
      If you have the old `edgevector/folddb/folddb` formula installed,
      uninstall it first; both formulas own the same command names:
           brew uninstall edgevector/folddb/folddb
           brew install edgevector/lastdb/lastdb

      This formula ships LastDB Mini only: `lastdbd` + `lastdb` over the owner
      Unix socket. There is no web UI or full-node HTTP server.
    EOS
  end
end
