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

func generate_grid(random = false):
	if random:
		rng.randomize()
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
	
func _instance_cell(cell_type, q, r, kind, handler_node = null):
	# Protection in case of null handler
	if handler_node == null:
		handler_node = get_parent()
	
	var cell = cell_type.instance()
	cell.init(q, r, kind, handler_node)
	add_child(cell)
	_add_instance_to_grid(cell, q, r)
	if kind in SELECTABLE_CELLS:
		cells_floor += [cell]

func instance_map(new_grid, handler_node = null):
	grid = new_grid
	for q in grid.keys():
		for r in grid[q].keys():
			var kind = grid[q][r]
			if kind == 'hole':
				_instance_cell(CellSize1, q, r, kind, handler_node)
			elif kind == 'floor' or kind == 'blocked': 
				_instance_cell(CellSize2, q, r, kind, handler_node)
			elif kind == 'full':
				_instance_cell(CellSize3, q, r, kind, handler_node)
			elif kind == 'border':
				var height = rng.randi() % 3
				var choices = {0: CellSize3, 1: CellSize4, 2:CellSize5}
				_instance_cell(choices[height], q, r, kind, handler_node)





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

func _compute_straight_lines_fov(cell_start, max_dist, min_dist = 0, \
									block_filter = BLOCKING_VIEW, \
									select_filter = SELECTABLE_CELLS ):
	## Computes a field of view composed of 6 straight lines
	# from a given cell and within a range of distance
	var paths = {}
	var cells = []
	
	# In direction of each neighbor
	for n in _neighbors(cell_start):
		var last_size = 0
		paths[n] = [cell_start] #path initialized with the starting cell
		# loop while the path is getting longer and within the max distance
		while paths[n].size() <= max_dist and paths[n].size() > last_size:
			last_size = paths[n].size()
			# Computing a step more
			var vect = n.get_coord_vect3()-cell_start.get_coord_vect3()
			
			add_step(paths[n], vect)
		
		# Distance filter and addition to exit value
		for c in paths[n].slice(min_dist, max_dist):
			if c.kind in block_filter:
				break
			else:
				if not (c in cells) and c.kind in select_filter:
					cells.append(c)
	
	return cells

func add_step(path, direction : Vector3 ):
	# Add a cell to an array given a direction.
	# The direction can be given in two formats:
	#  > (axisQ, axisR, axisZ), meaning a desired movement of +/- 1 cell on the 
	#	given axis. Only one composant must be set to +/- 1.
	#	Examples: (1,0,0), (0,-1,0)
	#  > (coordQ, coordR, coordZ), meaning a set of coordinates in a Q,R,Z 
	#	representation of an hexagonal grid. These coordinates are equivalent
	#	to a vector, which, applied to an original cell, gives a destination cell.
	#	This vector must respect q+r+z = 0 and represent a one-cell translation,
	#	ie, its squared length must be 2.
	#	Examples: (1,0,-1), (0,-1,1)
	
	# Size protection: the path must contain at least one cell
	if path.size() <1: return
	# next cell in the given direction
	var new_cell = null
	# last cell in the given path
	var last_cell = grid[path[-1].q][path[-1].r]
	
	# Axis only based movement
	if direction.length() == 1 :
		if direction == Vector3.RIGHT or direction ==  Vector3.LEFT:
			new_cell = grid[last_cell.q + int(direction.x)][last_cell.r]
		elif direction == Vector3.UP or direction ==  Vector3.DOWN:
			new_cell = grid[last_cell.q][last_cell.r + int(direction.y)]
		elif direction == Vector3.FORWARD or direction ==  Vector3.BACK:
			# Moving 1z = moving (+1q-1r)
			new_cell = grid[last_cell.q + int(direction.z)]\
							[last_cell.r - int(direction.z)]
	
	# Coordinates based movement
	elif direction.length_squared() == 2:
		var new_q = last_cell.q + int(direction.x)
		var new_r = last_cell.r + int(direction.y)
		
		if grid.has(new_q) and grid[new_q].has(new_r):
			new_cell = grid[new_q][new_r]
	
	else:
		print("Vecteur direction incorrect : {0}".format([direction]))
		print("  length: {0} | squared length: {1}".format(\
				[direction.length(), direction.length_squared()] ))
		return
	
	if new_cell != null:
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

func _compute_triangle_recursive(current_cell, cell_ref, height, direction, \
									triangle, block_filter, select_filter):
	if distance_cells(current_cell, cell_ref) == height-1:
		return
	else:
#		print("DEBUG: aimed cell : ({0};{1})".format([current_cell.q + direction.x,current_cell.r + direction.y]))
		# this cell indicates the aimed direction in a 2 cells range
		var target_cell = grid[int(current_cell.q + direction.x)][int(current_cell.r + direction.y)]
		
		# Looking for closest neighbor of target_cell 
		# --> Gives 2 cells in the wright direction
		for n in _neighbors(current_cell):
			if not (n in triangle) and distance_cells(n, target_cell) == 1 \
				and not(n.kind in block_filter):
				if n.kind in select_filter:
					triangle.append(n)
				# Continues the triangle contruction from the new cell
				_compute_triangle_recursive(n, cell_ref, height, direction, \
											triangle, block_filter, select_filter)

func _compute_triangle(cell_top, cell_target, height, \
									block_filter = BLOCKING_VIEW, \
									select_filter = SELECTABLE_CELLS):
	# Computes a triangle from a given cell to a target cell
	
	var direction = cell_target.get_coord_vect3() - cell_top.get_coord_vect3()
#	print("DEBUG: Direction is {0}".format([direction]))
#	print("DEBUG: cell top is {0}, cell target is {1}".format( \
#			[cell_top.get_coords_string(), cell_target.get_coords_string()]))
	# Early return if the cells are not correctly aligned
	if not( (# Target on x axis:
			direction.x == -2*direction.y and direction.x == -2*direction.z)
		or
			(# Target on y axis:
			direction.y == -2*direction.x and direction.y == -2*direction.z)
		or 
			(# Target on z axis:
			direction.z == -2*direction.x and direction.z == -2*direction.y)
			):
		print("{0} and {1} are not aligned".format(
			[cell_top.get_coords_string(), cell_target.get_coords_string()]))
		return
	
	# Resize of the direction vect
	direction = (direction*2)/distance_cells(cell_target, cell_top)
	
	var triangle = [cell_top]
	_compute_triangle_recursive(cell_top, cell_top, height, direction, triangle, \
								block_filter, select_filter)
	return triangle

func display_triangle(cell_top, cell_target, height, color_key):
	var triangle = _compute_triangle(cell_top, cell_target, height)
	
	if triangle == null:
		print("Triangle is empty\n")
	else:
		for cell in triangle:
			cell.change_material(color_key)


func _compute_hexa_points(cell_origin, radius, isEvenRangePointy = true, \
							 select_filter = SELECTABLE_CELLS):
	# Computes the 6 corners of an hexagon, based on a given cell and a radius
	# By default, even and odd radius are not managed the same way :
	# For an odd range, the returned cells have a side parallel to the origin cell
	#   Example : with radius = 1, the returned cells are the direct neighbors
	# For an even range, the default behaviour is returning the cells that have
	# a corner pointing to the origin cell. 
	#
	# Example with radius = 2
	# DEFAULT EVEN RADIUS BEHEVIOUR      ## MODIFIED EVEN RADIUS BEHAVIOUR 
	#                                    ## (identical to odd radius behaviour)
	# \ / \ / \ / \ /  # O = Origin Cell ## \ / \ / \ / \ /  #
	#  | X |   |   |   # X=Returned cell ##  |   |   |   |   #
	# / \ / \ / \ / \  #                 ## / \ / \ / \ / \  #
	#|   |   | O |   | #                 ##| X |   | O |   | #
	# \ / \ / \ / \ /  #                 ## \ / \ / \ / \ /  #
	#  | X |   |   |   #                 ##  |   |   |   |   #
	# / \ / \ / \ / \  #                 ## / \ / \ / \ / \  #
	#|   |   | X |   | #                 ##|   | X |   | X | #
	# \ / \ / \ / \ /  #                 ## \ / \ / \ / \ /  #
	#
	var points = []
	var points_vect3 = []
	
	# Getting origin coordinates in a vect3 format
	var origin_coord : Vector3 = cell_origin.get_coord_vect3()
	
	if radius < 1: #value protection
		print("Radius can't be less than 1. Provided radius: {0}".format([radius]))
		return
	
	# Compute each of six coordinates
	if isEvenRangePointy:
		points_vect3.append( origin_coord + Vector3(radius, int(-radius/2), int(-radius/2)) )
		points_vect3.append( origin_coord + Vector3(-radius, int(radius/2), int(radius/2)) )
		points_vect3.append( origin_coord + Vector3(int(-radius/2), radius, int(-radius/2)) )
		points_vect3.append( origin_coord + Vector3(int(radius/2), -radius, int(radius/2)) )
		points_vect3.append( origin_coord + Vector3(int(-radius/2), int(-radius/2), radius) )
		points_vect3.append( origin_coord + Vector3(int(radius/2), int(radius/2), -radius) )
	else:
		points_vect3.append( origin_coord + Vector3(0.0, radius, -radius) )
		points_vect3.append( origin_coord + Vector3(0.0, -radius, radius) )
		points_vect3.append( origin_coord + Vector3(radius, 0.0, -radius) )
		points_vect3.append( origin_coord + Vector3(-radius, 0.0, radius) )
		points_vect3.append( origin_coord + Vector3(radius, -radius, 0.0) )
		points_vect3.append( origin_coord + Vector3(-radius, radius, 0.0) )
		
	# Addition of each cell in output list
	for c in points_vect3:
		var cell = grid[int(c.x)][int(c.y)]
#		print(cell.get_coords_string())
		if cell.kind in select_filter:
			points.append( cell )
#		else:
#			print("DEBUG: {0} not selectable".format([cell.kind]))
	
	return points

func display_hexa_points(cell_origin, radius, color_key):
	var points = _compute_hexa_points(cell_origin, radius)
	
#	print("DEBUG: In display_hexa_points : point.len={0}".format([points.size()]))
	
	for c in points:
		c.change_material(color_key)
	
	return points



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
	var fov = []
	match spell.fov_type:
		'straight_lines':
			fov = display_straight_lines_fov(origin_cell, spell.cast_range[1],
											color_key, spell.cast_range[0])
		'fov':
			fov = display_field_of_view(origin_cell, spell.cast_range[1], 
										color_key, spell.cast_range[0])
		'hexa_points':
			fov = display_hexa_points(origin_cell, spell.cast_range[0], color_key)
		_:
			fov = display_field_of_view(origin_cell, spell.cast_range[1], 
										color_key, spell.cast_range[0])
	return fov

func display_impact(spell : Spell, origin_cell, target_cell, color_key):
	var cells = get_impact(spell, origin_cell, target_cell)
	
	for c in cells:
		c.change_material(color_key)

func get_impact(spell : Spell, origin_cell, target_cell):
	var cells = []
	match spell.impact_type:
		'cell':
			cells.append(target_cell)
		
		'zone':
			cells = _compute_zone(target_cell, spell.impact_range)
		
		'breath':
			cells = _compute_triangle(origin_cell, target_cell, spell.cast_range[1])
		
		_: # Remarkable and constant default behaviour
			cells.append(grid[0][0]) 
		
	return cells
