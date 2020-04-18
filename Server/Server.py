#!/usr/bin/env python3


import asyncio
import websockets
from websockets.exceptions import ConnectionClosedError
import json
import logging

import ManagerLobbys



class User():
    '''This class holds the variables needed to represent a user.'''

    def __init__(self, websocket, path, pseudo):
        self.websocket = websocket
        self.path = path
        self.pseudo = pseudo
        self.current_lobby = None



class Server():
    '''This class holds all the variables and functions the server needs.'''

    def __init__(self):
        logging.basicConfig()
        self.users = dict()
        self.manager_lobbys = ManagerLobbys.ManagerLobbys(self)


    ## MANAGE CONNECTION WITH CLIENT ##
    async def run(self, websocket, path):
        print('New connection received.')
        try:    
            await self.accept_connection(websocket, path)
            async for message in websocket:
                await self._on_message(websocket, message)
        except ConnectionClosedError:
            pass
        finally:
            self.close_connection(websocket)

    async def accept_connection(self, websocket, path):
        data = await self.receive_data(websocket)
        if data['action'] != 'connection':
            raise Exception('NetworkError: Expect Action to be a Connection.')
        pseudo = data['details']['pseudo']

        self.add_user(websocket, path, pseudo)

        response = {'action' : 'connection', 'details' : {'accept' : True}}
        await self.send_data(websocket, response)

    def close_connection(self, websocket):
        user = self.users[websocket]
        print(f'User {user.pseudo} closed the connection.')

        self.manager_lobbys._quit_lobby(user)
        self.remove_user(websocket)

    async def _on_message(self, websocket, message):
        # Called when a new message is received
        data = self.decode_msg(websocket, message)
        user = self.users[websocket]
        await self.manager_lobbys._on_message(data, user)




    ## MANAGE USERS DICTIONARY ##
    def add_user(self, websocket, path, pseudo):
        user = User(websocket, path, pseudo)
        self.users[websocket] = user

    def remove_user(self, websocket):
        del(self.users[websocket])



    ## COMMUNICATION FUNCTIONS ##
    async def receive_data(self, websocket):
        msg = await websocket.recv()
        return self.decode_msg(websocket, msg)

    async def send_data(self, websocket, data):
        msg = self.encode_data(websocket, data)
        await websocket.send(msg)

    def decode_msg(self, websocket, msg):
        data = json.loads(msg.decode())
        if websocket in self.users.keys():
            print(f"< from {self.users[websocket].pseudo} : {data}")
        else:
            print(f"< from unknown client : {data}")
        return data

    def encode_data(self, websocket, data):
        msg = json.dumps(data).encode()
        if websocket in self.users.keys():
            print(f"> to {self.users[websocket].pseudo} : {msg.decode()}")
        else:
            print(f"> to unknown client : {msg.decode()}")
        return msg






server = Server()
start_server = websockets.serve(server.run, "localhost", 4225)

print('Server launched, waiting for connections...')
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()