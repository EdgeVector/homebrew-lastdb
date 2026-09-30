# homebrew-lastdb CI notes

The gate of record is GitHub (`EdgeVector/homebrew-lastdb`). The required check
is the `ci-required` job in `.github/workflows/ci-required.yml`. That job needs
`tap-checks`, which runs `bash .lastgit/ci.sh`.

The old LastGit-to-GitHub mirror scripts were removed on 2026-09-30. The LastGit
and Forgejo copies are frozen.
