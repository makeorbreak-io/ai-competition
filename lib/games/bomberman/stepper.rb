module Games
  module Bomberman
    module Stepper
      DIRECTIONS = [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1],
      ].freeze

      class <<self
        def agents(board, position, type)
          board.values.flatten.select do |agent|
            (position.nil? || agent.position == position) && agent.is_a?(type)
          end
        end

        def explosions(x, position = nil)
          agents(x, position, Entities::Explosion)
        end

        def walls(x, position = nil)
          agents(x, position, Entities::Wall)
        end

        def players(x, position = nil)
          agents(x, position, Entities::Player)
        end

        def bombs(x, position = nil)
          agents(x, position, Entities::Bomb)
        end

        def rocks(x, position = nil)
          agents(x, position, Entities::Rock)
        end

        def rewards(x, position = nil)
          agents(x, position, Entities::Coin) +
            agents(x, position, Entities::MoreBombs) +
            agents(x, position, Entities::StrongerBombs)
        end

        def kill_player(player, score)
          player.alive = false
          score[player.id] -= 100
        end

        def bomb_decrease_timer(bomb)
          bomb.timer -= 1
        end

        def move_player(x, movement)
          player = players(x).find { |p| p.id == movement.player_id }
          remove_object(x, player)

          place_object(x, movement.to, player)
        end

        def object_types_at(x, position)
          x[position].map(&:class).uniq
        end

        def new_bomb(timer, radius, player_id)
          Entities::Bomb.new(timer, radius, Array(player_id))
        end

        def new_explosion
          Entities::Explosion.new
        end

        def place_object(x, position, object)
          x[position] << object.positioned_at(position)
        end

        def remove_object(x, object)
          x[object.position]
            .reject! { |agent| agent.object_id == object.object_id }
        end

        def next(state, actions)
          state = State.parse(StringIO.new(state.to_s))
          board = from_board(state.board)

          cleanup(board)
          bomb_tick(board)
          action_execution(board, actions, state.score)
          bomb_explosion(board, state.score)

          State.new(
            width: state.width,
            height: state.height,
            turn: state.turn + 1,
            turns_left: state.turns_left - 1,
            board: to_board(board.transform_values(&:compact)),
            score: state.score,
          )
        end

        def cleanup(board)
          explosions(board).each do |explosion|
            remove_object(board, explosion)
          end
        end

        def bomb_tick(board)
          bombs(board).each do |bomb|
            bomb_decrease_timer(bomb)
          end
        end

        def action_execution(board, actions, score)
          # player movement
          unwalkable_objects = [
            Entities::Wall,
            Entities::Rock,
            Entities::Bomb,
          ]

          actions
            .select(&Action::Move.method(:===))
            .select { |move| (object_types_at(board, move.to) & unwalkable_objects).empty? }
            .each { |move| move_player(board, move) }

          # collect rewards
          rewards(board).each do |reward|
            capturers = players(board, reward.position)

            if capturers.any?
              capturers.each { |player| apply_reward(board, score, reward, player) }
              remove_object(board, reward)
            end
          end

          # drop bombs
          actions
            .select(&Action::DropBomb.method(:===))
            .reject { |bomb| object_types_at(board, bomb.at).include?(Entities::Bomb) }
            .each { |drop_bomb| place_object(board, drop_bomb.at, new_bomb(3, 3, drop_bomb.player_id)) }

          # merge bombs
          bombs(board)
            .group_by(&:position)
            .values
            .select { |bombs| bombs.size > 1 }
            .each { |bombs| merge_bombs(board, bombs) }
        end

        def merge_bombs(board, bombs)
          bombs.each { |b| remove_object(board, b) }

          place_object(board, bombs.first.position, new_bomb(bombs.map(&:timer).min, bombs.map(&:radius).max, bombs.map(&:player).flatten.uniq))
        end

        def bomb_explosion(board, score)
          explode_bombs(board).each do |position|
            explode(board, position, score)
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

        def explode_bombs(x)
          new_bombs = bombs(x).select { |bomb| bomb.timer == 0 }
          processed_positions = new_bombs.map(&:position)

          rays = new_bombs.product(DIRECTIONS)
            .map { |(bomb, direction)| Ray.new(bomb.position, direction, bomb.radius) }

          Enumerator.new do |y|
            while rays.any?
              ray = rays.pop

              next if walls(x, ray.position).any?

              y.yield(ray.position)

              unless processed_positions.include?(ray.position)
                processed_positions.push(ray.position)

                rays += bombs(x, ray.position).product(DIRECTIONS)
                  .map { |bomb, direction| Ray.new(bomb.position, direction, bomb.radius) }
              end

              next if (object_types_at(x, ray.position) & [Entities::Player, Entities::Rock]).any?

              rays.push(ray.next) unless ray.ttl.zero?
            end
          end.to_a.uniq
        end

        def apply_reward(x, score, reward, player)
          case reward
          when Entities::Coin
            score[player.id] += reward.points
          when Entities::StrongerBombs
          when Entities::MoreBombs
          end
        end

        def explode(x, position, score)
          rocks(x, position).each do |rock|
            if rock.reward
              place_object(x, rock.position, rock.reward)
            end
            remove_object(x, rock)
          end

          players(x, position)
            .each { |player| kill_player(player, score) }

          bombs(x, position)
            .each { |bomb| remove_object(x, bomb) }

          place_object(x, position, new_explosion)
        end

        def from_board(board)
          board.each_with_index.flat_map do |line, i|
            line.each_with_index.map do |cell, j|
              [[i, j], cell]
            end
          end.to_h
        end

        def to_board(x)
          rows = x.keys.map(&:first).max + 1
          columns = x.keys.map(&:last).max + 1

          Array.new(rows) do |i|
            Array.new(columns) do |j|
              x[[i, j]]
            end
          end
        end
      end
    end
  end
end
