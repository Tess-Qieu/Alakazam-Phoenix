extends Spatial

var Character = preload("res://Scenes/Character.tscn")
var team_blue = []
var team_red = []
var current_character

var state = 'normal'

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	create_character('blue')
	create_character('red')
	current_character = team_blue[0]
	current_character.cast_spell(team_red[0].current_cell)
	
func create_character(team):
	var cell = $Map.cells_floor[rng.randi_range(0, len($Map.cells_floor)-1)]
	var character = Character.instance()
	character.init(cell, team)
	character.connect("character_selected", self, "_on_character_selected", [character])
	add_child(character)
	
	if team == 'blue':
		team_blue += [character]
	elif team == 'red':
		team_red += [character]

func _on_character_selected(character):
	current_character = character
	$Map.clear()

func _on_ButtonSpell_pressed():
	$Map.clear()
	var _fov = $Map.display_field_of_view(current_character.current_cell, 20)
	state = 'cast_spell'

func _on_ButtonClear_pressed():
	$Map.clear()
	
func _on_cell_clicked(cell):
	if state == 'normal':
		$Map.clear()
		$Map.display_field_of_view(cell, 25)
		cell.change_material('blue')
		print(cell.translation)
	
	elif state == 'cast_spell':
		current_character.cast_spell(cell)
