#!/usr/bin/env python3


import asyncio
import websockets
import json
import logging

import ManagerLobbys

logging.basicConfig()

USERS = dict()


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




async def accept_connection(websocket):
    data = await receive_data(websocket)
    if data['action'] != 'connection':
        raise Exception('NetworkError: Expect Action to be a Connection.')
    pseudo = data['details']['pseudo']

    USERS[websocket] = pseudo

    response = {'action' : 'connection', 'details' : {'accept' : True}}
    await send_data(websocket, response)

def close_connection(websocket):
    print(f'User {USERS[websocket]} closed the connection.')
    del(USERS[websocket])





def handle_message(msg):
    data = decode_msg(msg)
    print(data)

async def socket_connection(websocket, path):

    print('New connection received.')

    await accept_connection(websocket)
    try:    
        async for message in websocket:
            handle_message(message)
    except:
        pass
    finally:
        close_connection(websocket)


start_server = websockets.serve(socket_connection, "localhost", 4225)

print('Server launched, waiting for connections...')
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()