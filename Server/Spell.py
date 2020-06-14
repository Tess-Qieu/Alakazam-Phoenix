'''
Created on 31 mai 2020

@author: Gauth
'''
import random


class Spell(object):
	'''
	classdocs
	'''
	cast_range = [1,3]
	start_cooldown = 10
	current_cooldown = start_cooldown
	fov_type = 'fov'
	impact_type = 'cell'
	damage_amount = -1

	

	def __init__(self, params):
		'''
		Constructor
		'''
	
	def compute_damages_on(self, target_cell, touched_cells, team_list, \
								caster_team ):
		# target cell is note used here, could be used to compute damages
		#  based on distance from the targeted cell
		targets = []
		# Touched characters research
		for team in team_list:
			for character in team:
				if character.current_cell in touched_cells:
					targets.append(character)
		
		damages = []
		for elt in targets:
			damages += [random.randint(min, max+1)]
		
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
	cast_range = [0,10]
	fov_type = 'straight_lines'
	
class BombSpell(Spell):
	'''
	classdocs
	'''
	cast_range   = [2,4]
	impact_type  = 'zone'
	impact_range = 2