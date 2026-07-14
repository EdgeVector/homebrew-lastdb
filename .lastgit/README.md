# LastGit home - homebrew-lastdb (GitHub = public tap mirror)

| Role | Location |
|------|----------|
| Source of truth / CR / CI / merge | `lastdb:///homebrew-lastdb` |
| Public Homebrew tap + release assets | `https://github.com/EdgeVector/homebrew-lastdb` |

## Workflow

1. Agents open change requests with `lastgit cr` because `.last-stack/pr-venue`
   is `lastgit`.
2. The LastGit forge runs `.lastgit/ci.sh`, writes `ci-required`, and merges
   green CRs.
3. `sync-github-mirror.sh` pushes LastGit `main` to the public GitHub tap so
   `brew tap edgevector/lastdb` and release asset URLs keep working.

GitHub Actions are intentionally inert. Do not merge code on GitHub; use it as
the public clone/browse/install and release-object surface only.
