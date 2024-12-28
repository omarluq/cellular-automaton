require "colorize"
require "option_parser"

class Brain # :nodoc
  class Config
    property rows : Int32
    property cols : Int32
    property gens : Int32
    property buffer_height : Int32
    property buffer_width : Int32

    def initialize(@rows = 50, @cols = 50, @gens = 1000)
      @buffer_height = rows + 7
      @buffer_width = cols + 4
    end
  end

  class Cell
    enum State
      On    = 1
      Off   = 0
      Dying = 2
    end

    property state : State
    property x : Int32
    property y : Int32

    def initialize(@x : Int32, @y : Int32)
      @state = if Random.rand < 0.3
                 State::On
               else
                 State::Off
               end
    end

    def update_state(grid)
      neighbors = find_neighbors(grid)
      alive_neighbors = neighbors.count { |cell| cell.state.on? }
      dying_neighbors = neighbors.count { |cell| cell.state.dying? }

      @state = case @state
               when .on?
                 if alive_neighbors < 2 || alive_neighbors > 3
                   State::Dying
                 elsif dying_neighbors >= 4
                   State::Dying
                 else
                   State::On
                 end
               when .dying?
                 if alive_neighbors == 2 && Random.rand < 0.3
                   State::On
                 else
                   State::Off
                 end
               when .off?
                 if alive_neighbors == 3 || (alive_neighbors == 2 && dying_neighbors >= 2)
                   State::On
                 else
                   State::Off
                 end
               else
                 @state
               end
    end

    def find_neighbors(grid)
      rows = grid.size
      cols = grid[0].size
      neighbors = [] of Cell

      (-1..1).each do |dy|
        (-1..1).each do |dx|
          next if dx == 0 && dy == 0
          ny = (@y + dy + rows) % rows
          nx = (@x + dx + cols) % cols
          neighbors << grid[ny][nx]
        end
      end

      neighbors
    end
  end

  @generation = 0
  @buffer = Array(Array(String)).new
  @prev_buffer = Array(Array(String)).new

  property grid : Array(Array(Cell))
  property config : Config

  def initialize(@config : Config)
    @grid = Array(Array(Cell)).new(@config.rows) do |y|
      Array(Cell).new(@config.cols) do |x|
        Cell.new(x, y)
      end
    end

    @config.buffer_height.times do
      @buffer << Array(String).new(@config.buffer_width, " ")
      @prev_buffer << Array(String).new(@config.buffer_width, " ")
    end
  end

  def populate
    new_grid = @grid.map do |row|
      row.map do |cell|
        new_cell = Cell.new(cell.x, cell.y)
        new_cell.state = cell.state
        new_cell
      end
    end

    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cell.update_state(new_grid)
      end
    end
    @generation += 1
  end

  private def clear_buffer
    @config.buffer_height.times do |y|
      @config.buffer_width.times do |x|
        @buffer[y][x] = " "
      end
    end
  end

  private def swap_buffers
    @buffer, @prev_buffer = @prev_buffer, @buffer
  end

  private def draw_to_buffer(y : Int32, x : Int32, char : String)
    return if y < 0 || y >= @config.buffer_height || x < 0 || x >= @config.buffer_width
    @buffer[y][x] = char
  end

  def render_frame
    clear_buffer

    alive_count = @grid.sum { |row| row.count { |cell| cell.state.on? } }
    dying_count = @grid.sum { |row| row.count { |cell| cell.state.dying? } }
    dead_count = @grid.sum { |row| row.count { |cell| cell.state.off? } }

    header = "═══ Generation: #{@generation} ═══"
    header.chars.each_with_index do |char, x|
      draw_to_buffer(0, x + 2, char.to_s.colorize(:blue).to_s)
    end

    draw_to_buffer(1, 2, "Alive: #{alive_count} ♥".colorize(:green).to_s)
    draw_to_buffer(2, 2, "Dying: #{dying_count} ⚡".colorize(:yellow).to_s)
    draw_to_buffer(3, 2, "Dead:  #{dead_count} ✝".colorize(:dark_gray).to_s)

    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        char = case cell.state
               when .on?    then "■".colorize(:green)
               when .dying? then "▨".colorize(:yellow)
               when .off?   then "□".colorize(:dark_gray)
               end
        draw_to_buffer(y + 5, x + 2, char.to_s)
      end
    end

    print "\033[H"
    @config.buffer_height.times do |y|
      @config.buffer_width.times do |x|
        if @buffer[y][x] != @prev_buffer[y][x]
          print "\033[#{y + 1};#{x + 1}H#{@buffer[y][x]}"
        end
      end
    end
    STDOUT.flush

    swap_buffers
  end
end

def add_glider(grid, start_x, start_y)
  glider = [
    [0, 1, 0],
    [0, 0, 1],
    [1, 1, 1],
  ]

  glider.each_with_index do |row, y|
    row.each_with_index do |val, x|
      if val == 1
        grid[(start_y + y) % grid.size][(start_x + x) % grid.size].state = Brain::Cell::State::On
      end
    end
  end
end

config = Brain::Config.new
OptionParser.parse do |parser|
  parser.banner = "Usage: crystal main.cr [arguments]"

  parser.on("--rows=ROWS", "Number of rows (default: 50)") { |rows| config.rows = rows.to_i }
  parser.on("--cols=COLS", "Number of columns (default: 50)") { |cols| config.cols = cols.to_i }
  parser.on("--gens=GENS", "Number of generations (default: 1000)") { |gens| config.gens = gens.to_i }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
end

brain = Brain.new(config)

3.times do
  add_glider(brain.grid, Random.rand(brain.grid.size), Random.rand(brain.grid.size))
end

print "\033[2J"
print "\033[?25l"

begin
  config.gens.times do
    brain.populate
    brain.render_frame
    sleep 0.1.seconds
  end
ensure
  print "\033[?25h"
  puts "\033[#{config.buffer_height + 1};1H"
end
