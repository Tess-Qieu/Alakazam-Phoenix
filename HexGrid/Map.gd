extends Spatial

var Cell_White = preload("res://Prefabs/Cell/Cell_White/Cell_White.tscn")
var Cell_Grey = preload("res://Prefabs/Cell/Cell_Grey/Cell_Grey.tscn")

var rng = RandomNumberGenerator.new()
var grid = []
var last_mouse_position = Vector2(-1, -1)

const PROBA_CELL_FULL = 0.15
const PROBA_CELL_HOLE = 0.15
const RAY = 6

const LENGTH_BORDER = 1
const BORDER_HEIGHT = 3

func _ready():
	rng.randomize()
	generate_grid()
	generate_bordered_grid()
	instance_map()
	
func _process(_delta):
	var mouse_position = get_viewport().get_mouse_position()
	if is_rotation_camera_ask(mouse_position):
		rotate_camera(mouse_position)
	last_mouse_position = mouse_position

func random_kind():
	var value = rng.randf()
	var lim = PROBA_CELL_FULL
	if value  < lim:
		return 'full'
	lim += PROBA_CELL_HOLE
	if value < lim:
		return 'hole'
	return 'floor'
	
func generate_one_line(line_size, q, r):
	var kind = ''
	var half = line_size / 2 if (line_size / 2.0)  == (line_size / 2) else (line_size / 2 + 1)
	for _i in range(half):
		kind = random_kind()
		grid[r + RAY] += [{'q': q, 'r': r, 'kind': kind}]
		q += 1
		
	var indice_to_copy = half - 1
	if line_size - half != half:
		indice_to_copy -= 1
		
	for _i in range(half, line_size):
		kind = grid[r + RAY][indice_to_copy]['kind']
		grid[r + RAY] += [{'q':q, 'r':r, 'kind':kind}]
		indice_to_copy -= 1
		q += 1

func generate_grid():
	var nb_cell = RAY + 1
	var q = 0
	var r = -RAY
	for _i in range(RAY) :
		grid += [[]]
		generate_one_line(nb_cell, q, r)
		nb_cell += 1
		r += 1
		q = -RAY -r
	for _i in range(RAY + 1) :
		self.grid += [[]]
		generate_one_line(nb_cell, q, r)
		r += 1
		q = -RAY
		nb_cell -= 1

func generate_bordered_line(line):
	var new_line = []
	var r = line[0]['r']
	var q
	for i in range(1, LENGTH_BORDER + 1):
		q = line[0]['q'] - i
		new_line += [{'q': q, 'r': r, 'kind': 'border'}]
	new_line += line
	for i in range(1, LENGTH_BORDER + 1):
		q = line[-1]['q'] + i
		new_line += [{'q': q, 'r': r, 'kind': 'border'}]
	return new_line

func generate_bordered_grid():
	var grid_bordered = []
	
	# Create lines borders in r
	var r = grid[0][0]['r']
	var q
	var line_length
	var new_line = []
	for i in range(1, LENGTH_BORDER + 1):
		r -= 1
		new_line = []
		line_length = len(grid[0]) - i + 2*LENGTH_BORDER
		for j in line_length:
			q = -LENGTH_BORDER + j + 1
			new_line += [{'q': q, 'r': r, 'kind': 'border'}]
		grid_bordered += [new_line]
	
	r = grid[-1][0]['r']
	for i in range(1, LENGTH_BORDER+1):
		r += 1
		new_line = []
		line_length = len(grid[-1]) - i + 2*LENGTH_BORDER
		for j in line_length:
			q = -LENGTH_BORDER -RAY + j
			new_line += [{'q': q, 'r': r, 'kind': 'border'}]
		grid_bordered += [new_line]
		
	# Add border to lines in q
	for line in grid :
		grid_bordered += [generate_bordered_line(line)]
	grid = grid_bordered

func instance_cell(cell_type, q, r, kind, height=1):
	for i in range(height):
		var cell = cell_type.instance()
		cell.init(q, r, kind, i)
		add_child(cell)

func instance_map():
	for line in grid:
		for c in line:
			var q = c['q']
			var r = c['r']
			var kind = c['kind']
			
			if kind == 'hole':
				pass
			elif kind == 'floor': 
				instance_cell(Cell_White, q, r, kind)
			elif kind == 'full':
				instance_cell(Cell_Grey, q, r, kind, 2)
			elif kind == 'border':
				var height = rng.randi() % BORDER_HEIGHT + 2
				instance_cell(Cell_Grey, q, r, kind, height)

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
