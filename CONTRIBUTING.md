# How we work

## Git workflow

1. Pick an issue on the GitHub board and assign yourself.
2. Create a branch from `main`: `git switch -c adam/vehicle-movement` (or `neo/...`).
3. Commit small and often. Commit messages in English, imperative: "Add lane ring buffer".
4. Push and open a pull request. Write `Closes #12` in the description.
5. The other person skims it (does it build? do I understand it?) and merges.
6. `main` must always build. Never push broken code directly to `main`.

Tip: run `git pull` on `main` before starting new work to avoid conflicts.

## Authorship (required by the course)

The course requires that it is explicit who wrote which code. Every file starts with:

```c
/* vehicles.c
 *
 * Vehicle movement and lane wrap-around.
 *
 * Written 2026 by Adam Wahren.
 */
```

If a file has code from both of us, mark each function:

```c
/* Written by Neo Carlberg */
void draw_sprite(...)
```

Code taken from the course labs (`boot.S`, `dtekv-lib.c`, ...) keeps its original header.
If you change a lab file, add a comment saying what you changed.

Both of us use our own GitHub account and our own name in `git config`, so the git history
also shows who wrote what.

## Code style

- C99, 2-space or 4-space indentation (pick one and stick to it).
- `snake_case` for functions and variables, `UPPER_CASE` for constants and macros.
- Keep all hardware addresses in one header (e.g. `hw.h`), not as magic numbers spread around.
- No duplicated if-chains: use tables, loops and structs.
- `const` for sprite data so it stays out of RAM writes.
