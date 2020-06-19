extends Spatial

var Cell = preload("res://Scripts/Cell.gd")
var CellSize1 = preload("res://Scenes/Cells/CellSize1.tscn")
var CellSize2 = preload("res://Scenes/Cells/CellSize2.tscn")
var CellSize3 = preload("res://Scenes/Cells/CellSize3.tscn")
var CellSize4 = preload("res://Scenes/Cells/CellSize4.tscn")
var CellSize5 = preload("res://Scenes/Cells/CellSize5.tscn")

var rng = RandomNumberGenerator.new()
var grid = {}
var cells_floor = []
var last_mouse_position = Vector2(-1, -1)

const SELECTABLE_CELLS = ['floor', 'blocked']
const BLOCKING_VIEW = ['full', 'border']

const PROBA_CELL_FULL = 0.1
const PROBA_CELL_HOLE = 0.1
const LENGTH_BORDER = 8
const RAY_ARENA = 8
const RAY = LENGTH_BORDER + RAY_ARENA

# Littlest step the camera can do on the Zoom 3D Curve, on unit_offset
export var camera_sensibility = 0.05


func _ready():
	rng.randomize()



## HANDLE GRID GENERATION ##
func _random_kind():
	var value = rng.randf()
	var lim = PROBA_CELL_FULL
	if value  < lim:
		return 'full'
	lim += PROBA_CELL_HOLE
	if value < lim:
		return 'hole'
	return 'floor'
	
func _generate_one_gridline(line_size, r):
	var kind = ''
	var half = line_size / 2  if (line_size / 2.0)  == (line_size / 2) else (line_size / 2 + 1)
	var q = -RAY -r if r <= 0 else -RAY
	# first part : random
	for i in range(half):
		if distance_coord(q, r, 0, 0) > RAY_ARENA:
			kind = 'border'
		else:
			kind = _random_kind()
		_add_instance_to_grid(kind, q, r)
		if line_size / 2.0 == line_size / 2 or i + 1 != half :
			_add_instance_to_grid(kind, line_size - 2*i + q - 1, r)
		q += 1

func generate_grid():
	var nb_cell = RAY + 1
	for r in range(-RAY, 0) :
		_generate_one_gridline(nb_cell, r)
		nb_cell += 1
	for r in range(RAY + 1) :
		_generate_one_gridline(nb_cell, r)
		nb_cell -= 1


## HANDLE GRID INSTANCIATION
func _add_instance_to_grid(instance, q, r):
	if not q in grid.keys():
		grid[q] = {}
	grid[q][r] = instance
	
func _instance_cell(cell_type, q, r, kind):
	var cell = cell_type.instance()
	cell.init(q, r, kind, get_parent())
	add_child(cell)
	_add_instance_to_grid(cell, q, r)
	if kind in SELECTABLE_CELLS:
		cells_floor += [cell]

func instance_map(new_grid):
	grid = new_grid
	for q in grid.keys():
		for r in grid[q].keys():
			var kind = grid[q][r]
			if kind == 'hole':
				_instance_cell(CellSize1, q, r, kind)
			elif kind == 'floor' or kind == 'blocked': 
				_instance_cell(CellSize2, q, r, kind)
			elif kind == 'full':
				_instance_cell(CellSize3, q, r, kind)
			elif kind == 'border':
				var height = rng.randi() % 3
				var choices = {0: CellSize3, 1: CellSize4, 2:CellSize5}
				_instance_cell(choices[height], q, r, kind)





## HANDLE LINE SECTION
func _line_step(start : int, end : int, step : float) -> float:
	# Function used to calulate a step on a line	
	return start + (end-start)*step

func _compute_line(start, end):
	# Line calculation between two cells
	var line = []
	var N = distance_coord(start.q, start.r, end.q, end.r)
	
	#Addition of starting cell
	line.append(start)
	
	var r_float : float
	var q_float : float
	
	for i in range(1,N):
		# float coordinates calculation
		r_float = _line_step(start.r, end.r, float(i)/float(N))
		q_float = _line_step(start.q, end.q, float(i)/float(N))
		
		# Compute all r for that step
		var list_r = []
		if abs(fmod(r_float, 1)) == 0.5:
			list_r += [int(r_float - 0.5), int(r_float + 0.5)]
		else:
			list_r += [int(round(r_float))]
		
		# Compute all q for that step
		var list_q = []
		if abs(fmod(q_float, 1)) == 0.5:
			list_q += [int(q_float - 0.5), int(q_float + 0.5)]
		else:
			list_q += [int(round(q_float))]
		
		for q in list_q:
			for r in list_r:
				if grid[q][r] != null:
					line.append(grid[q][r])
	
	# Addition of ending cell
	line.append(end)
	return line

func display_line(cell_start, cell_end, color_key):
	var line = _compute_line(cell_start, cell_end)
	for cell in line:
		cell.change_material(color_key)
	return line


## HANDLE FIELD OF VIEW ##
func _compute_field_of_view(cell, max_dist, min_dist = 0):
	var cells_visible = []
	for target in cells_floor:
		var dist = distance_coord(cell.q, cell.r, target.q, target.r)
		if dist <= max_dist and dist >= min_dist :
			var line = _compute_line(cell, target)
			line += _compute_line(target, cell)
			
			var flag = true
			for c in line :
				if c.kind == 'full' or c.kind == 'border':
					flag = false
			if flag:
				cells_visible += [target]
				
	return cells_visible

func display_field_of_view(cell, max_dist, color_key, min_dist = 0):
	var cells_visible = _compute_field_of_view(cell, max_dist, min_dist)
	for c in cells_visible:
		c.change_material(color_key)
	return cells_visible

func is_in_fov(observer_cell, max_dist, target_cell, min_dist = 0):
	var fov = _compute_field_of_view(observer_cell, max_dist, min_dist)
	return target_cell in fov

func _compute_straight_lines_fov(cell_start, max_dist, min_dist = 0):
	## Computes a field of view composed of 6 straight lines
	# from a given cell and within a range of distance
	
	var cells = []
	## LINES COMPUTATION
	# coordinates structure : [one_line[min[q,r], max[q,r]]]
	var coords = [	[	[cell_start.q+min_dist, cell_start.r         ],
						[cell_start.q+max_dist, cell_start.r         ]	],
					[	[cell_start.q+min_dist, cell_start.r-min_dist],
						[cell_start.q+max_dist, cell_start.r-max_dist]	],
					[	[cell_start.q-min_dist, cell_start.r         ],
						[cell_start.q-max_dist, cell_start.r         ]	],
					[	[cell_start.q-min_dist, cell_start.r+min_dist],
						[cell_start.q-max_dist, cell_start.r+max_dist]	],
					[	[cell_start.q         , cell_start.r+min_dist],
						[cell_start.q         , cell_start.r+max_dist]	],
					[	[cell_start.q         , cell_start.r-min_dist],
						[cell_start.q         , cell_start.r-max_dist]	]	]
	
	## FOV STRAIGHT LINES
	# Each pair of coordinates represents the first and last cell of a line
	for c in coords:
		# line computation
		var current_line = _compute_line(grid[c[0][0]][c[0][1]], grid[c[1][0]][c[1][1]])
		# The visibility of each cell is tested
		for cell in current_line:
			var view_line = _compute_line(cell_start, cell)
			view_line += _compute_line(cell, cell_start)
			
			var visible = true
			for elt in view_line:
				if elt.kind in BLOCKING_VIEW:
					visible = false
					
			if visible and cell.kind in SELECTABLE_CELLS:
				cells.append(cell)
	
	return cells

func add_step(path, direction : Vector3):
	if direction.length() > 1:
		return
	
	var new_cell
	var last_cell = grid[path[-1].q][path[-1].r]
	
	if direction == Vector3.RIGHT or direction ==  Vector3.LEFT:
		new_cell = grid[last_cell.q + int(direction.x)][last_cell.r]
	elif direction == Vector3.UP or direction ==  Vector3.DOWN:
		new_cell = grid[last_cell.q][last_cell.r + int(direction.y)]
	elif direction == Vector3.FORWARD or direction ==  Vector3.BACK:
		# Moving 1z = moving (1q-1r)
		new_cell = grid[last_cell.q + int(direction.z)]\
						[last_cell.r - int(direction.z)]
	
	if new_cell != null and new_cell.kind in SELECTABLE_CELLS:
		path.append(new_cell)

func display_straight_lines_fov(cell_start, max_dist, color_key, min_dist = 0):
	var list = _compute_straight_lines_fov(cell_start, max_dist, min_dist)
	for cell in list:
		cell.change_material(color_key)
	return list






## VARIOUS SHAPES SECTION ##
func _compute_zone(center, radius):
	var z = -center.r - center.q
	var zone = []
	for q in range(center.q-radius, center.q+radius+1):
		for r in range( \
				max(center.r-radius, -q-z-radius), \
				min(center.r+radius, -q-z+radius) +1):
			if grid[q][r].kind in SELECTABLE_CELLS:
				zone.append(grid[q][r])
	return zone

func display_zone(center, radius, color_key):
	var zone = _compute_zone(center, radius)
	for cell in zone:
		cell.change_material(color_key)






## HANDLE PATH FINDING ##
func _neighbors (cell):
	# Function returning every neighbor of a cell, of any kind	
	var list = []
	
	if grid[cell.q][cell.r +1] != null:
		list.append(grid[cell.q][cell.r+1])
	
	if grid[cell.q +1][cell.r] != null:
		list.append(grid[cell.q +1][cell.r])
	
	if grid[cell.q +1][cell.r -1] != null:
		list.append(grid[cell.q +1][cell.r -1])
	
	if grid[cell.q][cell.r -1] != null:
		list.append(grid[cell.q][cell.r -1])
	
	if grid[cell.q -1][cell.r] != null:
		list.append(grid[cell.q -1][cell.r])
	
	if grid[cell.q -1][cell.r +1] != null:
		list.append(grid[cell.q -1][cell.r +1])
	
	return list
	
func _serialize_path(path):
	var path_serialized = []
	for c in path:
		path_serialized += [[c.q, c.r]]
	return path_serialized


func _compute_path(start, end, distance_max):
	# Function calculating a path between two cells
	if distance_coord(start.q, start.r, end.q, end.r) > distance_max:
		# If the distance between start and end is greater than distance_max
		# then no path < distance_max can be found
		return []
		
	# Starting cell is not included in the path, but ending cell is
	# The frontier is the line of farest cells reached
	var frontier = []
	frontier.append(start)
	# Came_from is a dictionnary where cells are associated with the cell who 
	#  permitted reaching it
	var came_from = {}
	came_from[start] = start
	
	var current_cell
	
	while not frontier.empty():
		# Taking the first cell in the frontier
		current_cell = frontier.pop_front()
		
		if current_cell == end:
			break
		
		# For each neighbor of the current cell,
		#  if the neighbor is a floor cell and hasn't been travelled across
		#   the neighbor is added to the frontier 
		#   and associated at the current cell 
		for next in _neighbors(current_cell):
			if (next.kind == 'floor') and not(next in came_from):
				frontier.append(next)
				came_from[next] = current_cell
	
	if not (end in came_from.keys()) :
		# There is no path to reach end from start
		return []
		
	# The path is calculated from end to start, then reversed	
	var _path = [end]	
	current_cell = came_from[end]
	while current_cell != start and current_cell != null:
		_path.append(current_cell)
		current_cell = came_from[current_cell]
	_path.invert()
	
	if len(_path) > distance_max:
		# If the path is taller than distance_max, then there is no path.
		_path = []
	
	return _path

func display_path(start, end, distance_max):
	var path = _compute_path(start, end, distance_max)
	for elt in path:
		elt.change_material('green')
	return _serialize_path(path)


func _compute_displacement_range(start, distance_max):
	var visited = [start]
	var reachable = [[start]]
	
	for i in range(1, distance_max+1):
		reachable.append([])
		for cell in reachable[i-1]:
			for neighbor in _neighbors(cell):
				if ( not(neighbor in visited) and (neighbor.kind == 'floor')):
					visited.append(neighbor)
					reachable[i].append(neighbor)
	return visited

func display_displacement_range(start, distance_max):
	var zone = _compute_displacement_range(start, distance_max)
	for cell in zone:
		cell.change_material('green')
	return zone




## HANDLE CAMERA ROTATION ##
func _process(_delta):
	var mouse_position = get_viewport().get_mouse_position()
	if is_rotation_camera_ask(mouse_position):
		rotate_camera(mouse_position)
	last_mouse_position = mouse_position

func _unhandled_input(event):
	# Zoom handling
	# Done in _unhandled_input instead of _input in order to let other nodes
	#  (as ScrollPane) handle a zoom before handling it on the map
	var MAX_ZOOM = 0.8 #The camera is limited to a portion of the 3D Curve
	var MIN_ZOOM = 0
	
	if event.is_action_pressed("Map_zoom_in"):
		# If zoom in, camera goes forward inside the authorized curve portion
		$CameraScrollPath/CameraTrolley.unit_offset = clamp( \
			$CameraScrollPath/CameraTrolley.unit_offset + camera_sensibility, \
			MIN_ZOOM, MAX_ZOOM)
		# No other handle needed on this event
		get_tree().set_input_as_handled() 
	elif event.is_action_pressed("Map_zoom_out"):
		# If zoom out, camera goes backward inside the authorized curve portion
		$CameraScrollPath/CameraTrolley.unit_offset = clamp( \
			$CameraScrollPath/CameraTrolley.unit_offset - camera_sensibility, \
			MIN_ZOOM, MAX_ZOOM)
		# No other handle needed on this event
		get_tree().set_input_as_handled()

func rotate_camera(mouse_position):
	if last_mouse_position != Vector2(-1, -1):
		var center_screen = get_viewport().size/2
		var vect_last = center_screen - last_mouse_position
		var vect_current = center_screen - mouse_position
		var angle = vect_current.angle_to(vect_last)
		$CameraScrollPath.rotate_y(-angle)
		
func is_rotation_camera_ask(mouse_position):
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) \
		and mouse_position != last_mouse_position:
		return true
	return false
	
	
	
## USEFULL FUNCTIONS
func distance_coord(q1, r1, q2, r2):
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2

func distance_cells(cell1, cell2):
	return distance_coord(cell1.q, cell1.r, cell2.q, cell2.r)

func clear():
	for c in cells_floor:
		c.change_material('floor')

func manage_fov(spell : Spell, origin_cell, color_key):
	var fov
	match spell.fov_type:
		'straight_lines':
			fov = display_straight_lines_fov(origin_cell, spell.cast_range[1],
											color_key, spell.cast_range[0])
		'fov':
			fov = display_field_of_view(origin_cell, spell.cast_range[1], 
										color_key, spell.cast_range[0])
		_:
			fov = display_field_of_view(origin_cell, spell.cast_range[1], 
										color_key, spell.cast_range[0])
	return fov

func manage_impact(spell : Spell, origin_cell, target_cell, color_key):
	match spell.impact_type:
		'cell':
			target_cell.change_material(color_key)
			
		'zone':
			display_zone(target_cell, spell.impact_range, color_key)
		_:
			target_cell.change_material(color_key)
