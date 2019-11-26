#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket 
import sys
 
def test():
    args = sys.argv
    maya = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    maya.connect(("localhost", 9001))
    
    # args[0] is connect_maya.py
    maya.send(('''polyCube -n "%s"'''%(str(args[1]))))
    maya.close()
 
if __name__=='__main__':
    test()