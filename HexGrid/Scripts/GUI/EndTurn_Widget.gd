extends VBoxContainer

# Defines if the time is running, ie if the TimerBar progresses each tick 
var is_time_running = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_time_running:
		$TimerBar.value += delta # Timer progression

func reset(is_my_turn, turn_time):
	## Resets the timer, and disable the button if it is not the player's turn
	$Button.disabled = not is_my_turn
	$TimerBar.max_value = turn_time
	$TimerBar.value = 0
	is_time_running = true
