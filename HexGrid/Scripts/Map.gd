extends Spatial

var CellSize1 = preload("res://Scenes/CellSize1.tscn")
var CellSize2 = preload("res://Scenes/CellSize2.tscn")
var CellSize3 = preload("res://Scenes/CellSize3.tscn")
var CellSize4 = preload("res://Scenes/CellSize4.tscn")
var CellSize5 = preload("res://Scenes/CellSize5.tscn")

var rng = RandomNumberGenerator.new()
var grid = {}
var last_mouse_position = Vector2(-1, -1)

const PROBA_CELL_FULL = 0.1
const PROBA_CELL_HOLE = 0.1
const LENGTH_BORDER = 8
const RAY_ARENA = 6
const RAY = LENGTH_BORDER + RAY_ARENA

func _ready():
	rng.randomize()
	generate_grid()
	instance_map()
	
func _process(_delta):
	var mouse_position = get_viewport().get_mouse_position()
	if is_rotation_camera_ask(mouse_position):
		rotate_camera(mouse_position)
	last_mouse_position = mouse_position
	
func distance_coord(q1, r1, q2, r2):
	return (abs(q1 - q2) 
		  + abs(q1 + r1 - q2 - r2)
		  + abs(r1 - r2)) / 2

func random_kind():
	var value = rng.randf()
	var lim = PROBA_CELL_FULL
	if value  < lim:
		return 'full'
	lim += PROBA_CELL_HOLE
	if value < lim:
		return 'hole'
	return 'floor'
	
func generate_one_line(line_size, r):
	var kind = ''
	var half = line_size / 2 if (line_size / 2.0)  == (line_size / 2) else (line_size / 2 + 1)
	var q = -RAY -r if r <= 0 else -RAY
	# first part : random
	for i in range(half):
		if distance_coord(q, r, 0, 0) > RAY_ARENA:
			kind = 'border'
		else:
			kind = random_kind()
		add_instance_to_grid(kind, q, r)
		if line_size / 2.0 == line_size / 2 or i + 1 != half :
			add_instance_to_grid(kind, line_size - 2*i + q - 1, r)
		q += 1

func generate_grid():
	var nb_cell = RAY + 1
	for r in range(-RAY, 0) :
		generate_one_line(nb_cell, r)
		nb_cell += 1
	for r in range(RAY + 1) :
		generate_one_line(nb_cell, r)
		nb_cell -= 1

func instance_cell(cell_type, q, r, kind):
	var cell = cell_type.instance()
	cell.init(q, r, kind)
	add_child(cell)

func add_instance_to_grid(instance, q, r):
	if not q in grid.keys():
		grid[q] = {}
	grid[q][r] = instance
	
func instance_map():
	for q in grid.keys():
		for r in grid[q].keys():
			var kind = grid[q][r]
			if kind == 'hole':
				instance_cell(CellSize1, q, r, kind)
			elif kind == 'floor': 
				instance_cell(CellSize2, q, r, kind)
			elif kind == 'full':
				instance_cell(CellSize3, q, r, kind)
			elif kind == 'border':
				var height = rng.randi() % 3
				var choices = {0: CellSize3, 1: CellSize4, 2:CellSize5}
				instance_cell(choices[height], q, r, kind)



func rotate_camera(mouse_position):
	if last_mouse_position != Vector2(-1, -1):
		var center_screen = get_viewport().size/2
		var vect_last = center_screen - last_mouse_position
		var vect_current = center_screen - mouse_position
		var angle = vect_current.angle_to(vect_last)
		$Origin.rotate_y(-angle)
		
func is_rotation_camera_ask(mouse_position):
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) and mouse_position != last_mouse_position:
		return true
	return false



#func get_cells_kind(kind):
#	var cells = []
#	for line in grid :
#		for c in line :
#			if c.kind == kind:
#				cells += [c]
#	return cells
#	pass
