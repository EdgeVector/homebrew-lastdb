class Folddb < Formula
  desc "Local-first database for personal data sovereignty"
  homepage "https://folddb.com"
  version "0.13.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.13.0/folddb-aarch64-apple-darwin.tar.gz"
      sha256 "828376b20839557df197d242903483185aa21005e85da36feb2e86ef32e403e7"
    else
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.13.0/folddb-x86_64-apple-darwin.tar.gz"
      sha256 "cd905fba6963a57a812ba801e96fd8d23da3437d1b609a92b06ee0177fd0be91"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/EdgeVector/homebrew-folddb/releases/download/v0.13.0/folddb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "debd70424fb9d14ad024ec21d7a3d1f76f9e60868aedf7ee6f0b5c3b8046c6de"
    end
  end

  def install
    bin.install "folddb"
    bin.install "folddb_server"
  end

  service do
    run [opt_bin/"folddb_server", "--port", "9001"]
    keep_alive true
    run_at_load true
    log_path var/"log/folddb/folddb.log"
    error_log_path var/"log/folddb/folddb.err.log"
    environment_variables HOME: Dir.home, PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Quickstart:

      1. Start the node — pick ONE (running more than one fights over port 9001):
           folddb daemon start          # simple; stop with `folddb daemon stop`
           brew services start folddb   # background service, restarts at login
           folddb daemon install        # always-on LaunchAgent. Add --durable to
                                        #   start before login with no keychain prompt
         `folddb daemon install` stops the others for you, so it's the safe pick
         if you're not sure what's already running.

      2. Finish first-time setup (creates your identity + 24-word recovery phrase):
           folddb setup                 # or open the dashboard and follow the prompts

      3. Open the dashboard:
           http://localhost:9001

      SAVE your 24-word recovery phrase somewhere safe — it is the ONLY way to
      recover your data on another device. Reprint it any time with:
           folddb recovery-phrase

      After `brew upgrade folddb`, the running daemon keeps serving the OLD binary
      on port 9001 — Homebrew does not restart it. Restart it the way you started it:
           brew services restart folddb                  # if started via `brew services`
           folddb daemon stop && folddb daemon start     # if started manually
           folddb daemon install                          # if installed as a LaunchAgent (re-run)
      A restart drops in-memory loaded schemas, so app clients (e.g. fbrain,
      fkanban) may need to re-run their `init` afterward.

      Second-device bootstrap (restore from your recovery phrase):
        https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/second-device.md

      If you upgraded from fold_db_node < 0.5.1, your data may live at the
      literal-tilde path $HOME/~/.folddb/data instead of $HOME/.folddb/data.
      To check / migrate:
        folddb migrate-tilde-data            # dry-run
        folddb migrate-tilde-data --apply    # actually move it
      Runbook: https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/tilde-data-migration.md
    EOS
  end

  test do
    assert_match "FoldDB CLI", shell_output("#{bin}/folddb --help")
  end
end
