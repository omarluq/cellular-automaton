require "colorize"
require "option_parser"

class Brain
  PATTERNS = {
    "blinker" => [
      [1, 1, 1],
    ],
    "beacon" => [
      [1, 1, 0, 0],
      [1, 1, 0, 0],
      [0, 0, 1, 1],
      [0, 0, 1, 1],
    ],
    "pulsar" => [
      [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],
      [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0],
    ],
    "glider" => [
      [0, 1, 0],
      [0, 0, 1],
      [1, 1, 1],
    ],
    "gosper_glider_gun" => [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
  }

  class Config
    property rows : Int32
    property cols : Int32
    property gens : Int32
    property buffer_height : Int32
    property buffer_width : Int32
    property update_delay : Float64

    def initialize(@rows = 50, @cols = 50, @gens = 1000, @update_delay = 0.1)
      @buffer_height = rows + 7
      @buffer_width = cols + 4
    end
  end

  property grid : Array(Array(Bool))
  property dying_grid : Array(Array(Bool))
  property config : Config
  @generation = 0

  def initialize(@config : Config)
    @grid = Array.new(@config.rows) { Array.new(@config.cols, false) }
    @dying_grid = Array.new(@config.rows) { Array.new(@config.cols, false) }
  end

  def populate
    new_grid = Array.new(@config.rows) { Array.new(@config.cols, false) }
    new_dying = Array.new(@config.rows) { Array.new(@config.cols, false) }

    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        neighbors = count_neighbors(y, x)
        dying_neighbors = count_dying_neighbors(y, x)

        if cell # alive
          if neighbors < 2 || neighbors > 3 || dying_neighbors >= 4
            new_dying[y][x] = true
          else
            new_grid[y][x] = true
          end
        elsif @dying_grid[y][x] # dying
          if neighbors == 2 && Random.rand < 0.3
            new_grid[y][x] = true
          end
        else # dead
          if neighbors == 3 || (neighbors == 2 && dying_neighbors >= 2)
            new_grid[y][x] = true
          end
        end
      end
    end

    @grid = new_grid
    @dying_grid = new_dying
    @generation += 1
  end

  private def count_neighbors(y : Int32, x : Int32) : Int32
    count = 0
    (-1..1).each do |dy|
      (-1..1).each do |dx|
        next if dx == 0 && dy == 0
        ny = (y + dy + @config.rows) % @config.rows
        nx = (x + dx + @config.cols) % @config.cols
        count += @grid[ny][nx] ? 1 : 0
      end
    end
    count
  end

  private def count_dying_neighbors(y : Int32, x : Int32) : Int32
    count = 0
    (-1..1).each do |dy|
      (-1..1).each do |dx|
        next if dx == 0 && dy == 0
        ny = (y + dy + @config.rows) % @config.rows
        nx = (x + dx + @config.cols) % @config.cols
        count += @dying_grid[ny][nx] ? 1 : 0
      end
    end
    count
  end

  def add_pattern(pattern_name : String, start_x : Int32, start_y : Int32)
    pattern = PATTERNS[pattern_name]?
    return unless pattern

    pattern.each_with_index do |row, y|
      row.each_with_index do |val, x|
        if val == 1
          @grid[(start_y + y) % @config.rows][(start_x + x) % @config.cols] = true
        end
      end
    end
  end

  def add_random_patterns(count : Int32)
    available_patterns = PATTERNS.keys
    count.times do
      pattern = available_patterns.sample
      x = Random.rand(@config.cols)
      y = Random.rand(@config.rows)
      add_pattern(pattern, x, y)
    end
  end

  def clear_grid
    @grid.each do |row|
      row.fill(false)
    end
    @dying_grid.each do |row|
      row.fill(false)
    end
  end

  def render_frame
    # Calculate statistics
    alive_count = @grid.sum { |row| row.count(true) }
    dying_count = @dying_grid.sum { |row| row.count(true) }
    dead_count = @config.rows * @config.cols - alive_count - dying_count

    # Clear screen and move cursor to home
    print "\033[H"

    # Render header
    header = "═══ Generation: #{@generation} ═══"
    puts header.colorize(:blue)
    puts "Alive: #{alive_count} ♥".colorize(:green)
    puts "Dying: #{dying_count} ⚡".colorize(:yellow)
    puts "Dead:  #{dead_count} ✝".colorize(:dark_gray)
    puts

    # Render grid
    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        char = if cell
                 "■".colorize(:green)
               elsif @dying_grid[y][x]
                 "▨".colorize(:yellow)
               else
                 "□".colorize(:dark_gray)
               end
        print char
      end
      puts
    end

    STDOUT.flush
  end
end

# Parse command line options
config = Brain::Config.new
OptionParser.parse do |parser|
  parser.banner = "Usage: crystal main.cr [arguments]"
  parser.on("--rows=ROWS", "Number of rows (default: 50)") { |rows| config.rows = rows.to_i }
  parser.on("--cols=COLS", "Number of columns (default: 50)") { |cols| config.cols = cols.to_i }
  parser.on("--gens=GENS", "Number of generations (default: 1000)") { |gens| config.gens = gens.to_i }
  parser.on("--delay=SECONDS", "Delay between generations (default: 0.1)") { |delay| config.update_delay = delay.to_f }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
end

# Initialize game
brain = Brain.new(config)

# Add initial patterns
brain.add_pattern("gosper_glider_gun", 1, 1)
brain.add_pattern("pulsar", 25, 25)
brain.add_random_patterns(3)

# Setup terminal
print "\033[2J"   # Clear screen
print "\033[?25l" # Hide cursor

begin
  config.gens.times do
    brain.populate
    brain.render_frame
    sleep config.update_delay
  end
rescue ex : Exception
  puts "Error: #{ex.message}"
  ex.backtrace.each { |line| puts line }
ensure
  # Cleanup terminal state
  print "\033[?25h" # Show cursor
  puts "\033[#{config.buffer_height + 1};1H"
end
