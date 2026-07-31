---
name: gh-tests
description: Fetch and analyze any failing tests / actions on your GitHub pull request
compatibility: Requires the GitHub CLI - `gh` ('brew install gh')
---

# GitHub Test Results

## Instructions

Your goal is to retrieve and organize all failing CI workflows so that a human
user can decide which to address. Follow these steps:

1. Use the `gh` CLI to pull up the latest CI results. Replace `<branchName>` with the current branch name.

```bash
gh pr checks <branchName> --json name,state,conclusion,detailsUrl,workflow
```

2. Organize the failures into groups based on the CI job in which they occurred.

```bash
gh pr checks <branchName> --json name,state,conclusion,detailsUrl,workflow --jq '.[] | select(.conclusion == "failure" or .state == "FAILURE")'
gh run list --branch <branchName> --limit 3 --json databaseId,name,conclusion,status --jq '.[] | select(.conclusion == "failure")'
```

To inspect a failed run, NEVER dump the full log. Use `--log-failed` and slice to error context only — full logs are thousands of lines and burn tokens:

```bash
gh run view <run-id> --log-failed | grep -iE 'error|fail|✕|✗|assert' -A3
gh run view <run-id> --log-failed | tail -100
```

3. If a certain CI job has many failures, like Integration Tests, group failures by suspected cause.

```bash
gh run view <run-id> --json jobs --jq '.jobs[] | select(.conclusion == "failure") | {name, databaseId}'
gh run view --job <job-id> --log-failed | grep -iE 'error|fail|✕|✗|assert' -A3
```

Finally, give the user a very brief summary of all open failures so that they
may decide how to continue and which failures to address first.
