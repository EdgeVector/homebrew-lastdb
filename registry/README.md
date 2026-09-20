# LastDB app registry index

The anonymous read surface of the LastDB app registry. `lastdb app install
<app>` reads `stable.json`, verifies `stable.json.sig` with the key pinned in
the `lastdb` binary (the same key is `index-signing.pub` here), and installs
the newest app commit that was proved with the LastDB build on your machine.

- `stable.json` — what `brew install lastdb` users draw from. Written by one
  human publish command after a candidate soaked green.
- `next.json` — the nightly candidate channel: rows land after the isolated
  llms-txt install smoke passes on the candidate set. Tom's Mac follows it.
- `proofs/<proof_run>.json` — one record per proof run a row names.

Grammar and rules: fold `docs/lastdb-app-registry-index.md`. No hand-edited
rows: a row exists only because a proof run passed on that exact pair.
