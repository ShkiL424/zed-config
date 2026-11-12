---
name: land
description: Commit, validate, rebase and fast-forward push this repository's changes to origin/main (no PRs). Use when the user presses Merge, invokes /land, or asks to merge, land or publish changes in zed-config.
metadata:
  delta-action: land
---

# Land changes in zed-config

Goal: get the current work onto `origin/main` as linear, fast-forward history. No pull requests, no merge commits, never force-push.

Report progress and the final result in the language the user is writing in.

## 1. Inspect state

```sh
git status --short --branch
git remote -v
git log --oneline -5
```

- Remote `origin` is GitHub (`ShkiL424/zed-config`, SSH). Remote `local` (if present) is the user's main checkout, e.g. `/Users/shkildima/Projects/zed-config/.git`.
- If there is nothing to commit and `HEAD` already equals `origin/main`, say so and stop.

## 2. Commit

If there are uncommitted changes:

1. Show the user the list of files that will be committed.
2. Never commit ignored or junk files: `.DS_Store`, `*.backup.*`, `*.local.json`, `.env*`, IDE folders. If such files are staged, unstage them and mention it.
3. Stage the intended changes and commit. Message style follows history: a short English title in imperative/title form (e.g. `Configure Unified Diffs and Extension Sorting`, `Add Windows installer for Zed configuration links`), optional body. Add any attribution trailer required by the session's instructions.
4. If the changes are clearly unrelated to each other, you may split them into several commits.

## 3. Validate changed files

Determine changed files with `git diff --name-only origin/main...HEAD` (after committing). Run only the relevant checks:

| Changed files | Check |
| --- | --- |
| `zed/**/*.json` | `python3 .agents/skills/land/scripts/check-jsonc.py <files>` (Zed JSON allows comments and trailing commas) |
| `install.sh` | `bash -n install.sh`; also `shellcheck install.sh` if `shellcheck` is installed |
| `install.ps1` | If `pwsh` is installed: `pwsh -NoProfile -Command '$e=$null; [System.Management.Automation.Language.Parser]::ParseFile("install.ps1",[ref]$null,[ref]$e) > $null; if ($e) { $e; exit 1 }'`. Otherwise report the check as skipped. |
| `install.sh`, `install.ps1`, files added/removed under `zed/` | Check that `README.md` still describes what the installers link and how. Point out mismatches; fix only if obvious, otherwise ask. |

Also check that `install.sh` and `install.ps1` stay consistent with each other (same set of linked files/directories) when either changes.

If any check fails: stop, show the output, do not push.

## 4. Sync with origin/main

```sh
git fetch origin
git rebase origin/main
```

### Conflicts (cautious policy)

Resolve automatically only purely mechanical conflicts where the intended result is unambiguous, for example:
- both sides added different, independent keys/bindings in the same JSON object;
- both sides added different independent lines/sections to `README.md`.

After such a resolution, re-run the step 3 checks on the affected files and tell the user exactly what was merged.

In every other case — the same setting/key/binding changed differently, removed on one side and edited on the other, any conflict in `install.sh`/`install.ps1` logic, or any doubt — stop, show the conflicting hunks with both versions, and ask the user how to resolve. Do not `git rebase --abort` unless the user asks; leave the rebase in progress for them.

## 5. Push

1. Verify push access before publishing: `git ls-remote origin HEAD` (SSH). `gh` is not required; its auth being invalid is not a blocker for pushing.
2. Push fast-forward only:
   ```sh
   git push origin HEAD:main
   ```
   Never use `--force` / `--force-with-lease`. If the push is rejected (remote moved), go back to step 4 once; if it is rejected again or for any other reason, stop and report.

## 6. Update the user's main checkout (if safe)

If remote `local` exists, its path is from `git remote get-url local` (strip the trailing `/.git` to get the working tree). Update it only when it is on `main` and its working tree is clean:

```sh
git -C <checkout> status --porcelain        # must be empty
git -C <checkout> rev-parse --abbrev-ref HEAD   # must be main
git -C <checkout> pull --ff-only origin main
```

Otherwise skip and tell the user why (e.g. it has uncommitted changes) — never stash, reset or overwrite their files.

## 7. Report

Summarize:
- commit hash(es) and titles landed on `origin/main`;
- checks run, passed, skipped (and why);
- any conflicts resolved automatically and how;
- whether the main checkout was updated.

## Never

- Create pull requests or branches on the remote.
- Force-push, rewrite published history, or push to branches other than `main`.
- Change GitHub settings or install tools.
- Discard the user's uncommitted work.
