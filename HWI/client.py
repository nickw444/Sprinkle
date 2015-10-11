import jsonrpclib
server = jsonrpclib.Server('http://raspberrypi:8001')
print(server.set_port(0, True))
print(server.get_port(0))