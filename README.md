# Cellular Automaton

![demo](./demo.gif)

A simple cellular automaton implemented in Crystal lang inspired by [Brian's Brain](https://en.wikipedia.org/wiki/Brian%27s_Brain), featuring three distinct states: Alive (On), Dying, and Dead (Off). This creates interesting patterns and behaviors different from traditional [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) simulations.

## About

This implementation combines rules from both Brian's Brain and Conway's Game of Life, creating a hybrid automaton that exhibits unique emergent behaviors. While Brian's Brain typically uses simpler rules (on → dying → off), this version adds more complex interaction rules and a chance for dying cells to revive, leading to more dynamic patterns.

## Initial State

- Cells start randomly with a 30% chance of being alive
- Three gliders are placed at random positions

## Rules

1. **For Living Cells (On):**

   - Dies if fewer than 2 or more than 3 alive neighbors
   - Starts dying if surrounded by 4 or more dying neighbors
   - Otherwise stays alive

2. **For Dying Cells:**

   - Has a 30% chance to revive if exactly 2 alive neighbors
   - Otherwise becomes dead

3. **For Dead Cells:**
   - Becomes alive if exactly 3 alive neighbors
   - Becomes alive if 2 alive neighbors and 2+ dying neighbors
   - Otherwise stays dead

## Usage

```bash
crystal main.cr [arguments]

Arguments:
  --rows=ROWS    Number of rows (default: 50)
  --cols=COLS    Number of columns (default: 50)
  --gens=GENS    Number of generations to run (default: 1000)
  -h, --help     Show help
```

### Example

```bash
crystal main.cr --rows=30 --cols=40 --gens=500
```
