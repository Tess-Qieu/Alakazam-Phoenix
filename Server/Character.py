#!/usr/bin/env python3

from Spell import RaySpell, BombSpell, BreathSpell


def distance_coord(q1, r1, q2, r2):
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2


class Character():
	''' Represents a character in the game '''
	
	# List of spells the character knows
	#  At runtime, class references are converted to instances
	Spells = {'CannonBall'	: RaySpell(),
			 	'Missile'	: BombSpell(),
			 'Flamethrower'	: BreathSpell() }
	
# 	# Cell on the Map where the character is currently placed
# 	current_cell : Cell
	
	def __init__(self, team_color, user, id_character):
		
		self.team_color = team_color
		self.user = user
		self.id_character = id_character

		self.health = 100
		self.range_displacement = 5
		self.alive = True
		
		self.current_cell : Cell = None

	def die(self):
		# Make the character die, /!\ MAYBE NEED TO RAISE SOMETHING FOR GAME
		self.alive = False
		self.health = 0

	def serialize(self):
		# Serialize the object to send it to the clients
		data = {'team_color': self.team_color,
				'q': self.current_cell.q,
				'r': self.current_cell.r,
				'id character': self.id_character,
				'health': self.health,
				'range displacement': self.range_displacement}
		return data

	def set_current_cell(self, new_cell):
		if not new_cell is None:
			self.current_cell = new_cell
	
	def get_current_cell(self):
		return self.current_cell
	
