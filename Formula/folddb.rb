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

  service do
    run [opt_bin/"folddb_server", "--port", "9001"]
    keep_alive true
    run_at_load true
    log_path var/"log/folddb/folddb.log"
    error_log_path var/"log/folddb/folddb.err.log"
    # Pin cwd to $HOME as a workaround for a fold_db_node tilde-expansion bug:
    # the daemon takes `database.path: "~/.folddb/data"` literally and joins it
    # to cwd, so existing dogfooders' data lives under $HOME/~/.folddb/data.
    # Remove this line + comment once EdgeVector/fold kanban task 1dcda ships
    # in a folddb release.
    working_dir Dir.home
    environment_variables HOME: Dir.home, PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      To start FoldDB as a background service that auto-restarts on login:
        brew services start folddb

      Or run it once in the foreground for ad-hoc / debugging:
        folddb daemon start

      Either way, the web UI is at http://localhost:9001 once the daemon is up.
      First-time setup (registering your node identity, optional cloud backup)
      runs in the web UI — until you complete it, the daemon is up but won't
      have an identity and the CLI won't work. Pass --no-open to `folddb daemon
      start` to skip the browser open (e.g. on a headless box).

      If you previously hand-rolled a LaunchAgent for folddb_server, stop it
      first so port 9001 is free before `brew services start folddb`:
        launchctl bootout "gui/$(id -u)/<your.label>"
        rm ~/Library/LaunchAgents/<your.label>.plist

      Second-device bootstrap (restore from BIP39 recovery phrase):
        https://github.com/EdgeVector/fold/blob/main/fold_db_node/docs/dogfood/second-device.md
    EOS
  end

  test do
    assert_match "FoldDB CLI", shell_output("#{bin}/folddb --help")
  end
end
