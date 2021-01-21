extends VBoxContainer


func _ready():
	#While the timer is not reset, it does not progress
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TimerBar.value += delta # Timer progression

func reset(is_my_turn, turn_time):
	## Resets the timer, and disable the button if it is not the player's turn
	$ButtonEndTurn.disabled = not is_my_turn
	$TimerBar.max_value = turn_time
	$TimerBar.value = 0
	set_process(true)
