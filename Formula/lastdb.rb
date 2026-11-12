# frozen_string_literal: true

# Homebrew formula for the LastDB release artifacts.
class Lastdb < Formula
  desc "LastDB Mini local-first database daemon"
  homepage "https://thelastdb.com"
  version "0.23.23"
  license "Apache-2.0"

  depends_on "openssl@3"

  on_macos do
    # Apple Silicon only (2026-07-05): the release pipeline no longer builds
    # Intel-mac or Linux tarballs. Re-add a block here if a consumer appears.
    url "https://github.com/EdgeVector/homebrew-lastdb/releases/download/v0.23.23/lastdb-aarch64-apple-darwin.tar.gz"
    sha256 "c57166c5e9f9e70d7968627f4fe9256c1fd9f19195f4ad63fa819ea637101e09"
  end


  conflicts_with "edgevector/lastdb/folddb",
                 because: "both formulas install lastdb, lastdbd, and the folddb compatibility command"

  def install
    bin.install "lastdb"
    bin.install "lastdbd"

    # Back-compat: keep the old `folddb` command name working for anyone
    # migrating from `edgevector/folddb/folddb`. The LastDB Mini tarball no longer
    # ships or installs the full-node `*_server` binaries.
    bin.install_symlink "lastdb" => "folddb"

    # Runtime-resolved homes for `brew services`. Baking Dir.home into the
    # launchd plist freezes whatever HOME the install process had (including
    # ephemeral smoke sandboxes under /tmp/...), so later `brew services start
    # lastdb` points at a dead path. Resolve login HOME + LASTDB_HOME at start.
    (bin/"lastdbd-service").write <<~SH
      #!/bin/bash
      set -euo pipefail
      if real_home="$(dscl . -read "/Users/$(id -un)" NFSHomeDirectory 2>/dev/null | awk '{print $2}')" \
         && [ -n "${real_home}" ]; then
        export HOME="${real_home}"
      elif real_home="$(eval echo "~$(id -un)" 2>/dev/null)" && [ -n "${real_home}" ]; then
        export HOME="${real_home}"
      fi
      export LASTDB_HOME="${LASTDB_HOME:-${HOME}/.lastdb}"
      here="$(cd "$(dirname "$0")" && pwd)"
      exec "${here}/lastdbd" "$@"
    SH
  end

  # `brew services start lastdb` runs LastDB Mini: core DB
  # (schema declare/query/mutate), app-identity, native search, and backup
  # controls served over the owner Unix socket
  # at ~/.lastdb/data/folddb.sock — no web UI, no ingestion, no discovery.
  # LASTDB_HOME is pinned at service *start* by lastdbd-service (not at
  # install time) so the Mini daemon never falls back to an existing full-node
  # ~/.folddb home on mixed desktop/service machines.
  service do
    run [opt_bin/"lastdbd-service"]
    keep_alive true
    run_at_load true
    log_path var/"log/lastdb/lastdbd.log"
    error_log_path var/"log/lastdb/lastdbd.err.log"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Quickstart (LastDB Mini — the brew-services default):

      1. brew services start lastdb
         Runs `lastdbd` via `lastdbd-service`: the headless core database on
         the Unix socket ~/.lastdb/data/folddb.sock. No web UI, no ingestion —
         apps like fbrain and fkanban connect straight to the socket. A fresh
         install generates its identity keyfile on first boot. The service
         wrapper resolves your login HOME at start and pins
         LASTDB_HOME=~/.lastdb so it never attaches to an existing full-node
         ~/.folddb home (and never freezes an install-time sandbox HOME).

      2. Inspect the running service and see the commands for this release:
           lastdb status
           lastdb --help

      To select a home for a manual daemon launch, pass
      `lastdbd --data-dir /absolute/path/to/home`. For Homebrew service
      starts the wrapper uses LASTDB_HOME, with ~/.lastdb as its default.

      Keep your recovery phrase safe. Use the backup and restore help in
      the installed lastdb CLI to prepare recovery credentials and select
      an accepted backup for a fresh destination.

      The old `folddb` command name still works (symlinked to `lastdb`) for
      back-compat while you migrate.

      If you already have the old `edgevector/folddb/folddb` formula installed,
      uninstall it before installing `lastdb`; both formulas own the same command
      names, so Homebrew cannot link them side-by-side:
           brew uninstall edgevector/folddb/folddb
           brew install edgevector/lastdb/lastdb

      After `brew upgrade lastdb`, check the running version with
      `lastdb status`. Follow the release's home compatibility and upgrade
      procedure before restarting the service.

      This formula ships LastDB Mini only: `lastdbd` + `lastdb` over the owner
      Unix socket. There is no React web UI, Tauri desktop app, or full-node
      HTTP server in this bottle — those product surfaces were removed.
    EOS
  end

end
