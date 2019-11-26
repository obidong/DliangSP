import socket

maya = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
maya.connect(("localhost", 9001))
maya.send(bytes("print 'hello'", encoding = 'utf-8'))
maya.close()
