require "active_support/core_ext/hash/keys"

module Games::Bomberman
  module ToPlayer
    def self.to_player(state:, id:)
      entities = state
        .entities
        .map { |entity| serialize_entity(state, entity, id) }
        .sort_by(&:to_json)

      {
        self: 0,
        width: state.width,
        height: state.height,
        turn: state.turn,
        turns_left: state.turns_left,
        entities: entities,
        entities_by_type: entities.group_by { |e| e[:type] },
        entities_by_position: entities.group_by { |e| e[:position] },
      }.deep_transform_keys { |k| k.is_a?(Symbol) ? k.to_s : k }
    end

    def self.mask_player_id(state, id, player_id)
      if player_id == id
        0
      else
        (state.player_ids - [id]).sort.index(player_id) + 1
      end
    end

    def self.serialize_entity(state, entity, id)
      case entity
      when Entities::Bomb
        {
          type: "bomb",
          position: entity.position,
          timer: entity.timer,
          range: entity.range,
          players: entity.player.map { |player_id| mask_player_id(state, id, player_id) },
        }
      when Entities::Coin
        {
          type: "coin",
          position: entity.position,
          points: entity.points,
        }
      when Entities::MoreBombs
        {
          type: "more-bombs",
          position: entity.position,
        }
      when Entities::StrongerBombs
        {
          type: "stronger-bombs",
          position: entity.position,
        }
      when Entities::Explosion
        {
          type: "explosion",
          position: entity.position,
        }
      when Entities::Player
        {
          type: "player",
          position: entity.position,
          id: mask_player_id(state, id, entity.id),
          alive: entity.alive,
          points: entity.points,
          simultaneous_bombs: entity.simultaneous_bombs,
          bomb_range: entity.bomb_range,
        }
      when Entities::Rock
        {
          type: "rock",
          position: entity.position,
        }
      when Entities::Wall
        {
          type: "wall",
          position: entity.position,
        }
      else
        raise "unknown entity: #{entity.class}"
      end
    end
  end
end
