extends Control

var offlineGame = preload("res://Scenes/BattleOffline.tscn")
var onlineGame = null#preload("res://Scenes/BattleOnline.tscn")
var waitingScreen = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Background animation 
	$Spatial/AnimationPlayer.play("round")
	# Connection of name validation
	# warning-ignore:return_value_discarded
	$VBoxContainer/Name_Selector.connect("text_entered", self, "_name_selection")
	# Start local game connection
	# warning-ignore:return_value_discarded
	$HBoxContainer/Local_Button.connect("pressed", self, "_goto_local_game")
	# Start online game connection
	# warning-ignore:return_value_discarded
	$HBoxContainer/Online_Button.connect("pressed", self, "_goto_online_game")

func _name_selection(new_text):
	# /!\ temporary print, should be used to save player's name 
	print ("Hello " + new_text)

func _goto_local_game():
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(offlineGame)

func _goto_online_game():
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(onlineGame)
