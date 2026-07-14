#!/usr/bin/env bash
# LastGit merge gate for the public LastDB Homebrew tap.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== shell syntax =="
for f in .lastgit/*.sh; do
  [ -e "$f" ] || continue
  echo "bash -n $f"
  bash -n "$f"
done

echo "== formula syntax =="
for f in Formula/*.rb; do
  [ -e "$f" ] || continue
  echo "ruby -c $f"
  ruby -c "$f"
done

echo "== public tap asset invariants =="
grep -R "github.com/EdgeVector/homebrew-lastdb/releases" Formula >/dev/null
grep -R "lastdb-aarch64-apple-darwin.tar.gz" Formula/lastdb.rb Formula/folddb.rb >/dev/null

echo "lastgit ci gate PASSED"
