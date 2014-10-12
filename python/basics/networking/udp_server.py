#!/usr/bin/env python2
# -*- coding: utf-8 -*-

# This program receive a udp packet and then exit

def Entry():

	port = 12345
	maxReceiveSize = 1024
	timeout = 60
	
	import socket
	udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	udp.bind(("",port))
	udp.settimeout(timeout)
	buffer, address = udp.recvfrom(maxReceiveSize)
	

	print("address:" + str(address))
	print("content size = " + str(len(buffer)))
	
	import pprint
	pprint.pprint(buffer)


Entry()

