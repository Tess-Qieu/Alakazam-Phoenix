#!/usr/bin/env python3


import asyncio
import websockets
from websockets.exceptions import ConnectionClosedError, ConnectionClosedOK
import json
import logging

from ManagerLobbys import ManagerLobbys
from ManagerID import ManagerID




class User():
    '''This class holds the variables needed to represent a user.'''

    def __init__(self, websocket, path, pseudo, user_id):
        self.websocket = websocket
        self.path = path
        self.pseudo = pseudo
        self.user_id = user_id
        self.current_lobby = None



class Server():
    '''This class holds all the variables and functions the server needs.'''

    def __init__(self):
        logging.basicConfig()
        self.users = dict()
        self.manager_lobbys = ManagerLobbys(self)
        self.users_manager_id = ManagerID()


    ## MANAGE CONNECTION WITH CLIENT ##
    async def run(self, websocket, path):
        print('New connection received.')
        try:    
            await self.accept_connection(websocket, path)
            async for message in websocket:
                await self._on_message(websocket, message)
        except ConnectionClosedError:
            pass
        except ConnectionClosedOK:
            pass
        finally:
            await self.close_connection(websocket)

    async def accept_connection(self, websocket, path):
        data = await self.receive_data(websocket)
        if data['action'] != 'connection':
            raise Exception('NetworkError: Expect Action to be a Connection.')
        pseudo = data['details']['pseudo']

        new_id = self.users_manager_id.get_new_id()
        
        # Addition of a pseudo if no one is given
        if pseudo == '':
            pseudo = 'fool_{}'.format(new_id)
        
        self.add_user(websocket, path, pseudo, new_id)

        response = {'action' : 'connection', 'details' : {'user id' : new_id}}
        await self.send_data(websocket, response)

    async def close_connection(self, websocket):
        user = self.users[websocket]
        print(f'User {user.pseudo} closed the connection.')

        await self.manager_lobbys._quit_lobby(user)
        self.remove_user(websocket)

    async def _on_message(self, websocket, message):
        # Called when a new message is received
        data = self.decode_msg(websocket, message)
        user = self.users[websocket]
        await self.manager_lobbys._on_message(data, user)




    ## MANAGE USERS DICTIONARY ##
    def add_user(self, websocket, path, pseudo, user_id):
        user = User(websocket, path, pseudo, user_id)
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

        def transform_key_to_int(data):
            new_data = {}
            for k, v in data.items():
                if isinstance(v, dict):
                    v = transform_key_to_int(v)
                try:
                    k = int(k)
                except:
                    pass
                new_data[k] = v
            return new_data

        data = json.loads(msg.decode())
        data = transform_key_to_int(data)
        if websocket in self.users.keys():
            print(f"< from {self.users[websocket].pseudo} : {data}")
        else:
            print(f"< from unknown client : {data}")
        return data

    def encode_data(self, websocket, data):
        msg = json.dumps(data).encode()
        if websocket in self.users.keys():
            print(f"> to {self.users[websocket].pseudo} : {data}")
        else:
            print(f"> to unknown client : {data}")
        return msg






server = Server()
start_server = websockets.serve(server.run, "localhost", 4225)

print('Server launched, waiting for connections...')
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()