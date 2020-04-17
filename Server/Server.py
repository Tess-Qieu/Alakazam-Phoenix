#!/usr/bin/env python3


import asyncio
import websockets
import json
import logging

import ManagerLobbys



## COMMUNICATION FUNCTIONS ##
def decode_msg(msg):
    data = json.loads(msg.decode())
    print(f"< {data}")
    return data

def encode_data(data):
    msg = json.dumps(data).encode()
    print(f"> {msg.decode()}")
    return msg

async def receive_data(websocket):
    msg = await websocket.recv()
    return decode_msg(msg)

async def send_data(websocket, data):
    msg = encode_data(data)
    await websocket.send(msg)





class User():
    '''This class holds the variables needed to represent a user.'''

    def __init__(self, websocket, path, pseudo):
        self.websocket = websocket
        self.path = path
        self.pseudo = pseudo




class Server():
    '''This class holds all the variables and functions the server needs.'''

    def __init__(self):
        logging.basicConfig()
        self.users = dict()
        self.manager_lobbys = ManagerLobbys.ManagerLobbys()


    ## MANAGE CONNECTION WITH CLIENT ##
    async def run(self, websocket, path):
        print('New connection received.')
        try:    
            await self.accept_connection(websocket, path)
            async for message in websocket:
                self.handle_message(websocket, message)
        except:
            pass
        finally:
            self.close_connection(websocket)

    async def accept_connection(self, websocket, path):
        data = await receive_data(websocket)
        if data['action'] != 'connection':
            raise Exception('NetworkError: Expect Action to be a Connection.')
        pseudo = data['details']['pseudo']

        self.add_user(websocket, path, pseudo)

        response = {'action' : 'connection', 'details' : {'accept' : True}}
        await send_data(websocket, response)

    def handle_message(self, websocket, message):
        data = decode_msg(message)
        print(data)

    def close_connection(self, websocket):
        print(f'User {self.users[websocket]} closed the connection.')
        self.remove_user(websocket)



    ## MANAGE USERS DICTIONARY ##
    def add_user(self, websocket, path, pseudo):
        user = User(websocket, path, pseudo)
        self.users[websocket] = user

    def remove_user(self, websocket):
        del(self.users[websocket])





server = Server()
start_server = websockets.serve(server.run, "localhost", 4225)

print('Server launched, waiting for connections...')
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()