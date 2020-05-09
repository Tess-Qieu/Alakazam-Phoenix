extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Background animation 
	$Spatial/AnimationPlayer.play("round")
	
	# Connection of name validation
	$VBoxContainer/Name_Selector.connect("text_entered", self, "_name_selection")

func _name_selection(new_text):
	# /!\ temporary print, should be used to save player's name 
	print ("Hello " + new_text)
