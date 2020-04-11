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
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2

func add_instance_to_grid(instance, q, r):
	if not q in grid.keys():
		grid[q] = {}
	grid[q][r] = instance

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
	add_instance_to_grid(cell, q, r)

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





func next_cell_on_line(i, j, cell):
	var row
	var col
	if i == -1 and j == -1 :
		col = cell.col-1 if cell.row%2==0 else cell.col
		row = cell.row-1
	elif i == -1 and j == 1 :
		col = cell.col-1 if cell.row%2==0 else cell.col
		row = cell.row+1
	elif i == 0 and j == -1 :
		col = cell.col-1
		row = cell.row
	elif i == 0 and j == 1 :
		col = cell.col + 1
		row = cell.row
	elif i == 1 and j == -1 :
		col = cell.col+1 if cell.row%2==1 else cell.col
		row = cell.row-1
	elif i == 1 and j == 1 :
		col = cell.col if cell.row%2==0 else cell.col+1
		row = cell.row+1
	return get_cell_coord([col, row], 'oddr')
	
func draw_line(start, end):
	# Compute the path between two cells : start and end.
	var path = []
	var deltaX = 2*(end.col - start.col) + abs(end.row%2) - abs(start.row%2)
	var deltaY = end.row - start.row
	var xSign = -1 if deltaX < 0 else 1
	var ySign = -1 if deltaY < 0 else 1
	var gammaX = abs(deltaX)
	var gammaY = abs(deltaY)
	var epsilon = -2*gammaX
	var currentCell = start
	path += [currentCell]
	while not currentCell == end :
		if epsilon >= 0 :
			currentCell = next_cell_on_line(-1*xSign, ySign, currentCell)
			epsilon = epsilon - 3*gammaX -3*gammaY
		else :
			epsilon += 3*gammaY
			if epsilon > -1*gammaX :
				currentCell = next_cell_on_line(xSign, ySign, currentCell)
				epsilon -= 3*gammaX
			else :
				if epsilon < -3*gammaX :
					currentCell = next_cell_on_line(xSign, -1*ySign, currentCell)
					epsilon += 3*gammaX
				else :
					currentCell = next_cell_on_line(0, xSign, currentCell)
					epsilon += 3*gammaY
		if currentCell == null:
			print('ERROR: cell does not exist.')
			return path
		path += [currentCell]
	return path

func get_cells_kind(kind):
	var cells = []
	for q in grid.keys():
		for r in grid[q].keys():
			if grid[q][r].kind == kind:
				cells += [grid[q][r]]
	return cells

func get_cell_coord(coord, coord_type = 'axial'):
	for q in grid.keys():
		for r in grid[q].keys():
			var cell = grid[q][r]
			if coord_type == 'axial':
				if q == coord[0] and r == coord[1]:
					return cell
			elif coord_type == 'cube':
				if cell.x == coord[0] and cell.y == coord[1] and cell.z == coord[2]:
					return cell
			elif coord_type == 'oddr':
				if cell.col == coord[0] and cell.row == coord[1]:
					return cell
	return null
