---
name: land
description: Commit, validate, rebase and fast-forward this repository's changes into the user's local main checkout (never pushes to origin, no PRs). Use when the user presses Merge, invokes /land, or asks to merge or land changes in zed-config.
metadata:
  delta-action: land
---

# Land changes in zed-config

Goal: get the current work onto the **local** `main` branch of the user's main checkout as linear, fast-forward history. No pull requests, no merge commits. **Never push to `origin`** (or anywhere else) — the user pushes to GitHub themselves.

Report progress and the final result in the language the user is writing in.

## 1. Inspect state

```sh
git status --short --branch
git remote -v
git log --oneline -5
```

- Remote `local` is the user's main checkout, e.g. `/Users/shkildima/Projects/zed-config/.git`; its working tree is `git remote get-url local` without the trailing `/.git`. This is the landing target. If `local` is missing, ask the user for the path of the main checkout — don't guess.
- Remote `origin` is GitHub. Do not push to it; there is no need to fetch it either.
- If there is nothing to commit and `HEAD` already equals `local/main` (after `git fetch local main`), say so and stop.

## 2. Commit

If there are uncommitted changes:

1. Show the user the list of files that will be committed.
2. Never commit ignored or junk files: `.DS_Store`, `*.backup.*`, `*.local.json`, `.env*`, IDE folders. If such files are staged, unstage them and mention it.
3. Stage the intended changes and commit. Message style follows history: a short English title in imperative/title form (e.g. `Configure Unified Diffs and Extension Sorting`, `Add Windows installer for Zed configuration links`), optional body. Add any attribution trailer required by the session's instructions.
4. If the changes are clearly unrelated to each other, you may split them into several commits.

## 3. Validate changed files

Determine changed files with `git diff --name-only local/main...HEAD` (after committing). Run only the relevant checks:

| Changed files | Check |
| --- | --- |
| `zed/**/*.json` | `python3 .agents/skills/land/scripts/check-jsonc.py <files>` (Zed JSON allows comments and trailing commas) |
| `install.sh` | `bash -n install.sh`; also `shellcheck install.sh` if `shellcheck` is installed |
| `install.ps1` | If `pwsh` is installed: `pwsh -NoProfile -Command '$e=$null; [System.Management.Automation.Language.Parser]::ParseFile("install.ps1",[ref]$null,[ref]$e) > $null; if ($e) { $e; exit 1 }'`. Otherwise report the check as skipped. |
| `install.sh`, `install.ps1`, files added/removed under `zed/` | Check that `README.md` still describes what the installers link and how. Point out mismatches; fix only if obvious, otherwise ask. |

Also check that `install.sh` and `install.ps1` stay consistent with each other (same set of linked files/directories) when either changes.

If any check fails: stop, show the output, do not land.

## 4. Sync with local main

```sh
git fetch local main
git rebase local/main
```

### Conflicts (cautious policy)

Resolve automatically only purely mechanical conflicts where the intended result is unambiguous, for example:
- both sides added different, independent keys/bindings in the same JSON object;
- both sides added different independent lines/sections to `README.md`.

After such a resolution, re-run the step 3 checks on the affected files and tell the user exactly what was merged.

In every other case — the same setting/key/binding changed differently, removed on one side and edited on the other, any conflict in `install.sh`/`install.ps1` logic, or any doubt — stop, show the conflicting hunks with both versions, and ask the user how to resolve. Do not `git rebase --abort` unless the user asks; leave the rebase in progress for them.

## 5. Fast-forward the local `main`

The main checkout pulls the commits from this repository; nothing is pushed anywhere. Let `<checkout>` be the main checkout's working tree and `<here>` be `git rev-parse --absolute-git-dir` of the current repository.

- If `<checkout>` is on `main` (`git -C <checkout> rev-parse --abbrev-ref HEAD`):
  ```sh
  git -C <checkout> fetch <here> HEAD
  git -C <checkout> merge --ff-only FETCH_HEAD
  ```
  Uncommitted changes in the checkout are fine as long as git accepts the merge. If git refuses (local changes would be overwritten, or not a fast-forward), stop and report — never stash, reset, checkout or overwrite the user's files.
- Otherwise (another branch is checked out there), update the branch ref without touching the working tree; git only allows a fast-forward here:
  ```sh
  git -C <checkout> fetch <here> HEAD:main
  ```

If the update is rejected because local `main` moved, go back to step 4 once; if it is rejected again or for any other reason, stop and report.

Afterwards confirm with `git -C <checkout> log --oneline -5 main`.

## 6. Report

Summarize:
- commit hash(es) and titles landed on local `main`;
- checks run, passed, skipped (and why);
- any conflicts resolved automatically and how;
- that nothing was pushed to `origin` — the user pushes themselves.

## Never

- Run `git push` — not to `origin`, not to `local`, not anywhere.
- Create pull requests or remote branches.
- Update local `main` with anything but a fast-forward; never reset or force-update it.
- Change GitHub settings or install tools.
- Discard the user's uncommitted work.
