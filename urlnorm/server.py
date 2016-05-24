#!/usr/bin/python

import zmq, sys, json, re
import urlnorm

port = "7654"

def bind():
    context = zmq.Context()
    socket = context.socket(zmq.REP)
    socket.bind("tcp://*:%s" % port)
    return socket

def listen(socket, func):
    while True:
        try :
            input_data = json.loads(socket.recv())
            output_data = json.dumps(func(input_data))
            socket.send(output_data)
        except KeyboardInterrupt:
            break;
        except :
            print(sys.exc_info())
            socket.send("{error:'internal server error'}")

def norm(url):
    url = urlnorm.norm(url)
    url = re.sub("^https:", "http:", url)
    url = re.sub("^www\.", "", url)
    url = re.sub("#.+$", "", url)
    return url

def compute(urls):
    return map(norm, urls)

def main():
    listen(bind(), compute)

main()
