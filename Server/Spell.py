'''
Created on 31 mai 2020

@author: Gauth
'''
import random


class Spell(object):
	'''
	classdocs
	'''

	def __init__(self):
		'''
		Constructor
		'''
		self.cast_range = [1,3]
		self.start_cooldown = 10
		self.current_cooldown = self.start_cooldown
		self.fov_type = 'fov'
		self.impact_type = 'cell'
		self.damage_amount = [-1,-1]
	
	def compute_damages_on(self, target_cell, touched_cells, team_list, \
								caster_team ):
		# target_cell is not used here, but could be used to deal damages
		#  based on distance from the targeted cell
		targets = []
		# Touched characters research
		for team in team_list:
			if team != caster_team:
				# Damages dealt only on opposing team
				for character in team.get_all_members():
					if character.current_cell in touched_cells:
						targets.append(character)
			
		damages = []
		for elt in targets:
			damages.append(random.randint(self.damage_amount[0], \
											self.damage_amount[1]))
		
		# Apply damages to characters and create data
		data = []
		for i, c in enumerate(targets):
			# apply damage
			damage = damages[i]
			c.health -= damage
			data_one_target = { 'id character': c.id_character, \
								'damage': damage, \
								'events': []}

			# Verify if character still alive	   
			if c.health <= 0:
				c.die()
				data_one_target['events'] += ['character dead']

			data += [data_one_target]

		return data

class RaySpell(Spell) :
	'''
	classdocs
	'''
	def __init__(self):
		Spell.__init__(self)
		self.damage_amount = [28,32]
		self.cast_range = [0,10]
		self.fov_type = 'straight_lines'
		
	
class BombSpell(Spell):
	'''
	classdocs
	'''
	
	def __init__(self):
		Spell.__init__(self)
		self.damage_amount = [10,15]
		self.cast_range   = [2,4]
		self.impact_type  = 'zone'
		self.impact_range = 2

class BreathSpell(Spell):
	'''
	classdocs
	'''
	
	def __init__(self):
		Spell.__init__(self)
		self.damage_amount = [8,13]
		self.cast_range = [2,4] #First value is cast range, second is triangle height
		self.fov_type = 'hexa_points'
		self.impact_type = 'breath'
		
