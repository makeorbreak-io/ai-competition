# Bomberman

Version: *not ready for release*

In a game of bomberman, players move around, placing bombs to clear a path and
blow up their opponents. They collect power ups and coins to help them get the
highest score. The game ends after a set amount of turns or when there is a
only one player standing.

The "Rules summary" section describes the rules of the game, without trying to
be extra precise, so that you get a basic idea of what the game rules are. The
"Detailed rules" section goes into exact details of how a turn is processed.


## Rules summary

A game of bomberman is played on a rectangular board. Each square on the board
may have an indestructible wall, a destructible rock, or be a free square. Free
squares may contain a reward, which can be either a power up or a coin.

There can be as many players as the number of free squares on the board.

Every turn, players can either move one square in one of the four cardinal
directions or, alternatively, place a bomb in their current position. Bombs
explode after some turns, launching a blast ray in each of the four directions.

Players cannot move to squares occupied by walls, rocks, nor bombs. They can move
to squares occupied by other players. Every player moves simultaneously. If
players move to a square with a reward, they get the reward and it is removed
from the board. If multiple players move to a square with a reward in the same
turn, they both get the reward.

Players can only drop a bomb while no other bomb placed by them is still on the
board. The number of simultaneous bombs per player may be changed by a power
up. Bombs cannot be placed if, at the start of the turn, there was a bomb in
the target square.

If two or more players place a bomb in the same square during the same turn,
those bombs are all replaced by a single bomb with the longest blast ray range.

Destructible rocks are destroyed when hit by bomb blasts and are occasionally
replaced by a reward. Players do not know in advance which destructible rocks
will be replaced by rewards when destroyed. This is the only hidden information
in the game.

After players move, any bombs that are due to go off explode. They explode
instantly, creating blast rays in each of the four directions. Bombs blast ray
range may be affected by power ups. Each ray stops propagating as soon as they
hit an indestructible wall, a destructible rock, or another bomb. They do not
stop when hitting a player. If a ray hits another bomb, the hit bomb explodes
in the same turn. After every blast ray is calculated, destructible rocks and
players that were hit are removed from the board.

If a player is hit by a bomb, they lose a set amount of points. The game ends
when there is a single player left on the board or when the game goes through a
set amount of turns.


### Available rewards

Rewards can be in the form of coins or power ups.

Coins increase the player's score by a set amount, visible to every player
beforehand. Different coins may yield a different number of points.

The "More bombs" power up increases the number of bombs placed by the player
that may exist on the board simultaneously.

"Stronger bombs" increases the range of the blast rays created when the
player's bomb explode. This only applies to bombs placed after collecting the
power up.


## Detailed rules

Each player starts with the following attributes:
- simultaneous bombs = 1
- bomb range = 3
- points = 0

At the start of each turn, each square on the board may contain a number of
objects. These are the possible sets of objects that may be in a square:
- An explosion marker
- An indestructible wall
- A destructible rock
- A destructible rock and a hidden reward
- A reward
- One or more players
- A bomb
- A bomb and one or more players
- Nothing

Squares cannot be in a combination of two or more of the above states. For
example, a square cannot contain both a bomb and a reward.

Each turn has the following phases:
- action decision
- cleanup
- bomb tick
- action execution
- bomb explosion

At the end of the turn, decrease the turn counter. If it hits zero, or if there
one or zero players left on the board, the game ends.


### Action decision

Each player still on the board decides which action are they going to make (up,
down, left, right, or drop bomb). Players can see the whole board except for
any rewards hidden under destructible rocks.


### Cleanup

Remove any explosion markers present on the board. In the first turn there
won't be any markers to remove.


### Bomb tick

Decrease the `timer` attribute of every bomb currently on the board.


### Action execution

All players that decided to do a movement action (up, down, left, or right)
move to their destination, except if there is a bomb, a destructible rock or
indestructible wall in the destination square.

Every player that is currently standing in a square with a reward (coin or
power up) collects the reward. If two or more players are in the same square
with a reward, they both get it.
- when a coin is collected, the player's score is increased by the coin's
  value;
- when "More bombs" is collected, the player's simultaneous bomb attribute is
  increased by one;
- when "Stronger bombs" is collected, the player's bomb range attribute is
  increased by one;

Any rewards collected this turn are removed from the board.

For every player that decided to do a drop bomb action, check the number of
bombs currently on the board that belong to them. If that number is less than
the player's simultaneous bombs attribute, and there was no bomb in that square
at the start of the turn, place a bomb in their square, with the following
attributes:
- `range` = the player's bomb range attribute
- `timer` = 3
- `owner` = the player's id

After placing new bombs, if there are squares with more than one bomb in them,
replace them with a
single bomb, with the following attributes:
- `range` = the largest range of the replaced bombs
- `timer` = 3
- `owner` = a set of every replaced bomb's `owner`


### Bomb explosion

Explosions are represented by explosion markers. These are removed during the
cleanup phase of the following turn.

Bombs that have their `timer` attribute at zero will explode now.

For each cardinal direction, starting from and inclusing the exploding bomb's
position, mark a number of squares equal to the bomb's `range` attribute,
stopping if you reach a square with a destructible rock, an indestructible
wall, or another bomb. Do not place explosion markers in squares with
indestructible walls.

For example, if the exploding bomb's `range` is 1, there should be five squares
marked in a plus sign configuration. Do not remove the exploding bombs from the
board yet.

If there are any bombs on the marked squares, those bombs will also explode
this turn. Follow the marking procedure for these bombs and continue until
there are no bombs on marked squares that have not been processed yet.

Go through every marked square and check what is in each square.

Remove any bombs from marked squares.

Remove destructible rocks from marked squares, leaving behind any rewards
that they may uncover.

If there are any players in marked squares, decrease each of their score's by
100 and remove them
from the board.

## Random notes

This is a turn based game. If two players perform the same action, they are
applied simultaneously to avoid first player advantage.

To avoid stalemates, the game only lasts for a limited amount of turns.

We use points instead of win/loss/draw to avoid too many draws.


## Open questions

Should we give player points for:
- breaking destructible rocks, to reward bomb usage?
- every new square that they visit, to reward exploration?

