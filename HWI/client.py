import jsonrpclib
server = jsonrpclib.Server('http://127.0.0.1:8001')
print(server.set_port(0, True))