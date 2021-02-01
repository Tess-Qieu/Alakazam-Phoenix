#!/usr/bin/env python3


from Character import Character

class Team():

	def __init__(self, team_name, color_team, user, characters : Character):
		self.team_color = color_team
		self.name = team_name
		self.user = user
		self.characters = characters

	def add_member(self, character):
		self.characters += [character]

	def remove_member(self, character):
		if character in self.characters:
			self.characters.remove(character)
	
	def get_member(self, index : int):
		if index >0 and index < self.characters.length:
			return self.characters[index]
	
	def get_all_members(self):
		return self.characters
	
	def is_in_team(self, character):
		return (character in self.characters)

	def is_team_dead(self):
		for c in self.characters:
			if c.alive:
				return False
		return True

	def serialize(self):
		return {'user id': self.user.user_id, 'color': self.team_color,
				'characters': [character.serialize() for character in self.characters]}
	
	def new_turn(self, data):
		''' Method called at the beginning of every new turn for the team
		'''
		# Creation of a dictionary with the following structure :
		# { character 1 : { Spell_1 : cooldown, 
		#					Spell_2 : cooldown },
		#	character 2 : { Spell_1 : cooldown,
		#					Spell_2 : cooldown } }
		cooldowns = {}
		
		# Spread of the new_turn to each character of the team
		for c in self.characters:
			cooldowns[c.id_character] = c.new_turn()
		
		# Cooldowns additions to the data
		data['details']['cooldowns'] = cooldowns
		return data