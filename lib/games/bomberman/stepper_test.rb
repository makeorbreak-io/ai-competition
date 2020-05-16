require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, "../.."))
loader.setup

require "minitest/autorun"
require "loader"

class Games::Bomberman::StepperTest < Minitest::Test
  SetPlayer = Struct.new(:player_id, :actions, :game) do
    def next(state)
      action = self.actions.shift

      game::Action.build(state, player_id, action)
    end
  end

  def assert_next_state(movesets, initial, expected)
    players = movesets.each_with_index.map { |moveset, i| SetPlayer.new(i, moveset, Games::Bomberman) }

    state = Games::Bomberman::State.parse(StringIO.new(initial))
    actions = players.map { |player| player.next(state) }

    next_state = Games::Bomberman::Stepper.next(state, actions)

    assert_equal(expected, next_state.to_s)
    assert_equal(initial, state.to_s)
  end

  def test_bomb_timer_decreases
    assert_next_state([], <<-INITIAL, <<-EXPECTED)
1
w w w w      w
w . w b2,3,0 w
w . . w      w
w . . .      w
w w w w      w
INITIAL
0
w w w w      w
w . w b1,3,0 w
w . . w      w
w . . .      w
w w w w      w
EXPECTED
  end

  def test_bomb_explosions_dont_go_through_walls
    assert_next_state([], <<-INITIAL, <<-EXPECTED)
1
w w w w      w
w . w b1,3,0 w
w . . w      w
w . . .      w
w w w w      w
INITIAL
0
w w w w w
w . w e w
w . . w w
w . . . w
w w w w w
EXPECTED
  end

  def test_bombs_explode_simultaneously
    assert_next_state([], <<-INITIAL, <<-EXPECTED)
1
w w      w      w w
w .      .      . w
w b1,2,0 r.     . w
w .      b1,2,0 . w
w w      w      w w
    INITIAL
0
w w w w w
w e . . w
w e e . w
w e e e w
w w w w w
    EXPECTED
  end

  def test_bombs_propagate
    assert_next_state([], <<-INITIAL, <<-EXPECTED)
1
w w      w w w      w w
w .      . . b5,1,0 . w
w .      . . .      . w
w b1,3,0 . . b3,2,0 . w
w w      w w w      w w
    INITIAL
0
w w w w w w w
w e . e e e w
w e . . e . w
w e e e e e w
w w w w w w w
    EXPECTED
  end

  def test_player_movement
    assert_next_state([%w[right]], <<-INITIAL, <<-EXPECTED)
1
w w         w w
w p0o,0,3,3 . w
w w         w w
    INITIAL
0
w w w         w
w . p0o,0,3,3 w
w w w         w
    EXPECTED
  end

  def test_player_movement_against_wall
    assert_next_state([%w[right]], <<-INITIAL, <<-EXPECTED)
1
w w w         w
w . p0o,0,3,3 w
w w w         w
    INITIAL
0
w w w         w
w . p0o,0,3,3 w
w w w         w
    EXPECTED
  end

  def test_player_movement_against_other_player
    assert_next_state([%w[right]], <<-INITIAL, <<-EXPECTED)
1
w w         w         w
w p0o,0,3,3 p1o,0,3,3 w
w w         w         w
    INITIAL
0
w w w                  w
w . p0o,0,3,3p1o,0,3,3 w
w w w                  w
    EXPECTED
  end

  def test_player_movement_to_same_cell
    assert_next_state([%w[right], %w[left]], <<-INITIAL, <<-EXPECTED)
1
w w         w w         w
w p0o,0,3,3 . p1o,0,3,3 w
w w         w w         w
    INITIAL
0
w w w                  w w
w . p0o,0,3,3p1o,0,3,3 . w
w w w                  w w
    EXPECTED
  end


  def test_player_drop_bomb
    assert_next_state([%w[bomb]], <<-INITIAL, <<-EXPECTED)
1
w w w         w
w . p0o,0,3,3 w
w w w         w
    INITIAL
0
w w w               w
w . b3,3,0p0o,0,3,3 w
w w w               w
    EXPECTED
  end

  def test_bomb_drop_does_not_override_existing_bomb
    assert_next_state([%w[bomb]], <<-INITIAL, <<-EXPECTED)
1
w w w               w
w . b2,4,0p0o,0,3,3 w
w w w               w
    INITIAL
0
w w w               w
w . b1,4,0p0o,0,3,3 w
w w w               w
    EXPECTED
  end

  def test_players_drop_bombs_same_square
    assert_next_state([%w[bomb], %w[bomb]], <<-INITIAL, <<-EXPECTED)
1
w w                  w
w p0o,0,3,3p1o,0,3,3 w
w w                  w
    INITIAL
0
w w                          w
w b3,3,0&1p0o,0,3,3p1o,0,3,3 w
w w                          w
    EXPECTED
  end


  def test_rocks_are_replaced_with_reward_on_explosion
    assert_next_state([], <<-INITIAL, <<-EXPECTED)
1
w w   w      w  w
w .   rs     .  w
w rc1 b1,1,0 r. w
w .   rm     .  w
w w   w      w  w
    INITIAL
0
w w   w  w w
w .   es . w
w c1e e  e w
w .   em . w
w w   w  w w
    EXPECTED
  end

  def test_coin_is_captured_by_player
    assert_next_state([%w[left]], <<-INITIAL, <<-EXPECTED)
1
w w  w         w
w c5 p0o,0,3,3 w
w w  w         w
    INITIAL
0
w w         w w
w p0o,5,3,3 . w
w w         w w
    EXPECTED
  end

  def test_simultaneous_capture_of_coin_increases_both_scores
    assert_next_state([%w[right], %w[left]], <<-INITIAL, <<-EXPECTED)
1
w w         w  w         w
w p0o,0,3,3 c5 p1o,0,3,3 w
w w         w  w         w
    INITIAL
0
w w w                  w w
w . p0o,5,3,3p1o,5,3,3 . w
w w w                  w w
    EXPECTED
  end
end
