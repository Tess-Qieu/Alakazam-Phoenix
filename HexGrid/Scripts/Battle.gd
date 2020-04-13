extends Spatial

var Character = preload("res://Scenes/Character.tscn")
var team_blue = []
var team_red = []
var current_character

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	create_character('blue')
	create_character('red')
	current_character = team_blue[0]
	_color_current_character_cell()
	$Map.connect("a_cell_hovered", self, "_on_a_cell_hovered")
	$Map.connect("a_cell_clicked", self, "_on_a_cell_clicked")
	
func create_character(team):
	var cell = $Map.cells_floor[rng.randi_range(0, len($Map.cells_floor))]
	var character = Character.instance()
	character.init(cell, team)
	character.connect("character_selected", self, "_on_character_selected", [character])
	add_child(character)
	
	if team == 'blue':
		team_blue += [character]
	elif team == 'red':
		team_red += [character]

func _color_current_character_cell():
	if (current_character in team_blue):
		current_character.current_cell.change_material('blue')
	elif (current_character in team_red):
		current_character.current_cell.change_material('red')
	else:
		current_character.current_cell.change_material('green')

func _on_character_selected(character):
	if not current_character.casting:
		$Map.clear()
		
		current_character = character
		_color_current_character_cell()

func _on_ButtonSpell_toggled(button_pressed):
	$Map.clear()
	
	current_character.casting = button_pressed
	if button_pressed:
		var fov = $Map.display_field_of_view(current_character.current_cell, 20)
	
	_color_current_character_cell()

func _on_ButtonClear_pressed():
	$Map.clear()
	_color_current_character_cell()

func _on_a_cell_hovered(active, cell):
	if not current_character.casting:
		$Map.clear()
		_color_current_character_cell()
		
		if active:
			$Map.draw_path(current_character.current_cell, cell)

func _on_a_cell_clicked(cell):
	if not current_character.casting and cell != null:
		$Map.clear()
#		current_character.teleport_to(cell)
		current_character.move_to(cell)
		_color_current_character_cell()
