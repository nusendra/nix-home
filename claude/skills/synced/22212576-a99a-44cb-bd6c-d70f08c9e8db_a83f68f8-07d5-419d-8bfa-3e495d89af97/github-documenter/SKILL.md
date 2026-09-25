---
name: github-documenter
description: >
  Scan all repositories in a GitHub organization, read the latest commits from the past day (or a custom time range),
  and generate a consolidated documentation report. Use this skill whenever the user asks to document GitHub activity,
  summarize recent commits across an org, generate a daily dev log, create a changelog from recent pushes, or produce
  a development activity report for a GitHub organization. Also trigger when the user mentions "GitHub Documenter",
  "org commits", "daily commit report", "repo activity summary", or wants to know what changed across repos recently.
  Trigger even for casual requests like "what did the team push today" or "any updates on our repos".
---

# GitHub Documenter

Generate a consolidated documentation report from recent commit activity across all repositories in a GitHub organization.
Everything runs through the `gh` CLI — no scripts, no tokens, no dependencies beyond `gh`.

## Prerequisites

The `gh` CLI must be installed and authenticated. Verify:

```bash
gh auth status
```

If not ready, tell the user to run `gh auth login`.

## Inputs

1. **GitHub org name** — e.g., `streamlinetechnology-io` (extract from URL if given)
2. **Time range** — defaults to last 24 hours. User may say "last 3 days", "this week", etc.
3. **Output format** — defaults to Markdown. Can produce .docx if requested (use docx skill).

## Workflow

### Step 1: List all repos in the org

```bash
gh repo list <org> --limit 500 --no-archived --json name,description,url,defaultBranchRef,primaryLanguage,isPrivate,pushedAt
```

This returns JSON. Parse the repo names from it.

### Step 2: Fetch recent commits for each repo

Calculate the `since` timestamp based on the requested time range. For example, for the last 24 hours:

```bash
SINCE=$(date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%SZ')
```

Then for each repo:

```bash
gh api "/repos/<org>/<repo>/commits?since=$SINCE&per_page=100" --paginate
```

This returns an array of commit objects. Extract the relevant fields: `sha`, `commit.message`, `commit.author.name`, `commit.author.date`, `author.login`, `html_url`.

If the user wants file-level detail on a specific commit:

```bash
gh api "/repos/<org>/<repo>/commits/<sha>"
```

### Step 3: Generate the report

Collect all the data and produce a Markdown report with this structure:

```markdown
# <Org Name> — Development Activity Report
## Period: <start date/time> to <end date/time>

### Summary
- Repositories scanned: X
- Repositories with activity: Y
- Total commits: Z
- Active contributors: N

---

### Repository: <repo-name>
**Description:** <repo description>
**Language:** <primary language>

| Time (UTC) | Author | SHA | Message |
|------------|--------|-----|---------|
| 2026-04-10 08:32 | @username | `abc1234` | Fix login redirect issue |
| ... | ... | ... | ... |

**Key changes:** <1-2 sentence narrative synthesized from the commit messages>

---

(repeat for each active repo)

### Contributors Summary

| Developer | Commits | Repositories |
|-----------|---------|--------------|
| @user1 | 12 | repo-a, repo-b |
| @user2 | 5 | repo-c |

### Overall Narrative
<A short paragraph synthesizing the day's development activity across the org — what areas saw the most work, any notable patterns, etc.>
```

### Step 4: Save and present

Save the report as `.md` to `/mnt/user-data/outputs/` and present it to the user.
If the user wants `.docx`, use the docx skill to convert.

## Handling Edge Cases

- **No commits found**: State clearly that no activity was detected in the time range and suggest expanding it.
- **Repo access errors (403/404)**: Skip the repo, note it at the bottom of the report under a "Skipped Repositories" section with the reason.
- **Large orgs (100+ repos)**: The `--limit 500` on `gh repo list` handles up to 500 repos. For very large orgs, sort by `pushedAt` and focus on recently-pushed repos first.
- **Empty commit messages**: Show `(no message)` in the table.

## Optional Filters

The user may request these — adjust the gh commands accordingly:

- **Specific repos only**: `--repos repo1,repo2` → only query those repos instead of listing all
- **Specific authors**: After fetching commits, filter by `author.login` or `commit.author.name`
- **Include file changes**: Fetch individual commit details with `gh api /repos/<org>/<repo>/commits/<sha>` and include the `files` array
- **Custom time range**: Adjust the `since` parameter — "this week" = since Monday 00:00 UTC, "last 3 days" = 72 hours ago, etc.
