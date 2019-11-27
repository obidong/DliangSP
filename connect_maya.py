#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket 
import sys
 
def create_shading_network():
    args = sys.argv
    port_num = args[1]
    preset = args[2]
    maya = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    maya.connect(("localhost", int(port_num)))
    
    # args[0] is connect_maya.py
    maya.send(('''polyCube -n "%s_%s"'''%(preset,str(port_num))))
    #maya.send("polyCube")
    
    maya.close()
 
if __name__=='__main__':
    create_shading_network()