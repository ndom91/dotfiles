---
name: gh-pr-comments
description: Fetch and organize GitHub PR comments for further review and fixing
argument-hint: [pr-number]
---

# PR Comments

Fetch and display comments for a pull request. The goal is for a human to review
all open PR comments (prefering unresolved ones) so that they can decide
whether or not to address or ignore them.

Do not worry about digging deeply into each comment at this point, just find all
comments and organize them in an easily consumable way so that a human can
decide on the next steps.

## Arguments

- `$ARGUMENTS` — PR number (required; ask if not provided)

## Fetch Instructions

Fetch review threads (inline code comments) via GraphQL so resolution status is available. The REST `/pulls/{n}/comments` endpoint does not return `isResolved`, so it cannot be used to filter resolved vs unresolved comments. Replace <repo> below with the name of the repository we want to get comments from. For example, 'support-app' or 'services'. Do not include the GitHub team name.

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          comments(first: 50) {
            nodes {
              databaseId
              author { login }
              createdAt
              body
              url
            }
          }
        }
      }
    }
  }
}' -F owner=team-plain -F repo=<repo> -F pr=$ARGUMENTS
```

Filter to `isResolved == false` threads only.

Then fetch top-level (issue-style) PR conversation comments. These have no thread/resolution concept, so REST is fine here. Replace <org> and <repo> with your current repository:

```bash
gh api repos/<org>/<repo>/issues/$ARGUMENTS/comments

# For example:
# gh api repos/team-plain/support-app/issues/$ARGUMENTS/comments
```

Summarize concisely: author, date, brief excerpt. Group by review thread (keyed on `path:line`) where applicable. Only focus on unresolved review threads plus all issue-level comments.
