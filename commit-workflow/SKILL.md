---
name: commit-workflow
description: Plan and execute safe, reviewable Git commits with an explicit approval gate. Use whenever the user asks to commit, stage for commit, amend, split, squash, reword, reorganize, or otherwise change Git commit history.
---

# Commit Workflow

Create understandable Git history while preserving the user's work. Organize commits by logical responsibility, follow repository conventions, and obtain explicit approval before changing the index or history.

## Non-Negotiable Approval Gate

When the user asks to commit, the initial request authorizes planning only. It does not authorize staging or committing.

Before any write operation:

1. Inspect the repository using read-only commands.
2. Present the exact proposed commit plan.
3. State the verification commands you intend to run.
4. Ask: **“May I proceed with this commit plan?”**
5. Wait for explicit approval.

Before approval, do not run commands that change the index, commits, branches, tags, or history, including `git add`, `git commit`, `git reset`, `git restore --staged`, `git rebase`, or `git cherry-pick`.

If the plan changes materially after approval, stop, present the revised plan, and ask again. Approval of one plan does not authorize a different plan.

## Read-Only Inspection

Inspect enough context to make a reliable plan. Common commands include:

```bash
git status --short --branch
git diff --stat
git diff
git diff --cached --stat
git diff --cached
git log --oneline -10
```

Also:

- Read repository instructions such as `AGENTS.md`, `CONTRIBUTING.md`, or equivalent files.
- Inspect untracked files that may belong to the change.
- Identify pre-existing staged work, unrelated edits, generated files, and likely secrets.
- Determine appropriate validation from project scripts, documentation, and changed areas.
- Preserve user changes. Never discard, overwrite, unstage, or absorb unrelated work without permission.

If there are no changes to commit, say so instead of creating an empty commit unless the user explicitly requests one.

## Plan by Logical Responsibility

A commit should represent one coherent change that a reviewer can understand and revert.

Prefer separate commits for independently meaningful concerns, such as:

- A reusable component or shared API capability followed by the feature that consumes it.
- A behavior-preserving refactor followed by a behavior change.
- Independent fixes or features that could be reverted separately.
- Standalone build, CI, dependency, documentation, or tooling changes.

Dependent commits are acceptable when they are ordered clearly. Foundational changes should precede consumers. Every commit should leave the repository in a valid state and should pass the checks relevant to that point in history.

Keep tightly coupled work together when the pieces have no useful independent purpose. A feature's implementation, types, tests, migrations, generated artifacts, and directly required documentation often belong together. Do not create microcommits merely because files live in different directories or architectural layers.

Use these tests when deciding whether to split:

- **Purpose:** Does each commit have a distinct reason to exist?
- **Validity:** Does each commit build and behave coherently on its own?
- **Reviewability:** Can a reviewer understand it without mentally applying later commits?
- **Revertability:** Could it reasonably be reverted independently?
- **Reuse:** Is a foundational change an intentional reusable capability rather than incidental plumbing?

## Commit Message Convention

Follow explicit user instructions and repository history first. When no stronger local convention exists, use Conventional Commits:

```text
<type>(<scope>): <imperative summary>
```

Common types:

- `feat`: new capability or behavior
- `fix`: bug correction
- `refactor`: behavior-preserving restructuring
- `perf`: performance improvement
- `test`: test-only change
- `docs`: documentation-only change
- `build`: build system or dependency change
- `ci`: continuous-integration change
- `chore`: maintenance not covered above
- `style`: formatting-only change
- `revert`: revert of an earlier commit

Choose a narrow, stable scope representing the domain or shared subsystem. Keep the subject concise and imperative, with no trailing period. Add a short body when the motivation, tradeoff, or relationship to other commits is not obvious. Use `!` and a `BREAKING CHANGE:` footer for breaking changes.

## Required Plan Format

Present an ordered plan before asking for approval:

```text
Proposed commit plan:

1. feat(ui): support disabled action state
   - Intent: provide reusable interaction and accessibility behavior.
   - Changes: shared action component and its focused tests.

2. feat(profile): add avatar picker
   - Intent: let users select and explicitly save an avatar.
   - Changes: picker UI, routing, data options, and persistence.

Verification:
- <project-appropriate command>
- <project-appropriate command>

Excluded:
- <unrelated or pre-existing changes, if any>

May I proceed with this commit plan?
```

For a single commit, still explain why the changes form one atomic unit and ask for approval.

## Execute Only After Approval

After explicit approval:

1. Run the approved validation, unless the plan intentionally schedules checks later.
2. Stop and report unexpected failures; do not silently weaken checks or use `--no-verify`.
3. Stage only the files or hunks belonging to the next commit. Prefer explicit paths or precise hunks over `git add .`.
4. Review the staged result with `git diff --cached --check`, `git diff --cached --stat`, and the full cached diff when needed.
5. Confirm that no unrelated, generated, secret, or user-owned changes slipped in.
6. Commit with the approved message.
7. Inspect the result and repeat for each commit in dependency order.
8. Run final validation when appropriate.
9. Report commit hashes, subjects, checks, remaining changes, and whether the working tree is clean.

If a commit hook fails or modifies files, inspect and report the result. Do not bypass hooks without explicit permission.

## History Rewrites and Remote Operations

Treat amend, reset, rebase, squash, reword, and similar operations as history rewrites. The plan must identify the commits affected and whether they appear published. Never rewrite shared or published history without explicit approval that specifically covers the rewrite and its consequences.

Do not push, force-push, create tags, or open a pull request unless the user separately requests it. A request to commit authorizes none of those operations.
