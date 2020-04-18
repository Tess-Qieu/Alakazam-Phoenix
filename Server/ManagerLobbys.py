#!/usr/bin/env python3

import asyncio
import Lobby


class ManagerID():
    """ Keep in memory all free games ids."""
    
    def __init__(self, N=1000000):
        self.ids = list(range(N))

    def get_new_id(self):
        return self.ids.pop(0)

    def free_id(self, id):
        self.ids += [id]


class ManagerLobbys():
    """ Used by the server to manage all lobbys. """

    def __init__(self, server):
        self.server = server # usefull to send data to clients
        self.manager_id = ManagerID()
        self.users_waiting_to_play = []
        self.lobbys = {}





    async def _on_message(self, data, user):
        
        if data['action'] == 'ask to play':
            self.users_waiting_to_play += [user]

            if len(self.users_waiting_to_play) >= 2:
                # Two users are waiting, they can play
                await self.new_game()

            else:
                # Only one user is waiting to play, he has to wait
                await self.ask_to_wait(user)


        elif data['action'] == 'new game' :
            await self.transfer_message_to_lobby(data, user)

        elif data['action'] == 'game':
            await self.transfer_message_to_lobby(data, user)

        else:
            print(f'NetworkError: action {data["action"]} not known.')


    def _quit_lobby(self, user):
        # Called when the user quit the lobby
        if user in self.users_waiting_to_play:
            self.users_waiting_to_play.remove(user)

        elif user.current_lobby is not None:
            self.lobbys[user.current_lobby.id_lobby]._quit_lobby(user)





    async def ask_to_wait(self, user):
        # Ask the client to wait until the Lobby Manager find an opponent
        data = {'action' : 'ask to wait', 'details' : {}}
        await self.server.send_data(user.websocket, data)
    

    async def new_game(self):
        # Create a new game
        user_1 = self.users_waiting_to_play.pop(0)
        user_2 = self.users_waiting_to_play.pop(0)
        print(f'New game with users {user_1.pseudo} and {user_2.pseudo}.')
        
        id_lobby = self.manager_id.get_new_id()
        lobby = Lobby.Lobby(self.server, id_lobby, [user_1, user_2])
        self.lobbys[id_lobby] = lobby

        await lobby.notify_new_game()

        user_1.current_lobby = lobby
        user_2.current_lobby = lobby

    async def transfer_message_to_lobby(self, data, user):
        lobby_id = data['details']['id']
        await self.lobbys[lobby_id]._on_message(data, user)