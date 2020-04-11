extends Spatial

var Character = preload("res://Scenes/Character.tscn")
var character_1 = null

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	prepare()
	draw_a_line()
	
func prepare():
	var cells_floor = $Map.get_cells_kind('floor')
	var cell = cells_floor[rng.randi_range(0, len(cells_floor))]
#	var cell = $Map.get_cell_coord([3,-3], 'oddr')
	character_1 = Character.instance()
	character_1.init(cell)
	add_child(character_1)

func draw_a_line():
	var cells_floor = $Map.get_cells_kind('floor')
	var cell = cells_floor[rng.randi_range(0, len(cells_floor))]
	var path = $Map.draw_line(character_1.current_cell, cell)
	for c in path:
		c.change_material(Global.materials['clicked'])
	path[0].change_material(Global.materials['team_blue'])
	path[-1].change_material(Global.materials['team_blue'])

