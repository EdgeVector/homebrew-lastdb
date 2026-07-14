# GitHub is the public tap mirror

**Source of truth:** LastGit `lastdb:///homebrew-lastdb`.

GitHub Actions workflows here are intentionally inert (`workflow_dispatch`
noops). Do not re-enable push/PR CI on GitHub. Agent merge gates run via
`.lastgit/ci.sh` on LastGit, and the mirror job pushes merged `main` back to
GitHub so Homebrew users keep the public tap and release asset URLs.
