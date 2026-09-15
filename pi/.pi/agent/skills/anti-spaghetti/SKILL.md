---
name: anti-spaghetti
description: Prevents unnecessary architectural complexity and spaghetti code. Use for every coding, refactoring, architecture, or code-review task, especially when adding a small feature to an existing project.
---

# Anti-spaghetti

The user is often worried that the project is approaching a complexity level where the code becomes spaghetti. Treat that as a request for an investigative architecture review, not as permission to redesign everything.

Keep changes proportional to the problem. Prefer the smallest clear solution that fits the existing architecture.

## Investigative review mode

When the user asks whether the code is spaghetti, investigate before changing anything:

1. Trace the relevant end-to-end flow and list which classes are used and in what order.
2. Inspect dependencies, state transitions, data ownership, duplicated logic, hidden side effects, and error paths.
3. Distinguish actual spaghetti from ordinary indirection. Do not call code spaghetti merely because it has several classes.
4. Give concrete findings with file paths and line numbers, explain the practical consequence, and classify each finding as high, medium, or low priority.
5. Separate confirmed defects from architectural risks and opinions.
6. Recommend incremental improvements in priority order. Explain what should remain unchanged.
7. Run focused tests and static analysis when available. Report their results and their limits.
8. Do not edit files during the investigation unless the user explicitly asks for implementation.

The review must answer:

- Is this spaghetti code, partly, or not currently?
- Where exactly is the complexity or coupling?
- What concrete bug or maintenance cost can it cause?
- What is the smallest improvement?
- What should be postponed to avoid overengineering?

## Mandatory workflow

1. Read the relevant existing classes, tests, routes, configuration, and data flow before proposing code.
2. Trace the complete path of the data being changed. Identify the current source of truth.
3. Search for existing services, interfaces, registries, repositories, DTOs, and helpers before creating new ones.
4. For a small bug or inconsistency, first look for a local fix of roughly a few lines. Do not introduce a new provider, mapper hierarchy, registry, event chain, or abstraction unless the local fix is impossible or clearly unsafe.
5. Explain the smallest viable change first. If larger alternatives exist, label them as optional and do not implement them by default.
6. Never duplicate a data source silently. Decide explicitly whether raw input, a domain entity, or a DTO is authoritative.
7. Do not add a translation layer merely because types differ. Add it only when it prevents a real bug and keep it close to the boundary.
8. Keep controllers thin, but do not move three understandable lines into a new service just to satisfy a slogan.
9. Avoid speculative abstractions for one current implementation. Generalize only when there are at least two real, stable use cases.
10. Preserve existing public behavior unless the user explicitly asks for a redesign.

## Complexity checkpoint

Before editing, state briefly:

- current data source of truth
- smallest files and lines that need changing
- why a new class is or is not needed
- expected test change

If the proposed solution needs more than one new class for a local feature, stop and reconsider.

## Required validation

After editing:

- run the focused tests first
- run static analysis if configured
- add a regression test for the actual failure
- report exactly what was changed and what was not changed

For PHP projects, use DDEV for tests, linters, static analysis, Composer, Symfony, and other project commands. Never use host PHP or vendor executables.

## Communication rule

Do not overwhelm the user with a framework redesign. If a three-line fix is sufficient, show that first. Ask before implementing a larger refactor.
