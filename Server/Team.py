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
