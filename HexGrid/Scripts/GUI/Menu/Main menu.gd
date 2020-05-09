extends Control

var localGame = preload("res://Scenes/BattleScreen.tscn")
var onlineGame = preload("res://Scenes/Game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Background animation 
	$Spatial/AnimationPlayer.play("round")
	
	# Connection of name validation
	$VBoxContainer/Name_Selector.connect("text_entered", self, "_name_selection")
	# Start local game connection
	$HBoxContainer/Local_Button.connect("pressed", self, "_goto_local_game")
	# Start online game connection
	$HBoxContainer/Online_Button.connect("pressed", self, "_goto_online_game")

func _name_selection(new_text):
	# /!\ temporary print, should be used to save player's name 
	print ("Hello " + new_text)

func _goto_local_game():
	get_tree().change_scene_to(localGame)

func _goto_online_game():
	get_tree().change_scene_to(onlineGame)
