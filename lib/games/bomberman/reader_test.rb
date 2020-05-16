require File.join(__dir__, "../../test_helper")

module Games::Bomberman
  class ReaderTest < Minitest::Test
    def state
      Reader.read(StringIO.new(<<-BOARD))
  1
  w w                w   w         w
  w rs               .   b2,3,0&3  w
  w b5,6,7p2k,7,8,9  rc4 r.        w
  w e                rm  p3o,4,5,6 w
  w w                w   w         w
  BOARD
    end

    def entities_by_class
      state.entities.group_by(&:class)
    end

    def test_board_size
      assert_equal 5, state.width
      assert_equal 5, state.height
    end

    def test_entities
      assert_equal 2, entities_by_class[Entities::Bomb].length
      assert_equal 1, entities_by_class[Entities::Explosion].length
      assert_equal 2, entities_by_class[Entities::Player].length
      assert_equal 4, entities_by_class[Entities::Rock].length
      assert_equal 16, entities_by_class[Entities::Wall].length
    end

    def test_bombs
      entities_by_class[Entities::Bomb][0].tap do |bomb|
        assert_equal 2, bomb.timer
        assert_equal 3, bomb.range
        assert_equal [0, 3], bomb.player
      end

      entities_by_class[Entities::Bomb][1].tap do |bomb|
        assert_equal 5, bomb.timer
        assert_equal 6, bomb.range
        assert_equal [7], bomb.player
      end
    end

    def test_players
      entities_by_class[Entities::Player][0].tap do |player|
        assert_equal false, player.alive
        assert_equal 2, player.id
        assert_equal 7, player.points
        assert_equal 8, player.simultaneous_bombs
        assert_equal 9, player.bomb_range
      end

      entities_by_class[Entities::Player][1].tap do |player|
        assert_equal true, player.alive
        assert_equal 3, player.id
        assert_equal 4, player.points
        assert_equal 5, player.simultaneous_bombs
        assert_equal 6, player.bomb_range
      end
    end

    def test_rock
      entities_by_class[Entities::Rock][0].tap do |rock|
        assert_equal Entities::StrongerBombs, rock.reward.class
      end

      entities_by_class[Entities::Rock][1].tap do |rock|
        assert_equal Entities::Coin, rock.reward.class
        assert_equal 4, rock.reward.points
      end

      entities_by_class[Entities::Rock][2].tap do |rock|
        assert_nil rock.reward
      end

      entities_by_class[Entities::Rock][3].tap do |rock|
        assert_equal Entities::MoreBombs, rock.reward.class
      end
    end
  end
end
