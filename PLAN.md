# Project plan: endless road-crossing game on DTEK-V

Group 67, Adam Wahren and Neo Carlberg.

Source documents: the course *Mini project* instructions and our draft extended abstract.
Each milestone below is also a GitHub milestone, and each bullet is (or becomes) an issue.

## What we must deliver

| Deliverable | Where / how | Deadline |
|---|---|---|
| Draft extended abstract (PDF, names + personnummer) | Canvas, one of us submits | done ✅ |
| Working game on the DTEK-V board | Shown at the EXPO | EXPO (fill in date) |
| Performance analysis report, 2 pages (needed for grade A/B) | Canvas | **before** the EXPO |
| Final extended abstract (past tense, no "we will…") | Bring printed to the EXPO | EXPO |
| Source code as `.zip` + `readme.txt` (how to build and run) | Project code upload | EXPO |
| 5-minute demo where **both** of us talk | At the EXPO | EXPO |

Course rules that affect how we work:

- Every source file and function must say who wrote it (see `CONTRIBUTING.md`).
- Roughly 50/50 of the actual coding each. No "one codes, one writes".
- C (or ASM) with the course toolchain only.
- No copy-pasted, duplicated code: use loops, tables and structs.
- We must be able to explain every line of code and every sentence of the report orally.

## Requirements (from the draft abstract)

Must have:

1. Endless world of lanes, generated as the player moves forward.
2. Score shown on the 7-segment displays.
3. Player controlled from the board (button for forward jump, switches for the other directions).
4. Collision with vehicles and with the bottom edge of the screen ends the game.
5. Restart after a loss.
6. Moving back and forth must not give extra points (score = furthest row reached).

Nice to have, only once all must-haves work:

- Other lane types: rivers with logs, forests with trees, train tracks.
- High-score list kept between games (in RAM while the board is powered).
- Difficulty levels that change vehicle speed.

## Architecture

A suggested split, to grow into bit by bit (none of these files exist yet).
Flat file layout so the course Makefile keeps working (it compiles every `.c`/`.S` in the project root).

| File | Responsibility | Owner |
|---|---|---|
| `main.c` | Init, main loop, game state machine (MENU → PLAYING → GAME_OVER) | both |
| `hw.c/.h` | All memory-mapped I/O addresses, timer setup, interrupt enable | both |
| `input.c/.h` | Read button + switches, edge detection (one jump per press) | Adam |
| `player.c/.h` | Player position on the grid, jumps, bounds checks | Adam |
| `vehicles.c/.h` | Vehicles per lane, movement, wrap-around | Adam |
| `collision.c/.h` | Player vs vehicle, player vs bottom edge | Adam |
| `score.c/.h` | Score logic, "furthest row" rule, 7-segment output | Adam |
| `gfx.c/.h` | VGA framebuffer, clear, fill rectangle, blit sprite, double buffering | Neo |
| `sprites.c/.h` | Pixel data for frog, cars, road, grass (as `const` arrays) | Neo |
| `camera.c/.h` | Scrolling: which world rows are on screen, world → screen coordinates | Neo |
| `render.c/.h` | Draws lanes, vehicles and player from the world state; game-over screen | Neo |
| `world.c/.h` | Lane ring buffer, pseudo-random lane generation | both |
| `perf.c/.h` | Read hardware performance counters (CSRs) for the report | both |

Key design decisions to agree on early (day 1, write them in `hw.h` / `world.h`):

- **Grid**: world is a grid of tiles, e.g. 16×16 px → 20 columns × 15 rows on 320×240.
- **Lanes**: a ring buffer of N lane structs (`type`, `direction`, `speed`, vehicle positions). When the camera moves past the top, the oldest lane is overwritten by a new random one. This makes the world endless with fixed memory.
- **Random**: a small xorshift/LCG PRNG with a seed (seed from the timer at start). A fixed seed is also needed for repeatable performance measurements.
- **Timing**: the hardware timer interrupt sets a `tick` flag (e.g. 30–60 Hz). The main loop does `input → update → render` once per tick. Keep the interrupt handler tiny.
- **Rendering**: start with full redraw each frame using filled rectangles; switch to sprites once that works. If it flickers, draw to a back buffer and swap.

## Milestones

Dates are relative; adjust once we know the EXPO date. Weekly sync meeting: pick a fixed day.

### M0 – Setup (this week)
- [ ] Both have the repo cloned and can build on their machine or the KTH computers (both)
- [ ] Agree on `hw.h` addresses and coding conventions (both)
- [ ] Confirm VGA works: borrow/buy VGA→HDMI adapter if needed (Neo)

### M1 – Hardware bring-up (week 1–2)
- [ ] Timer interrupt at a fixed frame rate, toggling an LED to prove it runs (Adam)
- [ ] Read button and switches with edge detection (Adam)
- [ ] Write a number to the 7-segment displays (Adam)
- [ ] Draw a filled rectangle and clear the screen over VGA (Neo)
- [ ] Draw a sprite from a `const` array (Neo)

### M2 – Playable core / MVP (week 2–4)
- [ ] Player moves on the grid and stays inside the screen (Adam)
- [ ] Lane ring buffer + random lane generation (both)
- [ ] Vehicles move in each lane at lane speed and direction (Adam)
- [ ] Camera scrolls as the player moves forward (Neo)
- [ ] Render lanes, vehicles and player from world state (Neo)
- [ ] Collision with vehicles and bottom edge → game over (Adam)
- [ ] Score = furthest row reached, shown on 7-seg (Adam)
- [ ] Game-over screen and restart (both)

**MVP = all must-have requirements met. Tag it `v1.0` in git so we always have a demo-able version.**

### M3 – Polish and optional features (week 4–5, only if M2 is done)
- [ ] Forced scrolling / pressure so the player cannot stand still forever (both)
- [ ] Extra lane type (river with logs or train) (pick one, split code ~50/50)
- [ ] Difficulty levels via switches (Adam)
- [ ] High-score list (Neo)
- [ ] Nicer sprites / animations (Neo)

### M4 – Performance analysis (start in parallel with M3, finish 1 week before EXPO)
- [ ] `perf.c`: read `mcycle`, `minstret` and the `mhpmcounter` CSRs (check the *DTEK-V Hardware Counter Introduction* for which counter is which event) (both)
- [ ] Benchmark mode: fixed seed + scripted input, run e.g. 1000 frames, measure `update` and `render` separately (both)
- [ ] Measure with `make OPT=-O0` and `make OPT=-O3` (both)
- [ ] Collect: IPC, I-cache stalls, D-cache stalls, ALU stalls, data-hazard stalls; put numbers in a table (both)
- [ ] Write the 2-page report ourselves: method, IPC, what stops IPC=1, -O0 vs -O3, architectural improvements (both)

### M5 – EXPO prep (last week)
- [ ] Code freeze: only bug fixes, tag `v-expo` (both)
- [ ] Every file and function has an author comment (both)
- [ ] `readme.txt` with build/run instructions, zip and upload (both)
- [ ] Final extended abstract in past tense, with contributions + reflections (both)
- [ ] Rehearse the 5-minute demo, both speaking; both able to explain all code (both)
- [ ] Pack board, cables, adapter, printed abstract (both)

## Risks

| Risk | What we do |
|---|---|
| The DTEK-V has only one push button | Use the button for "forward" and switches for back/left/right, or add buttons on the GPIO header. Decide in M1. |
| No VGA monitor at home | Get a VGA→HDMI adapter early; develop logic with 7-seg/UART prints meanwhile. |
| Rendering too slow → flicker | Only redraw what changed, use the back buffer, keep sprites small. This also gives us something interesting for the performance report. |
| Uneven split of coding | Each issue has an owner label; check the split at every weekly sync. |
| Merge conflicts | Small branches, one file mostly owned by one person, merge often. |
| Running out of time | MVP first, tag it, optional features only after. |

## Hardware cheat sheet

Fill in / verify against the course *Literature and Resources* and lab 3 code.

| Peripheral | Address | Notes |
|---|---|---|
| LEDs | `0x04000000` | 10 bits |
| Switches | `0x04000010` | 10 bits |
| 7-segment displays | `0x04000050` + 0x10 × n | 6 displays, active low |
| Timer | `0x04000020` | used in lab 3 |
| Push button | `0x040000d0` | |
| VGA pixel buffer | `0x08000000` | 320×240, 1 byte/pixel – verify |
| VGA DMA control | `0x04000100` | buffer swap – verify |
