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

echo "== registry index invariants =="
for idx in registry/stable.json registry/next.json; do
  [ -f "$idx" ] || { echo "missing $idx" >&2; exit 1; }
  [ -f "$idx.sig" ] || { echo "missing $idx.sig" >&2; exit 1; }
  channel="$(basename "$idx" .json)"
  jq -e --arg c "$channel" '.index_version == 1 and .channel == $c and (.apps | type == "array")' "$idx" >/dev/null     || { echo "$idx: index_version/channel/apps invariant failed" >&2; exit 1; }
  jq -e '.alg == "ed25519" and (.key_id | length == 64) and (.payload_sha256 | length == 64) and (.sig | length > 0)' "$idx.sig" >/dev/null     || { echo "$idx.sig: signature shape invariant failed" >&2; exit 1; }
  digest="$(shasum -a 256 "$idx" | awk '{print $1}')"
  [ "$digest" = "$(jq -r .payload_sha256 "$idx.sig")" ]     || { echo "$idx: bytes do not match the signed digest (re-run last-stack-registry-index sign)" >&2; exit 1; }
  # Every row names a proof record that exists in this tree.
  while IFS= read -r proof; do
    [ -n "$proof" ] || continue
    [ -f "registry/proofs/$proof.json" ] || { echo "$idx: row names proof_run $proof but registry/proofs/$proof.json is missing" >&2; exit 1; }
  done < <(jq -r '.apps[].compat[].proof_run' "$idx" | sort -u)
  # Signature verification needs a lastdb that knows the index; the host lane
  # runs whatever is installed, so verify when it can and say when it cannot.
  if command -v lastdb >/dev/null 2>&1 && lastdb app index verify --help >/dev/null 2>&1; then
    lastdb app index verify --index "$idx"
  else
    echo "note: installed lastdb has no \`app index verify\`; digest checked, signature not verified here"
  fi
done

echo "lastgit ci gate PASSED"
