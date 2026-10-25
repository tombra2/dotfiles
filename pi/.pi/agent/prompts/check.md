---
name: upn-check
description: Runs "mpu" (linter, formatter, tests for the codebase). Use when the user asks for linting, formatting, or tests on their project, or mentions "mpu".
---

# mpu

Global alias that runs the linter, formatter, and tests for the codebase.

​`bash
mpu
​`

Always run the script without hesitation, regardless of the status.
On failure: parse the output, name the affected files/lines, propose fixes before applying them.
