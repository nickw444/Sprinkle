import jsonrpclib
import datetime
import pytz
server = jsonrpclib.Server('http://127.0.0.1:8002')

# server.set_mode(mode='AUTO', circuit=0)
# print(server.get_zones())
# print(server.set_zone(0, 'My Zone!'))
# server.set_mode(mode='OFF', circuit=1)
# print(server.get_schedule())
# server.rm_schedule('9dd1e7175cca4dd28ef39056c03381a7')

# server.set_mode(mode='ON',circuit=0,duration=5)
# print(server.get_mode(0))
rv = server.add_schedule(
    circuit=0,
    days='mon,tue,wed,thu,fri',
    hour=19,
    minute=44,
    duration=3806
)

print(rv)