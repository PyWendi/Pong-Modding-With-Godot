@tool
class_name HUD
extends CanvasLayer

## The color of the scores and middle line.
@export var color: Color = Color.WHITE:
	set = _set_color

## The size of the score numbers.
@export_range(50, 500, 1) var font_size: float = 200.0:
	set = _set_font_size

## Select a system font to replace the default one.
@export var font: SystemFont:
	set = _set_font

@onready var _score_labels = {
	Global.Player.LEFT: %PlayerLeftScore,
	Global.Player.RIGHT: %PlayerRightScore,
}

@onready var game_over_label = $%GameOverTexte
@onready var game_over_timer_label = %SecondBeforeRestart
@export var seconds_before_restart:int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	game_over_label.hide()
	game_over_timer_label.hide()
	
	Global.hud_added.emit()
	Global.score_changed.connect(_on_score_changed)
	Global.game_over.connect(_show_game_over_text)


func _on_score_changed():
	set_players_scores(Global.score[Global.Player.LEFT], Global.score[Global.Player.RIGHT])

# Show the game over texte
func _show_game_over_text(ball: Node2D, player : Global.Player):
	# Show then hide the text, and call for ball respawn after  few seconds
	var game_over_text = "Right Player Lose !"
	if player == Global.Player.LEFT:
		game_over_text = "Left Player Lose !"
	if player == Global.Player.BOTH:
		game_over_text = "Both Player Lose !"
	game_over_label.text = game_over_text
	game_over_label.show()
	game_over_timer_label.show()
	
	#Show second cooldown
	for i in range(seconds_before_restart, 0, -1):
		game_over_timer_label.text = "The game restarts after " + str(i) + "s."
		await get_tree().create_timer(1).timeout

	game_over_label.text = ""
	game_over_timer_label.text = ""
	game_over_label.hide()
	game_over_timer_label.hide()
	Global.respawn_ball_from_game_over(ball, player)

func _set_font_size(new_font_size: float):
	font_size = new_font_size
	if not is_node_ready():
		await ready
	for label: Label in _score_labels.values():
		label.add_theme_font_size_override("font_size", roundi(font_size))
		# Adjust the pivot to the new size:
		label.pivot_offset = Vector2(240.0, 176.0 * font_size / 200.0)


func _set_font(new_font: SystemFont):
	font = new_font
	if not is_node_ready():
		await ready
	for label: Label in _score_labels.values():
		label.add_theme_font_override("font", font)


func _set_color(new_color: Color):
	if not is_node_ready():
		await ready
	color = new_color
	%Lines.modulate = color
	for label in _score_labels.values():
		label.add_theme_color_override("font_color", color)


## Sets the score for each player:
func set_players_scores(left_score: int, right_score: int):
	var left_text = _score_labels[Global.Player.LEFT].text
	if str(left_score) != left_text:
		_score_labels[Global.Player.LEFT].text = str(left_score)
		DampedOscillator.animate(
			_score_labels[Global.Player.LEFT], "rotation", 300.0, 7.0, -95.0, 0.5
		)
	var right_text = _score_labels[Global.Player.RIGHT].text
	if str(right_score) != right_text:
		_score_labels[Global.Player.RIGHT].text = str(right_score)
		DampedOscillator.animate(
			_score_labels[Global.Player.RIGHT], "rotation", 300.0, 7.0, 95.0, 0.5
		)
