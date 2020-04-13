extends Spatial


var Character = preload("res://Scenes/Character.tscn")
var team_blue = []
var team_red = []
var current_character

var state = 'normal'
var fov = []

var rng = RandomNumberGenerator.new()

# Handle initialization
func _ready():
	create_character('blue')
	create_character('red')
	current_character = team_blue[0]
	clear_arena()

# Handle Character
func create_character(team):
	var cell = $Map.cells_floor[rng.randi_range(0, len($Map.cells_floor)-1)]
	var character = Character.instance()
	character.init(cell, team)
	character.connect("character_selected", self, "_on_character_selected", [character])
	character.connect("character_arrived", self, "_on_character_arrived")
	add_child(character)
	
	if team == 'blue':
		team_blue += [character]
	elif team == 'red':
		team_red += [character]

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



func _on_character_arrived():
	state = 'normal'
	clear_arena()
	
# On object clicked
func _on_character_selected(character):
	if not state == 'cast_spell':
		# select character
		current_character = character
		clear_arena()
	else:
		make_current_character_cast_spell(character.current_cell)

func _on_cell_clicked(cell):
	if state == 'normal':
#		current_character.teleport_to(cell)
#		for elt in $Map.compute_path(current_character.current_cell, cell):
#			current_character.move_to(elt)
		var path = $Map.compute_path(current_character.current_cell, cell)
		path.append(cell)
		current_character.set_path(path)
		state = 'moving'
	
	elif state == 'cast_spell':
		make_current_character_cast_spell(cell)



# On object hovered
func _on_cell_hovered(cell):
	if state == 'normal':
		clear_arena()
		$Map.draw_path(current_character.current_cell, cell)

func _on_cell_unhovered(_cell):
	# useless for now, may have some interest later 
	pass
