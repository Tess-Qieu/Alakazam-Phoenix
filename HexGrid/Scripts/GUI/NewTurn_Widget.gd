extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func configure(team:Team, is_player_turn):
	$Control/TeamTurn_Label.text = team.name
	# TODO: Start button shall be deactivated if the playing team is not the player's team
	$Control/StartButton.visible = is_player_turn
	show()
