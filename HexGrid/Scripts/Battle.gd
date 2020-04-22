extends Spatial

signal ask_move
signal ask_cast_spell


var Character = preload("res://Scenes/Character.tscn")
var team_blue = []
var team_red = []
var current_character

var state = 'normal' # ['normal', 'cast_spell', 'movement']
var fov = []
var path = []

var rng = RandomNumberGenerator.new()



## INITIALISATION ##
func init(grid, team_blue_settings, team_red_settings, node_battlenetwork):
	# Instanciate map and characters
	$Map.instance_map(grid)
	_create_team('blue', team_blue_settings)
	_create_team('red', team_red_settings)
	
	current_character = team_blue[0]
	clear_arena()
	
	# warning-ignore:return_value_discarded		
	connect('ask_move', node_battlenetwork, '_on_ask_move')
	# warning-ignore:return_value_discarded
	connect('ask_cast_spell', node_battlenetwork, '_on_ask_cast_spell')
	






## CHARACTER CREATION/UPDATE ##
func _create_team(team_name, data):
	for c in data:
		var character = _create_character(team_name, 
										c['q'], 
										c['r'],
										c['id_character'],
										c['health'], 
										c['range displacement'])
		if team_name == 'blue':
			team_blue += [character]
		elif team_name == 'red':
			team_red += [character]

func _create_character(team, q, r, id_character, health, range_displacement):
	var cell = $Map.grid[q][r]
	var character = Character.instance()
	character.init(cell, team, id_character, health, range_displacement, self)
	
	_update_character_cell_references(character, cell)
	add_child(character)
	return character

func _update_character_cell_references(character, new_cell):
	## Update references from cell to character and from character to cell
	
	# if the character had a cell reference
	if character.current_cell != null:
		# The previous cell forgets the character reference 
		#  and gets back to floor kind
		character.current_cell.character_on = null
		character.current_cell.kind = 'floor'
	
	# The character's new cell reference and kind are update
	character.current_cell = new_cell
	new_cell.kind = 'blocked'
	# The new cell gets a reference to the player on it
	new_cell.character_on = character

func _on_character_die(character):
	character.die(self)






## MAKE MOVE/SPELL##
func _make_current_character_move_one_step():
	# Movement limitation
	state = 'moving'
	current_character.move_to(path.pop_front())

# this function may end in battle_screen
func make_character_move_following_path_valid(character, path_valid):
	# Movement limitation
	current_character = character
	path = []
	for coord in path_valid:
		path += [$Map.grid[coord[0]][coord[1]]]
	_make_current_character_move_one_step()
	

func make_current_character_cast_spell(cell):
	# if cell in fov, cast spell, else cancel spell casting
	if cell in fov:
		current_character.cast_spell(cell)
	fov = []
	clear_arena()
	state = 'normal'

func make_character_cast_spell(character, cell):
	character.cast_spell(cell)
	fov = []
	clear_arena()
	state = 'normal'





## CLEAR ##
func _color_current_character_cell():
	if (current_character in team_blue):
		current_character.current_cell.change_material('blue')
	elif (current_character in team_red):
		current_character.current_cell.change_material('red')
	else:
		current_character.current_cell.change_material('green')

func clear_arena():
	$Map.clear()
	_color_current_character_cell()









## ANIMATION EVENTS ##
func _on_character_movement_finished(character, ending_cell):
	_update_character_cell_references(character, ending_cell)
	if path.size() == 0:
		state = 'normal'
		clear_arena()
	else:
		_make_current_character_move_one_step()





## OBJECT CLICKED EVENTS ##
func _on_character_selected(character):
	if not state == 'cast_spell':
		# select character
		current_character = character
		clear_arena()
	else:
		emit_signal('ask_cast_spell', current_character, character.current_cell) # for now there is only one spell
#		make_current_character_cast_spell(character.current_cell)


func _on_cell_clicked(cell):
	if state == 'normal':
		if len(path) > 0 :
			emit_signal('ask_move', current_character, path)
#			_make_current_character_move_one_step()
	elif state == 'cast_spell':
		if cell in fov:
			emit_signal('ask_cast_spell', current_character, cell) # for now there is only one spell
#		make_current_character_cast_spell(cell)






## OBJECT HOVERED EVENTS ##
func _on_cell_hovered(cell):
	if state == 'normal':
		clear_arena()
		path = $Map.display_path(current_character.current_cell, 
								cell, 
								current_character.current_range_displacement)
	
func _on_character_hovered(character):
	if state == 'normal':
		clear_arena()
		$Map.display_displacement_range(character.current_cell, 
										character.current_range_displacement)




## USEFULL FUNCTIONS ##
func get_character_by_id(id_character):
	for character in team_red + team_blue:
		if character.id_character == id_character:
			return character
	return null

func get_cell_by_coords(q, r):
	return $Map.grid[q][r]
