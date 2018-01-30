# Coin Collector
(C) 2018, Richard Marks, Stephen Collins, MIT License

## Design Summary
the game consists of a 2D board of 10 x 10 tiles

each tile can be one of dirt, a pit, a coin, or a stone covering either dirt, a pit or a coin

at the start, all tiles are the stone tile

when you click on a stone tile, it changes to reveal either dirt, a coin or a pit

if the tile revealed is dirt, you continue playing

if the tile revealed is a pit, you lose a life

if the tile revealed is a coin, you may then click on the coin to collect it, which changes the tile to dirt

you have 3 lives at the start of the game, and gain an extra life for each 25 coins you collect

if you turn over all the tiles in the board, the board is reset to a new random configuration with all tiles turned to stones and you keep playing

the timer counts down each second, starting from 120 seconds on the timer

when the timer reaches zero, the game is over, your total coins are tallied and you get a chance to log a high score which gets stored in local storage

### Notes

+ Prototype does not include a timer
+ Prototype does not include resetting the board
+ Prototype does not include high scores nor total coin tally at gameover

## Prototype Example Execution

### frame 1

```
user@host~$ ./coin-collector-prototype
Coin Collector Prototype v1.0
S - Stone                Lives Remaining: 3
D - Dirt                 Coins Collected: 0
P - Pit
C - Coin
-------------------------------------------
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | X
--+---+---+---+---+---+---+---+---+---+---+
A | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
B | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
C | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
D | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
E | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
F | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
G | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
H | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
I | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
J | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
Y

Enter Coordinate To Check(Y,X): D,3
```

### frame 2

```
Coin Collector Prototype v1.0
S - Stone                Lives Remaining: 3
D - Dirt                 Coins Collected: 0
P - Pit
C - Coin
-------------------------------------------
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | X
--+---+---+---+---+---+---+---+---+---+---+
A | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
B | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
C | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
D | S | S | S | D | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
E | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
F | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
G | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
H | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
I | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
J | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
Y

Enter Coordinate To Check(Y,X): G,5
```

### frame 3

```
Coin Collector Prototype v1.0
S - Stone                Lives Remaining: 3
D - Dirt                 Coins Collected: 0
P - Pit
C - Coin
-------------------------------------------
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | X
--+---+---+---+---+---+---+---+---+---+---+
A | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
B | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
C | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
D | S | S | S | D | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
E | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
F | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
G | S | S | S | S | S | C | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
H | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
I | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
J | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
Y

Enter Coordinate To Check(Y,X): G,5
```

### frame 4

```
Coin Collector Prototype v1.0
S - Stone                Lives Remaining: 3
D - Dirt                 Coins Collected: 1
P - Pit
C - Coin
-------------------------------------------
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | X
--+---+---+---+---+---+---+---+---+---+---+
A | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
B | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
C | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
D | S | S | S | D | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
E | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
F | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
G | S | S | S | S | S | D | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
H | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
I | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
J | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
Y

Enter Coordinate To Check(Y,X): I,8
```

### frame 5

```
Coin Collector Prototype v1.0
S - Stone                Lives Remaining: 2
D - Dirt                 Coins Collected: 1
P - Pit
C - Coin
-------------------------------------------
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | X
--+---+---+---+---+---+---+---+---+---+---+
A | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
B | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
C | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
D | S | S | S | D | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
E | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
F | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
G | S | S | S | S | S | D | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
H | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
I | S | S | S | S | S | S | S | S | P | S |
--+---+---+---+---+---+---+---+---+---+---+
J | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
Y

Enter Coordinate To Check(Y,X): H,2
```

### frame 6

```
Coin Collector Prototype v1.0
S - Stone                Lives Remaining: 1
D - Dirt                 Coins Collected: 1
P - Pit
C - Coin
-------------------------------------------
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | X
--+---+---+---+---+---+---+---+---+---+---+
A | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
B | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
C | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
D | S | S | S | D | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
E | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
F | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
G | S | S | S | S | S | D | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
H | S | S | P | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
I | S | S | S | S | S | S | S | S | P | S |
--+---+---+---+---+---+---+---+---+---+---+
J | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
Y

Enter Coordinate To Check(Y,X): H,3
```

### frame 7


```
Coin Collector Prototype v1.0
S - Stone                Lives Remaining: 0
D - Dirt                 Coins Collected: 1
P - Pit
C - Coin
-------------------------------------------
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | X
--+---+---+---+---+---+---+---+---+---+---+
A | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
B | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
C | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
D | S | S | S | D | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
E | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
F | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
G | S | S | S | S | S | D | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
H | S | S | P | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
I | S | S | S | S | S | S | S | S | P | S |
--+---+---+---+---+---+---+---+---+---+---+
J | S | S | S | S | S | S | S | S | S | S |
--+---+---+---+---+---+---+---+---+---+---+
Y

*** G A M E  O V E R ***
Play Again? (Y/N) N
user@host~$
```