extends Spatial


var Character = preload("res://Scenes/Character.tscn")
var team_blue = []
var team_red = []
var current_character

var state = 'normal' # ['normal', 'cast_spell', 'movement']
var fov = []
var path = []

var rng = RandomNumberGenerator.new()


# Handle initialization
func _ready():
	create_character('blue')
	create_character('red')
	current_character = team_blue[0]
	clear_arena()



# Handle Character
func _set_cell_character_on(character, cell):
	# Update the cell so it has a reference to the character on
	if character.current_cell != null:
		character.current_cell.character_on = null
	cell.character_on = character
		
func create_character(team):
	var cell = $Map.cells_floor[rng.randi_range(0, len($Map.cells_floor)-1)]
	var character = Character.instance()
	character.init(cell, team, self)
	_set_cell_character_on(character, cell)
	add_child(character)
	
	if team == 'blue':
		team_blue += [character]
	elif team == 'red':
		team_red += [character]

func make_current_character_move_following_path():
	# Movement limitation
	state = 'moving'
	current_character.move_following_path(path)
	_set_cell_character_on(current_character, path[-1])

func make_current_character_cast_spell(cell):
	# if cell in fov, cast spell, else cancel spell casting
	if cell in fov:
		current_character.cast_spell(cell)
	fov = []
	clear_arena()
	state = 'normal'




# Handle clear
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






# Handle button events
func _on_ButtonSpell_pressed():
	clear_arena()
	fov = $Map.display_field_of_view(current_character.current_cell, 20)
	state = 'cast_spell'
	
func _on_ButtonClear_pressed():
	clear_arena()
	print(team_blue[0].current_health, ' : ', team_red[0].current_health)





# Handle waiting events
func _on_character_movement_finished():
	state = 'normal'
	clear_arena()





# Handle On object clicked
func _on_character_selected(character):
	if not state == 'cast_spell':
		# select character
		current_character = character
		clear_arena()
	else:
		make_current_character_cast_spell(character.current_cell)

func _on_cell_clicked(cell):
	if state == 'normal':
		if len(path) > 0 :
			make_current_character_move_following_path()
	elif state == 'cast_spell':
		make_current_character_cast_spell(cell)






# Handle On object hovered
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
