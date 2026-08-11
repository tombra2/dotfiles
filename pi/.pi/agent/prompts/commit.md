---
name: commit
description: Group the current uncommitted git changes into logically related commits and push them. Use this whenever the user says "commit", "commit my changes", asks to split changes into commits, or wants their working tree committed in sensible groups instead of one big commit. Trigger even if the user just says "commit" with no further detail.
---

# Commit

Splits the current working-tree changes into logically grouped commits (Conventional Commits style), proposes the grouping to the user, then commits and pushes after confirmation.

## Workflow

1. **Inspect state**
   - `git status --porcelain` to list changed/new/deleted files.
   - `git diff` (and `git diff --staged` if anything is already staged) to see actual changes, not just filenames.
   - If there are no changes, say so and stop.

2. **Group by logic, not by file/folder**
   - Read the diffs and cluster changes that belong to the same logical unit of work (e.g. "new endpoint + its test", "refactor of service X", "config change", "unrelated bugfix").
   - A group can span multiple files; a single file can even be split via `git add -p` if it contains unrelated hunks.
   - Do not group purely by directory or file type — group by what the change _does_.

3. **Propose the grouping**
   - Present each proposed group to the user: files/hunks included + a draft Conventional Commit message (`type(scope): summary`, e.g. `feat(auth): add password reset endpoint`).
   - Use types: feat, fix, refactor, test, docs, chore, style, perf, build, ci.
   - Wait for user confirmation or adjustments before committing anything. Keep this proposal concise — a short list, not a long essay.

4. **Commit each group**
   - `git add <specific files/hunks>` for that group only.
   - `git commit -m "<conventional commit message>"`.
   - Repeat per group, in a sensible order (e.g. foundational/refactor changes before features that depend on them).

5. **Push**
   - After all groups are committed, `git push`.
   - If the branch has no upstream, use `git push -u origin <branch>`.
   - Report the final list of commits made (`git log --oneline -n <count>`).

## Notes

- Never invent a grouping the diff doesn't support — if the change is genuinely one unit, one commit is correct; don't force artificial splits.
- If splitting a single file's hunks is needed, use `git add -p` (or `git diff` + targeted staging) rather than committing the whole file to the wrong group.
- If unsure whether two changes belong together, ask the user rather than guessing.
