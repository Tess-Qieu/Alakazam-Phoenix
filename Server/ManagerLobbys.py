#!/usr/bin/env python3

import asyncio

from Game import Game
from ManagerID import ManagerID



class ManagerLobbys():
    """ Used by the server to manage all lobbys. """

    def __init__(self, server):
        self.server = server # usefull to send data to clients
        self.lobbys_manager_id = ManagerID()
        self.users_waiting_to_play = []
        self.lobbys = {}





    async def _on_message(self, data, user):
        # Manage the message from the clients
        
        if data['action'] == 'ask to play':
            self.users_waiting_to_play += [user]

            if len(self.users_waiting_to_play) >= 2:
                # Two users are waiting, they can play
                await self.new_lobby()

            else:
                # Only one user is waiting to play, he has to wait
                await self.ask_to_wait(user)


        elif data['action'] == 'new game' :
            await self.transfer_message_to_lobby(data, user)

        elif data['action'] == 'game':
            await self.transfer_message_to_lobby(data, user)

        else:
            print(f'NetworkError: action {data["action"]} not known.')



    # /!\ Only manage deconnection for now
    async def _quit_lobby(self, user):
        # Called when the user quit the lobby
    
        def destroy_lobby(self, lobby):
            for user in lobby.players + lobby.observators:
                user.current_lobby = None

            id_lobby = lobby.id_lobby
            self.lobbys_manager_id.free_id(id_lobby)
            
            del(self.lobbys[id_lobby])
            del(lobby)
            print(f'Lobby {id_lobby} destroyed.')

        
        if user in self.users_waiting_to_play:
            # if user is waiting to find an opponent
            self.users_waiting_to_play.remove(user)

        elif user.current_lobby is not None:
            # If user is in a Lobby
            lobby = user.current_lobby
            game_continue = await lobby._quit_lobby(user)

            if not game_continue:
                destroy_lobby(self, lobby)







    async def ask_to_wait(self, user):
        # Ask the client to wait until the Lobby Manager find an opponent
        data = {'action' : 'ask to wait', 'details' : {}}
        await self.server.send_data(user.websocket, data)
    

    async def new_lobby(self):
        # Create a new game
        user_1 = self.users_waiting_to_play.pop(0)
        user_2 = self.users_waiting_to_play.pop(0)
        
        id_lobby = self.lobbys_manager_id.get_new_id()
        lobby = Game(self.server, id_lobby, [user_1, user_2])
        self.lobbys[id_lobby] = lobby

        print(f'New lobby {id_lobby} with users {user_1.pseudo} and {user_2.pseudo}.')
        await lobby.notify_new_lobby()
        lobby.begin()

        user_1.current_lobby = lobby
        user_2.current_lobby = lobby

    async def transfer_message_to_lobby(self, data, user):
        # Find the appropriate lobby and call his _on_message function
        id_lobby = data['details']['id']
        await self.lobbys[id_lobby]._on_message(data, user)
