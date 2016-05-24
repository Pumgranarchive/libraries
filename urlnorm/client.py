#!/usr/bin/python

import zmq, sys, json, re

host = "localhost"
port = "7654"

def connect():
    context = zmq.Context()
    socket = context.socket(zmq.REQ)
    socket.connect("tcp://"+ host +":"+ port)
    return socket

def send(socket, txt):
    socket.send(txt)
    return socket.recv()

def main():
    socket = connect()
    input_data = json.dumps(["https://toto.com#hello"])
    output_data = send(socket, input_data)
    print output_data

main()
