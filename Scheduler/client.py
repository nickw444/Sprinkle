import jsonrpclib
import datetime
import pytz
server = jsonrpclib.Server('http://127.0.0.1:8002')

server.set_mode(mode='AUTO', circuit=0)
# server.set_mode(mode='OFF', circuit=0)
# print(server.get_schedule())
# server.rm_schedule('9dd1e7175cca4dd28ef39056c03381a7')

# server.set_mode(mode='ON',circuit=0,duration=5)
# print(server.get_mode(0))
# server.add_schedule(
#     circuit=0,
#     days='mon,tue,wed,thu,fri,sat,sun',
#     hour=0,
#     minute='*',
#     duration=5
# )