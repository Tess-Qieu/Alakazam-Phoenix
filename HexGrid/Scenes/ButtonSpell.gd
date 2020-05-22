extends Button

var battle = null

func _ready():
	battle = get_parent().get_parent().get_parent()


# warning-ignore:unused_argument
func _process(delta):
	if battle.memory_on_turn != null :
		# we have to wait until it receives informations from the server to be set
		if battle.is_my_turn :
			if battle.memory_on_turn['cast spell'][battle.current_character] :
				disabled = true
			else:
				disabled = false
