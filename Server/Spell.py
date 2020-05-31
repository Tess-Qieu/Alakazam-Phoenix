'''
Created on 31 mai 2020

@author: Gauth
'''

class MyClass(object):
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
