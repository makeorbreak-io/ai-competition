function next(local_state)
  moves = {
    "right",
    "bomb",
    "left",
    "down",
    "bomb",
    "up",
    "right",
    "right",
    "bomb",
    "right",
    "right",
    "down",
  }

  move = moves[local_state["turn"] + 1]
  if move then
    return move
  else
    return "wait"
  end
end
