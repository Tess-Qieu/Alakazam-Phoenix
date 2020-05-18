extends Control

var menu = preload('res://Scenes/Menu/MainMenu.tscn')


func _ready():
	get_tree().change_scene_to(menu)
#	Network.connect_to_server()
	
	






