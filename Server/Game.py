#!/usr/bin/env python3

import asyncio
import random

from Lobby import Lobby
from Map import Map
from ManagerID import ManagerID
from Character import Character
from Team import Team


TIME_TURN = 30


class Timer():
	def __init__(self, timeout, callback):
		self._timeout = timeout
		self._callback = callback
		self._task = asyncio.ensure_future(self._job())

	async def _job(self):
		await asyncio.sleep(self._timeout)
		await self._callback()

	def cancel(self):
		self._task.cancel()


class Game(Lobby):
	''' Administrate a game depending clients actions '''

	## INITIALISATION ##
	def __init__(self, server, manager_lobby, id_lobby, players, observators):
		super().__init__(server, manager_lobby, id_lobby, players, observators)

		self.character_manager_id = ManagerID(100)
		self.map = Map()
		self.players_ready = [False for p in self.players]
		self.started = False
		self.teams = []

		self.init_teams()

		self.timer = None
		self.player_on_turn = None
		self.memory_on_turn = {}
		self.turns = self.players.copy()
		random.shuffle(self.turns)

	def begin(self):
		# could be the time while players can place character
		self.timer = Timer(1, self.new_turn) 

	def init_teams(self):
		# Create the team's characters
		
		def _create_team(self, team_name, color_team, user, cells):
			team = Team(team_name, color_team, user, [])
			for c in cells:
				new_character = Character(team.team_color, user, # c, \
										self.character_manager_id.get_new_id())
				team.add_member(new_character)
				self._update_character_cell(new_character, c)
			return team

		cells = self.map.random_cells_floor(6)
		random.shuffle(self.players)
		self.teams += [_create_team(self, "Devil's Flame", 'red', self.players[0], cells[:len(cells)//2])]
		self.teams += [_create_team(self, "Ocean's Deep", 'blue', self.players[1], cells[len(cells)//2:])]







	## COMMUNICATION WITH CLIENTS ##

	async def _on_message(self, data, user):
		# Manage the message from the clients
		if data['action'] == 'new game':
			# players send they are ready
			if data['details']['ready'] == True:
				self.set_player_ready(user)

		elif data['action'] == 'game':
			# game is running
			if data['ask'] == 'move':
				# user ask to move a character
				await self.ask_move(data['details'])
			elif data['ask'] == 'cast spell':
				# user ask to cast a spell
				await self.ask_cast_spell(data['details'])
			elif data['ask'] == 'end turn':
				# user ask to end its turn
				self.timer.cancel()
				await self.new_turn()
				
			# after a player ask a play, check if the game is over
			if self.is_game_over():
				await self.notify_game_over()
				self.end_of_lobby()

		else:
			print(f'NetworkError: action {data["action"]} not known.')



	async def notify_new_lobby(self):
		# Notify the clients that the lobby is ready
		data = {'action': 'new game', 
				'details': {'grid': self.map.serialize(),
							'lobby id': self.id_lobby,
							'teams': {self.teams[0].name: self.teams[0].serialize(),
									  self.teams[1].name: self.teams[1].serialize()
									}  
							}
				}
		await self.notify_all(data)



	async def notify_game_over(self):
		# Notify the players that the game is over and who won/lose
		results = {team.user: not team.is_team_dead() for team in self.teams}
		
		print('Game Over !')
		print('\n'.join([f'{user.pseudo} lost the game.' for user in results if not results[user]]))
		print('\n'.join([f'{user.pseudo} won the game.' for user in results if results[user]]))

		for user, res in results.items():			
			data = {'action': 'game over',
					'details': {'victory': res}}
			await self.notify_one_player(user, data)



	def end_of_lobby(self):
		# Called when the lobby end
		self.timer.cancel()
		super().end_of_lobby()



	async def new_turn(self):
		# Notify the clients when new turn
		self.next_player()
		self.reset_memory_on_turn()
		data = {'action': 'game',
				'directive': 'new turn',
				'details' : {'user id': self.player_on_turn.user_id,
							 'turn time': TIME_TURN,
							 'memory on turn': self.serialize_memory_on_turn()}}
		self.timer = Timer(TIME_TURN, self.new_turn)
		await self.notify_all(data)



	async def notify_ask_not_valid(self, data):
		user = self.get_player_by_id(data['user id'])
		data = {'action': 'game',
				'response': 'not valid',
				'details': data}
		await self.notify_one_player(user, data)






	## ACTIONS TO DO WHEN ASK FROM CLIENT ##

	def is_correct_user_id(self, data):
		return data['user id'] == self.player_on_turn.user_id

	def is_correct_character_user(self, character):
		return character.user.user_id == self.player_on_turn.user_id

	def is_correct_ask(self, character, data):
		return self.is_correct_user_id(data) \
				and self.is_correct_character_user(character) \
				and character.alive

	def is_correct_ask_cast_spell(self, data):
		# Verify if the ask spell is correct and that the character has not cast a spell yet this turn
		character = self.get_character_by_id(data['thrower']['id character'])
		return self.is_correct_ask(character, data) and not self.memory_on_turn['cast spell'][character]

	def is_correct_ask_move(self, data):
		# Verify the ask is correct and that the character has not move yet this turn
		character = self.get_character_by_id(data['id character'])
		return self.is_correct_ask(character, data) and not self.memory_on_turn['move'][character]




	async def ask_move(self, data):
		# Called when the user ask to move a character
		# Verify that the path is correct and that the character has not move yet this turn
		if not self.is_correct_ask_move(data):
			# if ask isn't correct, then return 
			await self.notify_ask_not_valid(data)
			return


		id_character = data['id character']
		path = data['path']	  

		# Find the correct character
		character = self.get_character_by_id(id_character)

		# Verify if the path is valid
		cell_start = character.current_cell
		path_in_cell = [self.map.get_cell(c[0], c[1]) for c in path]

		is_valid = self.map.is_path_valid(cell_start, path_in_cell) 
		
		# Send the response to the clients
		if is_valid and len(path) <= character.range_displacement: 
			# make the move
			self._update_character_cell(character, path[-1])

			# save that the character has made the move
			# so it can not move again this turn
			self.memory_on_turn['move'][character] = True

			data = {'action': 'game', 
					'response': 'move',
					'details': {'id character': id_character,
								'path': path,
								'memory on turn': self.serialize_memory_on_turn()}}
			
			await self.notify_all(data)

		else:
			# path not valid, prevent the user who asked
			await self.notify_ask_not_valid(data)




	async def ask_cast_spell(self, data):
		# Called when the user ask to move a character
		# Verify that the cats spell is correct and that the character has not cast a spell yet this turn

		if not self.is_correct_ask_cast_spell(data):
			# if ask isn't correct, then return 
			await self.notify_ask_not_valid(data)
			return

		
		id_thrower = data['thrower']['id character']
		coord_target = data['target']
		spell_name = data['spell name']

		character_thrower = self.get_character_by_id(id_thrower)
		cell_thrower = character_thrower.current_cell
		cell_target = self.map.get_cell(coord_target[0], coord_target[1])
		
		spell = character_thrower.Spells[spell_name]

		
		#is_valid = self.map.is_target_in_field_of_view(cell_thrower, cell_target)
		is_valid = self.map.is_target_in_fov(spell, cell_thrower, cell_target)

		if is_valid:
			# Get impacted cells
			touched_cells = self.map.get_touched_cells( spell, \
														cell_thrower,\
													 	cell_target)
			# Give impacted cell to Spell to compute damage info
			data_spell_applied = character_thrower.Spells[spell_name] \
				.compute_damages_on(cell_target, \
									touched_cells, \
									self.teams, \
							self.get_character_team(character_thrower))
			
			# Save that the character has cast the spell
			# so it can not cast a spell again this turn
			self.memory_on_turn['cast spell'][character_thrower] = True

			data = {'action': 'game',
					'response': 'cast spell',
					'details': {'thrower': {'id character': id_thrower},
								'target': coord_target,
								'spell name': spell_name,
								'damages': data_spell_applied,
								'memory on turn': self.serialize_memory_on_turn()}}

			await self.notify_all(data)

		else:
			# spell not valid, tell the user who asked
			await self.notify_ask_not_valid(data)


	def set_player_ready(self, user):
		# Called when the client indicates that he correctly load the game
		# and he is ready to play
		index = self.players.index(user)
		self.players_ready[index] = True

		# if one user isn't ready, pass
		for p in self.players_ready:
			if not p:
				return

		# else start the game
		print(f'The game in the lobby {self.id_lobby} starts !')
		self.started = True
		self.begin()






	## USEFULL FUNCTIONS ##

	def is_game_over(self):
		for team in self.teams:
			if team.is_team_dead():
				return True
		return False

	def get_all_characters(self):
		characters = []
		for team in self.teams:
			characters += team.characters
		return characters

	def get_character_by_id(self, id_character):
		for c in self.get_all_characters():
			if c.id_character == id_character:
				return c
		print(f'NetworkValueError: no character with id {id_character}.')
		return None
	
	def get_character_team(self, character):
		for t in self.teams:
			if character in t:
				return t
		
		return None

	def get_player_by_id(self, user_id):
		for user in self.players:
			if user.user_id == user_id:
				return user
		return None

	def get_team_by_player(self, user):
		for team in self.teams:
			if team.user == self.player_on_turn:
				return team

	def next_player(self):
		if self.player_on_turn is not None:
			self.turns += [self.player_on_turn]
		self.player_on_turn = self.turns.pop(0)

	def reset_memory_on_turn(self):
		# should be called after self.next_player()
		current_team = self.get_team_by_player(self.player_on_turn)
		self.memory_on_turn = {'cast spell': {c: False for c in current_team.characters},
								'move': {c: False for c in current_team.characters}
								}

	def serialize_memory_on_turn(self):
		memory_serialized = {}
		for action, mem in self.memory_on_turn.items():
			mem_s = {character.id_character : boolean for character, boolean in mem.items()} 
			memory_serialized[action] = mem_s
		return memory_serialized

	def _update_character_cell(self, character, new_cell):
		# Data protection
		if character is None:
			return # TODO: RAISE A NULL ERROR
		elif new_cell is None:
			return # TODO: RAISE A NULL ERROR
		elif new_cell.kind != 'floor':
			return # TODO: RAISE A WORKFLOW ERROR
		
		if not character.current_cell is None:
			character.current_cell.kind = 'floor'
		
		character.current_cell = new_cell
		new_cell.kind = 'blocked'



