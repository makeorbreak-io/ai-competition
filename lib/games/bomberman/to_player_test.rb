require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, "../.."))
loader.setup

require "minitest/autorun"
require "loader"

module Games::Bomberman
  class ToPlayerTest < Minitest::Test
    def state
      Reader.read(StringIO.new(<<-BOARD))
  1
  w w                w w   w         w
  w rs               . .   b2,3,2&3  w
  w b5,6,3p2k,7,8,9  . rc4 r.        w
  w e                . rm  p3o,4,5,6 w
  w w                w w   w         w
  BOARD
    end

    def to_player(id)
      ToPlayer.to_player(state: state, id: id)
    end

    def test_self
      assert_equal 0, to_player(3)["self"]
      assert_equal 0, to_player(2)["self"]
    end

    def test_player_ids
      assert_equal 1, to_player(3)["entities_by_type"]["player"][0]["id"]
      assert_equal 0, to_player(3)["entities_by_type"]["player"][1]["id"]

      assert_equal 0, to_player(2)["entities_by_type"]["player"][0]["id"]
      assert_equal 1, to_player(2)["entities_by_type"]["player"][1]["id"]
    end

    def test_meta
      assert_equal 6, to_player(3)["width"]
      assert_equal 5, to_player(3)["height"]
      assert_equal 0, to_player(3)["turn"]
      assert_equal 1, to_player(3)["turns_left"]
    end

    def test_entities
      assert_equal 27, to_player(3)["entities"].length
    end

    def test_entities_by_type
      assert_equal 18, to_player(3)["entities_by_type"]["wall"].length
      assert_equal 2, to_player(3)["entities_by_type"]["player"].length
      assert_equal 4, to_player(3)["entities_by_type"]["rock"].length
    end

    def test_entities_by_position
      assert_equal "bomb", to_player(3)["entities_by_position"][[1,4]][0]["type"]
    end

    def test_player
      to_player(3)["entities_by_type"]["player"][0].tap do |player|
        assert_equal 1, player["id"]
        assert_equal false, player["alive"]
        assert_equal 7, player["points"]
      end

      to_player(3)["entities_by_type"]["player"][1].tap do |player|
        assert_equal 0, player["id"]
        assert_equal true, player["alive"]
        assert_equal 4, player["points"]
      end
    end
  end
end
