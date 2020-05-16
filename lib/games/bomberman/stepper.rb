module Games
  module Bomberman
    class Stepper
      DIRECTIONS = [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1],
      ].freeze

      class <<self
        def next(state, actions)
          new(state).next(actions)
        end
      end

      attr_reader :state
      def initialize(state)
        # deep dup
        @state = State.parse(StringIO.new(state.to_s))
      end

      def entity_types_at(position)
        state
          .entities
          .select { |e| (position.nil? || e.position == position) }
          .map(&:class)
          .uniq
      end

      def agents(position, type)
        state
          .entities
          .select { |e| e.is_a?(type) }
          .select { |e| (position.nil? || e.position == position) }
      end

      def explosions(position = nil)
        agents(position, Entities::Explosion)
      end

      def walls(position = nil)
        agents(position, Entities::Wall)
      end

      def players(position = nil)
        agents(position, Entities::Player)
      end

      def bombs(position = nil)
        agents(position, Entities::Bomb)
      end

      def rocks(position = nil)
        agents(position, Entities::Rock)
      end

      def rewards(position = nil)
        agents(position, Entities::Coin) +
          agents(position, Entities::MoreBombs) +
          agents(position, Entities::StrongerBombs)
      end

      def kill_player(player)
        player.alive = false
        player.points -= 100
      end

      def bomb_decrease_timer(bomb)
        bomb.timer -= 1
      end

      def move_player(movement)
        player = players.find { |p| p.id == movement.player_id }

        remove_object(player)
        place_object(movement.to, player)
      end

      def new_bomb(timer, range, player_id)
        Entities::Bomb.new(timer, range, Array(player_id))
      end

      def new_explosion
        Entities::Explosion.new
      end

      def place_object(position, object)
        state.entities << object.positioned_at(position)
      end

      def remove_object(object)
        state
          .entities
          .reject! { |agent| agent.object_id == object.object_id }
      end

      def next(actions)
        cleanup
        bomb_tick
        action_execution(actions)
        bomb_explosion
        decrease_turn_counter

        state
      end

      def decrease_turn_counter
        state.turn += 1
        state.turns_left -= 1
      end

      def cleanup
        explosions(state).each do |explosion|
          remove_object(explosion)
        end
      end

      def bomb_tick
        bombs.each do |bomb|
          bomb_decrease_timer(bomb)
        end
      end

      def action_execution(actions)
        # player movement
        unwalkable_objects = [
          Entities::Wall,
          Entities::Rock,
          Entities::Bomb,
        ]

        actions
          .select(&Action::Move.method(:===))
          .select { |move| (entity_types_at(move.to) & unwalkable_objects).empty? }
          .each { |move| move_player(move) }

        # collect rewards
        rewards.each do |reward|
          capturers = players(reward.position)

          if capturers.any?
            capturers.each { |player| apply_reward(reward, player) }
            remove_object(reward)
          end
        end

        # drop bombs
        actions
          .select(&Action::DropBomb.method(:===))
          .reject { |bomb| entity_types_at(bomb.at).include?(Entities::Bomb) }
          .each { |drop_bomb| place_object(drop_bomb.at, new_bomb(3, 3, drop_bomb.player_id)) }

        # merge bombs
        bombs
          .group_by(&:position)
          .values
          .select { |bombs| bombs.size > 1 }
          .each { |bombs| merge_bombs(bombs) }
      end

      def merge_bombs(bombs)
        bombs.each { |b| remove_object(b) }

        place_object(bombs.first.position, new_bomb(bombs.map(&:timer).min, bombs.map(&:range).max, bombs.map(&:player).flatten.uniq))
      end

      def bomb_explosion
        explode_bombs.each do |position|
          explode(position)
        end
      end

      Ray = Struct.new(:position, :direction, :ttl) do
        def next
          Ray.new(
            position.zip(direction).map(&:sum),
            direction,
            ttl - 1,
          )
        end
      end

      def explode_bombs
        new_bombs = bombs.select { |bomb| bomb.timer == 0 }
        processed_positions = new_bombs.map(&:position)

        rays = new_bombs.product(DIRECTIONS)
          .map { |(bomb, direction)| Ray.new(bomb.position, direction, bomb.range) }

        Enumerator.new do |y|
          while rays.any?
            ray = rays.pop

            next if walls(ray.position).any?

            y.yield(ray.position)

            unless processed_positions.include?(ray.position)
              processed_positions.push(ray.position)

              rays += bombs(ray.position).product(DIRECTIONS)
                .map { |bomb, direction| Ray.new(bomb.position, direction, bomb.range) }
            end

            next if (entity_types_at(ray.position) & [Entities::Player, Entities::Rock]).any?

            rays.push(ray.next) unless ray.ttl.zero?
          end
        end.to_a.uniq
      end

      def apply_reward(reward, player)
        case reward
        when Entities::Coin
          player.points += reward.points
        when Entities::StrongerBombs
        when Entities::MoreBombs
        end
      end

      def explode(position)
        rocks(position).each do |rock|
          if rock.reward
            place_object(rock.position, rock.reward)
          end
          remove_object(rock)
        end

        players(position)
          .each { |player| kill_player(player) }

        bombs(position)
          .each { |bomb| remove_object(bomb) }

        place_object(position, new_explosion)
      end
    end
  end
end
