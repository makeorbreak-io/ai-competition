require "strscan"
require "json"

module Loader
  def self.scan(s)
    t = s.scan(/./)

    case t
    when 'w'
      Wall.new
    when 'c'
      Coin.new(s.scan(/[0-9]+/).to_i)
    when 'r'
      Rock.new(scan(s))
    when 'p'
      id = s.scan(/[0-9]+/).to_i
      alive = s.scan(/[ok]/) == "o"

      Player.new(id, alive)
    when 'e'
      Explosion.new
    when 'b'
      timer = s.scan(/[0-9]+/).to_i
      s.scan(/,/)
      radius = s.scan(/[0-9]+/).to_i

      Bomb.new(timer, radius)
    when '.'
      nil
    else
      raise t
    end
  end

  def self.cell2state(cell)
    s = StringScanner.new(cell)
    value = []
    value << scan(s) until s.eos?
    value.compact
  end

  def self.nacs(agent)
    case agent
      when Bomb
        "b#{agent.timer},#{agent.radius}"
      when Wall
        "w"
      when Rock
        "r#{nacs(agent.reward)}"
      when Explosion
        "e"
      when Coin
        "c#{agent.points}"
      when Player
        "p#{agent.id}#{agent.alive ? "o" : "k"}"
    end
  end

  def self.state2cell(cell)
    return "." if cell.empty?
    cell.map(&method(:nacs)).sort.join
  end

  def self.read_board(io)
    turns = io.readline.to_i

    lines = io.readlines.map { |line| line.strip.split(/\s+/) }

    raise unless lines.map(&:size).uniq.size == 1

    board_cells = lines.each_with_index.map do |line, i|
      line.each_with_index.map do |cell, j|
        cell2state(cell).map do |agent|
          agent&.positioned_at([i, j])
        end
      end
    end

    {
      "width" => lines.first.size,
      "height" => lines.size,
      "turns_left" => turns,
      "board" => board_cells,
    }
  end

  def self.write_board(state)
    io = StringIO.new

    io.puts state["turns_left"]

    cells = state["board"].map { |line| line.map { |cell| state2cell(cell) } }

    cells.each do |row|
      io.puts row.join(" ")
    end

    io.string
  end
end
