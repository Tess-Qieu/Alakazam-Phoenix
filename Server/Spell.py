'''
Created on 31 mai 2020

@author: Gauth
'''

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