class Lastdb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.16.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.16.0/lastdb-aarch64-apple-darwin.tar.gz"
      sha256 "67c1fef5e7adc3f3146cb6b714bc451fbabcaf6bfbe063e33eb9a9eda8f2ceb1"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.16.0/lastdb-x86_64-apple-darwin.tar.gz"
      sha256 "082b889d9f279e255659741eb8476baf4788ff19b49b0b01dcb6c229eb66226d"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.16.0/lastdb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "7c7102311aaaa4568e6ec546c72763f49a4ac4f7a7a458cce6de7b71228c8e96"
    end
  end

  def install
    bin.install "lastdb"
    bin.install "lastdb_server"

    # Back-compat: keep the old `folddb` / `folddb_server` command names working
    # for anyone migrating from `edgevector/folddb/folddb`. The release tarball
    # also ships these binaries, but symlinking keeps a single source of truth.
    bin.install_symlink "lastdb" => "folddb"
    bin.install_symlink "lastdb_server" => "folddb_server"
  end

  service do
    run [opt_bin/"lastdb_server", "--port", "9001"]
    keep_alive true
    run_at_load true
    log_path var/"log/lastdb/lastdb.log"
    error_log_path var/"log/lastdb/lastdb.err.log"
    environment_variables HOME: Dir.home, PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Quickstart:

      1. Start the node — pick ONE (running more than one fights over port 9001):
           lastdb daemon start          # simple; stop with `lastdb daemon stop`
           brew services start lastdb   # background service, restarts at login
           lastdb daemon install        # always-on LaunchAgent. Add --durable to
                                        #   start before login with no keychain prompt
         `lastdb daemon install` stops the others for you, so it's the safe pick
         if you're not sure what's already running.

      2. Finish first-time setup (creates your identity + 24-word recovery phrase):
           lastdb setup                 # or open the dashboard and follow the prompts

      3. Open the dashboard:
           http://localhost:9001

      SAVE your 24-word recovery phrase somewhere safe — it is the ONLY way to
      recover your data on another device. Reprint it any time with:
           lastdb recovery-phrase

      The old `folddb` / `folddb_server` command names still work (symlinked to
      `lastdb` / `lastdb_server`) for back-compat while you migrate.

      After `brew upgrade lastdb`, the running daemon keeps serving the OLD binary
      on port 9001 — Homebrew does not restart it. Restart it the way you started it:
           brew services restart lastdb                  # if started via `brew services`
           lastdb daemon stop && lastdb daemon start     # if started manually
           lastdb daemon install                          # if installed as a LaunchAgent (re-run)
      A restart drops in-memory loaded schemas, so app clients (e.g. fbrain,
      fkanban) may need to re-run their `init` afterward.

      Second-device bootstrap (restore from your recovery phrase):
        https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/second-device.md

      If you upgraded from fold_db_node < 0.5.1, your data may live at the
      literal-tilde path $HOME/~/.folddb/data instead of $HOME/.folddb/data.
      To check / migrate:
        lastdb migrate-tilde-data            # dry-run
        lastdb migrate-tilde-data --apply    # actually move it
      Runbook: https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/tilde-data-migration.md
    EOS
  end

  test do
    assert_match "LastDB CLI", shell_output("#{bin}/lastdb --help")
  end
end
