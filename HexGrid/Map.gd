extends Spatial

var Cell_White = preload("res://Prefabs/Cell/Cell_White/Cell_White.tscn")
var Cell_Grey = preload("res://Prefabs/Cell/Cell_Grey/Cell_Grey.tscn")

var rng = RandomNumberGenerator.new()
var grid = []
var is_button_right_pressed

# Array of selected cells
var selected_cells = []

const PROBA_CELL_FULL = 0.15
const PROBA_CELL_HOLE = 0.15
const RAY = 6

const SPEED_DECREASE = 20000


func _ready():
	rng.randomize()
	generate_grid()
	instance_map()
	selected_cells.resize(2)

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
	return q

func generate_grid():
	var nb_cell = RAY + 1
	var q = 0
	var r = -RAY
	for _i in range(RAY) :
		grid += [[]]
		q = generate_one_line(nb_cell, q, r)
		nb_cell += 1
		r += 1
		q = -RAY -r
	for _i in range(RAY + 1) :
		self.grid += [[]]
		q = generate_one_line(nb_cell, q, r)
		r += 1
		q = -RAY
		nb_cell -= 1

func instance_cell(cell_type, q, r, kind, height=0):
	var cell = cell_type.instance()
	cell.init(q, r, kind, height)
	add_child(cell)
	if cell.kind == "floor":
		cell.connect("selected", self, "selected_cell", [cell])
	
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
				instance_cell(Cell_Grey, q, r, kind)
				instance_cell(Cell_Grey, q, r, kind, 1)

# Function memorizing the selected tile and unselecting the previous
func selected_cell(index, cell):
	if selected_cells.size() > index:
		if selected_cells[index] != null:
			selected_cells[index].unselect()
			
		selected_cells[index] = cell

func _on_Floor_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	# Rotate the view around the Origin(0,0)
	
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) and event is InputEventMouseMotion:
		var center_screen = get_viewport().size/2
		var mouse_position = get_viewport().get_mouse_position()
		var ratio = 1.1 
		if event.speed.y != 0 :
			ratio = event.speed.x / event.speed.y # if > 1 move along x, else along y
		
		if mouse_position.x < center_screen.x:
			if mouse_position.y < center_screen.y:
				# up left
				if ratio < 1:
					$Origin.rotate_y(-event.speed.y/SPEED_DECREASE)
				else :
					$Origin.rotate_y(event.speed.x/SPEED_DECREASE)
			else:
				# down left
				if ratio < 1:
					$Origin.rotate_y(-event.speed.y/SPEED_DECREASE)
				else:
					$Origin.rotate_y(-event.speed.x/SPEED_DECREASE)
		else:
			if mouse_position.y < center_screen.y:
				# up right
				if ratio < 1:
					$Origin.rotate_y(event.speed.y/SPEED_DECREASE)
				else:
					$Origin.rotate_y(event.speed.x/SPEED_DECREASE)
			else:
				if ratio < 1:
					$Origin.rotate_y(event.speed.y/SPEED_DECREASE)
				else:
					$Origin.rotate_y(-event.speed.x/SPEED_DECREASE)

