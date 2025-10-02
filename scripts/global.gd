extends Node

## Emitted from [HUD] when it is added to the scene
@warning_ignore("unused_signal")
signal hud_added

signal score_changed
signal goal_scored(ball: Node2D, player: Player)
signal game_over(ball: Node2D, loser: Player)
signal respawn_ball(ball: Node2D, player: Player)

enum Player { LEFT, RIGHT, BOTH }

## Stores the score for each player.
var score = {
	Player.LEFT: 0,
	Player.RIGHT: 0,
}


# Initialize the score to 0 to set it back from the previous mode
func initialise_score():
	score[Player.RIGHT] = 0
	score[Player.LEFT] = 0
	# Emit the UI to update the score 
	# according to the score.Player.LEFT/RIGHT
	score_changed.emit()
	
func initialize_game_over(ball: Node2D,loser: Player):
	game_over.emit(ball, loser)

func score_goal(ball: Node2D, player: Player):
	goal_scored.emit(ball, player)

func respawn_ball_from_game_over(ball: Node2D, player: Player):
	respawn_ball.emit(ball, player)

func add_score(player: Player, value: int):
	if player == Player.BOTH:
		score[Player.RIGHT] += value
		score[Player.LEFT] += value
	else:
		score[player] += value
	score_changed.emit()
