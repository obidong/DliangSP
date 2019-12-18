#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# this file has been converted to connect_maya.exe and no longed needed. 
import socket,sys,json

def create_shading_network():
	args = sys.argv
	port_num = args[1]
	shader_name = args[2]
	channel_info = args[3]
	render_engine = args[4]
	maya = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	maya.connect(("localhost", int(port_num)))
	maya.send('''import DliangSP_Maya.bridge;reload(DliangSP_Maya.bridge); DliangSP_Maya.bridge.run('%s','%s','%s')'''%(shader_name, channel_info, render_engine))
	maya.close()

if __name__ == '__main__':
	create_shading_network()     
