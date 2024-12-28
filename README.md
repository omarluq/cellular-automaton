# Cellular Automaton

<!--toc:start-->

- [Cellular Automaton](#cellular-automaton)
  - [Features](#features)
  - [Rules](#rules)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Examples](#examples)
  - [Patterns](#patterns)
  - [Controls](#controls)
  - [Implementation Details](#implementation-details)
  - [License](#license)
  - [Contributing](#contributing)
  <!--toc:end-->

![demo](./demo.gif)

A sophisticated cellular automaton implemented in Crystal, combining elements from [Brian's Brain](https://en.wikipedia.org/wiki/Brian%27s_Brain) and [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life). This implementation features three distinct states (Alive, Dying, and Dead) and supports various predefined patterns including oscillators, spaceships, and the famous Gosper Glider Gun.

## Features

- Three-state cellular automaton (Alive, Dying, Dead)
- Multiple pre-defined patterns:
  - Oscillators (Blinker, Beacon, Pulsar)
  - Spaceships (Glider, Lightweight Spaceship)
  - Still Life (Block, Beehive)
  - Gosper Glider Gun
- Colorized terminal output (Green for alive, Yellow for dying, Gray for dead)
- Real-time statistics tracking
- Configurable grid size and simulation speed
- Toroidal grid (wraps around edges)
- Random pattern placement

## Rules

1. **For Living Cells (Green):**

   - Dies if fewer than 2 or more than 3 alive neighbors
   - Enters dying state if surrounded by 4 or more dying neighbors
   - Otherwise stays alive

2. **For Dying Cells (Yellow):**

   - 30% chance to revive if exactly 2 alive neighbors
   - Otherwise becomes dead

3. **For Dead Cells (Gray):**
   - Becomes alive if exactly 3 alive neighbors
   - Becomes alive if 2 alive neighbors and 2+ dying neighbors
   - Otherwise stays dead

## Installation

Requires Crystal language installed on your system.

```bash
git clone https://github.com/omarluq/cellular-automaton.git
cd cellular-automaton
```

## Usage

```bash
crystal run main.cr [arguments]

Arguments:
  --rows=ROWS        Number of rows (default: 50)
  --cols=COLS        Number of columns (default: 50)
  --gens=GENS        Number of generations (default: 1000)
  --delay=SECONDS    Delay between generations (default: 0.1)
  -h, --help        Show help message
```

### Examples

Run with default settings:

```bash
crystal run main.cr
```

Create a larger grid with faster updates:

```bash
crystal main.cr --rows=100 --cols=100 --delay=0.05
```

Run a quick simulation:

```bash
crystal main.cr --rows=30 --cols=40 --gens=100 --delay=0.1
```

## Patterns

The simulation includes several pre-defined patterns that you can experiment with:

- **Oscillators:**

  - Blinker: Simple 3-cell oscillator
  - Beacon: 4x4 oscillator
  - Pulsar: Large 13x13 oscillator

- **Spaceships:**

  - Glider: Basic moving pattern
  - Lightweight Spaceship (LWSS): Larger moving pattern

- **Still Life:**

  - Block: 2x2 stable pattern
  - Beehive: 4x3 stable pattern

- **Guns:**
  - Gosper Glider Gun: Continuously produces gliders

## Controls

- The simulation runs automatically once started
- Use Ctrl+C to exit
- The display shows:
  - Current generation number
  - Count of alive cells (■)
  - Count of dying cells (▨)
  - Count of dead cells (□)

## Implementation Details

- Uses efficient boolean arrays for state tracking
- Implements toroidal grid wrapping for infinite-like space
- Optimized neighbor counting
- Efficient terminal rendering with color support
- Batch updates for smooth animation

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.
