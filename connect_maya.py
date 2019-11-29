#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket 
import json
import sys, ast, getopt, types

def create_shading_network():
	args = sys.argv
	port_num = args[1]
	shader_name = args[2]
	channel_info = args[3]
	render_engine = args[4]
	channel_token = args[5]
	maya = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	maya.connect(("localhost", int(port_num)))
	#maya.send('''print %s'''%renderer)
	#maya.send('''print %s'''%channel_info)
	maya.send('''import dliang_sp2maya;reload(dliang_sp2maya); dliang_sp2maya.run('%s','%s','%s','%s')'''%(shader_name, channel_info, render_engine,channel_token))
	maya.close()

if __name__ == '__main__':
	create_shading_network()     
