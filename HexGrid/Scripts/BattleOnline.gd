extends 'res://Scripts/Battle.gd'



func _ready():
	pass
	
## ASK PLAY TO SERVER
func _on_ask_move(character, path):
	if not is_my_turn :
		# Client should not send ask for a play if it's not his turn to play
		return
		
	var data = {'action': 'game',
				'ask': 'move', 
				'details': {'id character' : character.id_character,
							'path' : path,
							}}
	send_data(data)

func _on_ask_cast_spell(thrower, target): # for now, useless to precise which spell to use
	# thrower is the character which cast the spell
	# target is the cell where the spelle is cast
	if not is_my_turn :
		# Client should not send ask for a play if it's not his turn to play
		return
	
	var data = {'action': 'game',
				'ask': 'cast spell',
				'details': {'thrower': {'id character': thrower.id_character},
							'target': [target.q, target.r]
							}
				}
	send_data(data)

func _on_end_turn_asked():
	## Request from the client to the server to end his turn before 
	#   the timer's end
	if not is_my_turn or $BattleScreen/Battle.state != 'normal':
		# Client should not ask to end his turn if it's not his turn to play
		#  of if the Battle is still busy
		return
	
	var data = {'action': 'game',
				'ask': 'end turn',
				'details': {}}
	
	send_data(data)

