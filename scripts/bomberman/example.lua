function playerposition(local_state, id)
  for i, row in pairs(local_state["board"]) do
    for j, cells in pairs(row) do
      for c, cell in pairs(cells) do
        if cell["type"] == "player" and cell["id"] == id then
          return {i, j}
        end
      end
    end
  end
end

function empty_move(local_state, position)
  for i, p in pairs({{-1,0}, {1,0}, {0,-1}, {0,1}}) do
    free = true
    for c, cell in pairs(local_state["board"][position[1] + p[1]][position[2] + p[2]]) do
      ctype = cell["type"]
      if ctype == "wall" or ctype == "rock" or ctype == "bomb" then
        free = false
      end
    end

    if free then
      return p
    end
  end

  return false
end

function next_to_(local_state, position, ctype)
  for i, p in pairs({{0, 0}, {-1,0}, {1,0}, {0,-1}, {0,1}}) do
    for c, cell in pairs(local_state["board"][position[1] + p[1]][position[2] + p[2]]) do
      if cell["type"] == ctype then
        return p
      end
    end
  end

  return false
end


function placed_bomb(local_state, id)
  for i, row in pairs(local_state["board"]) do
    for j, cells in pairs(row) do
      for c, cell in pairs(cells) do
        if cell["type"] == "bomb" and cell["player"] == id then
          return {i, j, cell}
        end
      end
    end
  end
end

function next(local_state)
  directions = {
    "up",
    "down",
    "left",
    "right",
    "bomb",
  }

  -- we're always player 0 and they're always player 1
  myposition = playerposition(local_state, 0)
  theirposition = playerposition(local_state, 1)

  print(myposition)
  print(theirposition)
  print(placed_bomb(local_state, 0))
  print(placed_bomb(local_state, 1))

  bomb = next_to_(local_state, myposition, "bomb")
  if bomb then
    print("next to bomb", bomb)

    moveto = empty_move(local_state, myposition)
    print("empty move", moveto)

    if moveto[1] == 1 and moveto[2] == 0 then
      return "down"
    elseif moveto[1] == -1 and moveto[2] == 0 then
      return "up"
    elseif moveto[1] == 0 and moveto[2] == -1 then
      return "left"
    elseif moveto[1] == 0 and moveto[2] == 1 then
      return "right"
    end

    print("dunno where to move, going down")
    return "down"
  end

  if next_to_(local_state, myposition, "rock") then
    print("next to rock")

    return "bomb"
  end

  return "up"
end
