---
name: debuzz
description: Translate an assistant's previous response (or any pasted text) into plain, direct English using the local OpenCode CLI, with audience modes (colleague/manager/director) controlling how detailed vs. high-level the result is. Use whenever the user invokes /debuzz, asks to "de-buzzfeed" a reply, says "say that in normal english" / "translate that to regular person english", asks for a manager- or exec-friendly version of a reply, or complains that a response sounds hypey, dramatic, listicle-like, or "like buzzfeed".
---

# Debuzz — plain-English translation via OpenCode

The user finds the default assistant register grating: dramatic framing, suspense-building, listicle energy, phrases like "the load-bearing assumption" or "the third one is the most instructive yet." This skill reruns a response through the `opencode2` CLI so they get the same content said like a normal person, at a chosen altitude. The point of using a separate OpenCode invocation (rather than rewriting it yourself) is an independent editor that doesn't share the original's stylistic habits, so do not paraphrase, tidy, or summarize the source text before or after the OpenCode call.

## Arguments

`/debuzz [mode] [text]` — both parts optional.

- **mode**: if the first word of the arguments is `colleague`, `manager`, or `director`, that's the mode. Otherwise the mode is `colleague`.
- **text**: whatever remains after the mode word is the text to translate. If empty, translate your own most recent substantive response — the one immediately before the user invoked the skill. Reproduce it faithfully from the conversation, word for word, including code blocks.

Examples: `/debuzz` (colleague mode, last reply) · `/debuzz director` (exec brief of last reply) · `/debuzz manager <pasted text>`.

## Modes

Every mode shares the same style rules: plain declarative sentences, no dramatic framing, no suspense-building, no buzzy metaphors ("load-bearing assumption", "here's the kicker", "this changes everything"), no reveals, no hype. The modes differ only in audience and altitude:

- **colleague** (default) — a competent engineer explaining it to a peer. Keep every technical fact, number, file path, command, and code block exactly intact. Only the style changes, not the substance; do not shorten beyond what removing fluff removes.
- **manager** — an engineer updating a technical-adjacent manager. Lead with what happened / what was found, why it matters, and what happens next or what's needed. Keep key facts and numbers; drop code blocks, file paths, and implementation mechanics unless one is essential to the point. Target roughly a third of the original length.
- **director** — an executive brief. Three to five sentences: the outcome, the impact or risk in business terms, and any decision or ask. No code, no file paths, no implementation detail. Assume thirty seconds of attention.

## How

1. Write the source text verbatim to a file in the scratchpad directory (e.g. `debuzz-input.md`). Use the Write tool, not shell echo, so quoting can't mangle it.

2. Run OpenCode in non-interactive mode. Attach the source file and compose the prompt from the shared style rules plus the chosen mode's audience instructions. Request JSON output and filter its `text` events so the model banner and other CLI event output are not included. For example, colleague mode:

   ```bash
   opencode2 run --format json --file <scratchpad>/debuzz-input.md "Rewrite the attached text in plain, direct English, as a competent engineer explaining it to a colleague. Remove dramatic framing, suspense-building, hype, and buzzy metaphors (e.g. 'load-bearing assumption', 'here's the kicker', 'the most instructive part', 'this changes everything'). Plain sentences, no reveals. Keep every technical fact, number, file path, command, and code block exactly intact. Only the style changes, not the substance, and do not shorten beyond what removing fluff removes. Output only the rewritten text with no preamble or commentary." | jq -r 'select(.type == "text") | .part.text'
   ```

   For `manager` and `director`, replace the audience sentence and the keep-everything clause with that mode's instructions from the Modes section (audience, what to keep vs. drop, target length), keeping the style-rules sentence and the "output only the rewritten text" closer unchanged.

   Give the command a generous timeout (120s+); the CLI can be slow to first token.

3. Output OpenCode's result to the user **verbatim** as your reply. Do not summarize it, wrap it in your own framing, or add a sign-off, as any text you add reintroduces the voice being removed. A one-line lead like "OpenCode's translation (manager):" is the most you should add.

## If OpenCode fails

If the command errors (authentication, network, rate limit), show the user the actual error and suggest the fix (usually running `opencode2 auth` to check or update authentication). Only offer your own rewrite as a clearly labeled fallback, never silently substitute it, since the user specifically wants a second model's edit.
