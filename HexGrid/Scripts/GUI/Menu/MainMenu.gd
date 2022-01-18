extends Control

onready var local_bt  = $Visual_components/VBoxContainer2/HBoxContainer/Local_Button
onready var online_bt = $Visual_components/VBoxContainer2/HBoxContainer/Online_Button
onready var name_box  = $Visual_components/Name_Container/Name_Selector

# Called when the node enters the scene tree for the first time.
func _ready():
	# Background animation 
	$Spatial/AnimationPlayer.play("round")
	# Connection of name validation
	# warning-ignore:return_value_discarded
	name_box.connect("text_changed", self, "_name_selection")
	# Start local game connection
	# warning-ignore:return_value_discarded
	local_bt.connect("pressed", self, "_goto_local_game")
	# Start online game connection
	# warning-ignore:return_value_discarded
	online_bt.connect("pressed", self, "_goto_online_game")

func _name_selection(new_text):
	Global.pseudo = new_text
	
func _goto_local_game():
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(Global.BattleOffline)

func _goto_online_game():
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(Global.WaitingLobby)
