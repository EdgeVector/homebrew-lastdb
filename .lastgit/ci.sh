#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

for formula in Formula/*.rb; do
  ruby -c "$formula" >/dev/null
done

grep -R "github.com/EdgeVector/homebrew-lastdb/releases" Formula >/dev/null
grep -R "lastdb-aarch64-apple-darwin.tar.gz" Formula/lastdb.rb Formula/folddb.rb >/dev/null
