import random
# from collections import namedtuple
from Spell import Spell

# def distance_coord(q1, r1, q2, r2):
# 	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2

# Cell = namedtuple('Cell', ['q', 'r', 'kind'])


class Cell():
	''' Class representing a cell on the Map 
		
		@author: Gauth
	'''
	q = 0
	r = 0
	kind = 'border'
	
	def __init__(self, q, r, kind):
		self.q = q
		self.r = r
		self.kind = kind
	
	def get_coord3(self):
		return [self.q, self.r, -self.q - self.r]


class Map():
	'''Contains a representation of the map'''

	PROBA_CELL_FULL = 0.1
	PROBA_CELL_HOLE = 0.1
	LENGTH_BORDER = 8
	RAY_ARENA = 8
	RAY = LENGTH_BORDER + RAY_ARENA

	def __init__(self):
		self.grid = {}
		self.cells_floor = []
		self.generate_grid()

	def serialize(self):
		grid_serialized = {}
		for q in self.grid.keys():
			grid_serialized[q] = {}
			for r in self.grid[q].keys():
# 				if (self.get_cell(q, r).kind == 'blocked'):
# 					grid_serialized[q][r] = 'floor'
# 				else:
# 					grid_serialized[q][r] = self.get_cell(q, r).kind
				grid_serialized[q][r] = self.get_cell(q, r).kind
		return grid_serialized

	def random_cells_floor(self, nb=2):
		cells = []
		while nb > 0:
			cell = random.choice(self.cells_floor)
			if cell not in cells:
				cells += [cell]
				nb -= 1
		return cells

	def get_cell(self, q, r):
		try:
			return self.grid[q][r]
		except KeyError:
			return None
	
	def distance_coords(self, q1, r1, q2, r2):
		return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2
	
	def distance_cells(self, cell1 : Cell, cell2 :Cell):
		return self.distance_coords(cell1.q, cell1.r, cell2.q, cell2.r)
	
	def _compute_line(self, start, end):
		
		def _line_step(start, end, step):
			# Function used to calculate a step on a line	
			return start + (end - start) * step
		
		# Line calculation between two cells
		line = []
		N = int(self.distance_coords(start.q, start.r, end.q, end.r))
		
		# Addition of starting cell
		line.append(start)
		
		for i in range(1, N):
			# float coordinates calculation
			r_float = _line_step(start.r, end.r, float(i) / float(N))
			q_float = _line_step(start.q, end.q, float(i) / float(N))
			
			# Compute all r for that step
			list_r = []
			if abs(r_float % 1) == 0.5:
				list_r += [int(r_float - 0.5), int(r_float + 0.5)]
			else:
				list_r += [int(round(r_float))]
			
			# Compute all q for that step
			list_q = []
			if abs(q_float % 1) == 0.5:
				list_q += [int(q_float - 0.5), int(q_float + 0.5)]
			else:
				list_q += [int(round(q_float))]
			
			for q in list_q:
				for r in list_r:
					cell = self.get_cell(q, r)
					if cell is not None:
						line.append(cell)
		
		# Addition of ending cell
		line.append(end)
		return line

	# # GRID GENERATION ##
	def generate_grid(self):
		
		def _add_instance_to_grid(self, kind, q, r):
			if not q in self.grid.keys():
				self.grid[q] = {}

			instance = Cell(q, r, kind)
			self.grid[q][r] = instance

			if kind == 'floor':
				self.cells_floor += [instance]

		def _random_kind(self):
			value = random.random()
			lim = self.PROBA_CELL_FULL
			if value < lim:
				return 'full'
			lim += self.PROBA_CELL_HOLE
			if value < lim:
				return 'hole'
			return 'floor'
			
		def _generate_one_gridline(self, line_size, r):
			kind = ''
			half = int(line_size / 2 if line_size % 2 == 0 else (line_size / 2 + 1))
			q = -self.RAY - r if r <= 0 else -self.RAY
			# first part : random
			for i in range(half):
				if self.distance_coords(q, r, 0, 0) > self.RAY_ARENA:
					kind = 'border'
				else:
					kind = _random_kind(self)
				_add_instance_to_grid(self, kind, q, r)
				if line_size % 2 == 0 or i + 1 != half :
					_add_instance_to_grid(self, kind, line_size - 2 * i + q - 1, r)
				q += 1

		nb_cell = self.RAY + 1
		for r in range(-self.RAY, 0) :
			_generate_one_gridline(self, nb_cell, r)
			nb_cell += 1
		for r in range(self.RAY + 1) :
			_generate_one_gridline(self, nb_cell, r)
			nb_cell -= 1

	def is_path_valid(self, cell_start, path):

		def _is_neighbors(cell_1, cell_2):

			vect = (cell_1.q - cell_2.q, cell_1.r - cell_2.r)
			coord_neighbors = [(0, 1), (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1)]
			for c in coord_neighbors:
				if vect == c:
					return True
			return False

		if cell_start is None:
			return False
		for c in path:
			if c is None or c.kind != 'floor':
				return False

		current_cell = cell_start
		for cell in path:
			if not _is_neighbors(cell, current_cell):
				return False
			current_cell = cell
		return True

	def neighbors(self, cell:Cell):
		liste = []
		
		if self.grid[cell.q][cell.r + 1] != None:
			liste.append(self.grid[cell.q][cell.r + 1])
			
		if self.grid[cell.q][cell.r - 1] != None:
			liste.append(self.grid[cell.q][cell.r - 1])
			
		if self.grid[cell.q + 1][cell.r] != None:
			liste.append(self.grid[cell.q + 1][cell.r])
			
		if self.grid[cell.q - 1][cell.r] != None:
			liste.append(self.grid[cell.q - 1][cell.r])
			
		if self.grid[cell.q - 1][cell.r + 1] != None:
			liste.append(self.grid[cell.q - 1][cell.r + 1])
			
		if self.grid[cell.q + 1][cell.r - 1] != None:
			liste.append(self.grid[cell.q + 1][cell.r - 1])
			
		return liste
		
	# # VARIOUS SHAPES SECTION ##
	def _compute_zone(self, center, radius, selection_filter=['floor', \
																'blocked']):
		zone = []
		z = -center.q - center.r
		
		for q in range(center.q - radius, center.q + radius + 1):
			for r in range(max(center.r - radius, -q - z - radius), \
							min(center.r + radius, -q - z + radius) + 1):
				
				if self.grid[q][r].kind in selection_filter:
					zone.append(self.grid[q][r])
		return zone
	
	def _compute_triangle_recursive(self, current_cell : Cell, cell_ref:Cell,
								height, direction, triangle, select_filter, block_filter):
		if self.distance_cells(current_cell, cell_ref) == height - 1:
			return
		else:
			target_cell = self.grid[current_cell.q + direction[0]][current_cell.r + direction[1]]
			
			for n in self.neighbors(current_cell):
				if  not n in triangle \
					and self.distance_cells(n, target_cell) == 1 \
					and not n.kind in block_filter:
					if n.kind in select_filter:
						triangle.append(n)
					
					self._compute_triangle_recursive(n, cell_ref, height, direction, triangle, select_filter, block_filter)

	def _compute_triangle(self, start : Cell, target : Cell, height, \
						selection_filter=['floor', 'blocked'], \
						block_filter=['border', 'full']):
		''' TODO
			
			@author: Gauth
		'''
		direction = [target.q - start.q, target.r -start.r, (-target.q -target.r) - (-start.q -start.r)]
		
		if not ((direction[0] == -2 * direction[1] and direction[0] == -2 * direction[2]) \
			or ( direction[1] == -2 * direction[0] and direction[1] == -2 * direction[2]) \
			or ( direction[2] == -2 * direction[0] and direction[2] == -2 * direction[1]) \
				):
			print("ERROR: cells are not aligned")
# 			print("DEBUG:###########\n"+\
# 				"start:({},{}), target:({},{}), direction:{}".format(\
# 					start.q, start.r, target.q, target.r, direction) \
# 				+"\n#################")
			return []
		
		# Resize of direction to obtain a 2-cells long "vector"
		for index in range(len(direction)):
			direction[index] = direction[index] * 2 / self.distance_cells(start, target)
		
		triangle = [start]
		
		# recursive construction
		self._compute_triangle_recursive(start, start, height, direction, triangle, selection_filter, block_filter)
		
		return triangle
	
	# # VISION SECTION ##
	
	def has_vision_on(self, cell_from, cell_target, blocked_by=['border', \
																  'full']):
		''' Function computing a field of view (fov) from a cell
			 and returning if an other cell is in this fov
			Cell kinds blocking the fov are listed in blocked_by in order
			 to make the fov computation more generic
			
			@author: Gauth
		'''
		if cell_from is None or cell_target is None:
			return False

		first_line = self._compute_line(cell_from, cell_target)
		second_line = self._compute_line(cell_target, cell_from)
		for c in first_line + second_line:
			if c.kind in blocked_by:
				return False
		return True

	def is_target_in_straight_line_fov(self, origin : Cell, target : Cell, \
											 min_dist=0, max_dist=0):
		''' Function computing a field of view (fov) from a cell
			 and returning if an other cell is in this fov
			In this function the fov is limited to straight line from the
			 origin cell and within minimal and maximal distances
			
			@author: Gauth
		'''
		# Incorrect data protection
		if origin == None or target == None:
			return False
		# Out of range cell
		elif self.distance_cells(target, origin) < min_dist or \
			max_dist < self.distance_cells(target, origin):
			return False
		
		# Constant Q, Constant R or Constant Z
		if origin.q == target.q or origin.r == target.r \
			or ( (-origin.r -origin.q) == (-target.r -target.q) ):
			
			return self.has_vision_on(origin, target)
	
	def is_target_in_hexa_points_fov(self, origin : Cell, target : Cell, \
									radius : int):
		''' TODO
			 
			@author: Gauth
		'''
		result = False
		targets = []
		origin_coord = origin.get_coord3()
		target_coord = target.get_coord3()
# 		print("DEBUG: ########\n" + \
# 				"radius:{}".format(radius)+\
# 				"\n#############")
		
		if (radius % 2) == 0:
			targets.append([origin_coord[0] -radius,\
							origin_coord[1] +radius/2,\
							origin_coord[2] +radius/2] )
			
			targets.append([origin_coord[0] +radius,\
							origin_coord[1] -radius/2,\
							origin_coord[2] -radius/2] ) 
			
			targets.append([origin_coord[0] +radius/2,\
							origin_coord[1] -radius,\
							origin_coord[2] +radius/2] ) 
			
			targets.append([origin_coord[0] -radius/2,\
							origin_coord[1] +radius,\
							origin_coord[2] -radius/2] )
			
			targets.append([origin_coord[0] +radius/2,\
							origin_coord[1] +radius/2,\
							origin_coord[2] -radius] ) 
			
			targets.append([origin_coord[0] -radius/2,\
							origin_coord[1] -radius/2,\
							origin_coord[2] +radius] ) 
# 			print("DEBUG: ########\n" + \
# 				"targets:\n")
# 			for i in targets:
# 				print("{}\n".format(i))
# 			print("###############")
			result = target_coord in targets
		else:
			targets.append([origin_coord[0] -radius,\
							origin_coord[1] +radius,\
							origin_coord[2]	+0] )
			
			targets.append([origin_coord[0] +radius,\
							origin_coord[1] -radius,\
							origin_coord[2] -0] ) 
			
			targets.append([origin_coord[0] +radius,\
							origin_coord[1] +0,\
							origin_coord[2] -radius] ) 
			
			targets.append([origin_coord[0] -radius,\
							origin_coord[1] +0,\
							origin_coord[2] +radius] )
			
			targets.append([origin_coord[0] +radius,\
							origin_coord[1] -radius,\
							origin_coord[2] +0] ) 
			
			targets.append([origin_coord[0] -radius,\
							origin_coord[1] +radius,\
							origin_coord[2] +0] )
		
# 		if not result:
# 			print("DEBUG: ########\n" + \
# 				"origin:({},{}) and target:({},{}) ".format(origin.q, origin.r, target.q, target.r)+\
# 				"are not aligned\n#############")
		
		return result

	def is_target_in_fov(self, spell : Spell, caster_cell, target_cell):
		''' Function managing if a character placed on a given cell 
			 can cast a spell on a targeted cell, based on the field of 
			 view (fov) type of the spell
			 
			@author: Gauth
		'''
# 		print("DEBUG: ########\n"+\
# 				"fov type :"+ spell.fov_type\
# 				+"\n#############")
		if spell.fov_type == 'straight_lines':
			return self.is_target_in_straight_line_fov(caster_cell, \
													target_cell, \
													spell.cast_range[0], \
													spell.cast_range[1])
		elif spell.fov_type == 'fov': 
			return self.has_vision_on(caster_cell, target_cell)
		
		elif spell.fov_type == 'hexa_points':
			return self.is_target_in_hexa_points_fov(caster_cell, \
													target_cell,
													spell.cast_range[0])
		
		else:
			return False
	
	def get_touched_cells(self, spell : Spell, caster_cell, target_cell):
		''' Function computing which cells are touched by spell, based on 
			 the impact type of the spell.
			
			Currently unused, caster spell can be needed to compute 
			 geometries based on a caster-target orientation
			
			@precondition: target_cell must be in the field of view of the 
			 given spell, casted from the caster_spell
			
			@author: Gauth
		'''
		if spell.impact_type == 'cell':
			return [target_cell]
		elif spell.impact_type == 'zone':
			return self._compute_zone(target_cell, spell.impact_range)
		elif spell.impact_type == 'breath':
			return self._compute_triangle(caster_cell, target_cell, spell.cast_range[1])
		return []
