from gpiocrust import Header, OutputPin

"""
Talk to this HWI by referencing ports 0 through 7 (or more)
"""

port_numbers = [3, 5, 7, 8, 10, 11, 12, 13, 15, 16, 18, 19, 21, 22, 23, 24]

with Header() as header:

    class GPIOInterface(object):
        def __init__(self):
            self.ports = []
            pass

        def configure_ports(self, port_numbers):
            if len(self.ports): raise Exception("Already configured.")
            for port_no in port_numbers:
                port = OutputPin(port_no)
                port.value = 0
                self.ports.append(port)

        def set_port(self, port_index, value):
            # Make sure they gave us a valid port
            if port_index < len(self.ports):
                self.ports[port_index].value = value
                return True
            else:
                print("Invalid port was given ({}). Ignoring".format(port))
                return False

        def get_port(self, port_index):
            if port_index < len(self.ports):
                return self.ports[port_index].value
            else:
                print("Invalid port was given ({}). Ignoring".format(port))

    def main(argv):
        from jsonrpclib.SimpleJSONRPCServer import SimpleJSONRPCServer
        gpio = GPIOInterface()
        gpio.configure_ports(port_numbers)

        hostname = '127.0.0.1'
        port = 8001
        if '-h' in sys.argv:
            hostname = sys.argv[sys.argv.index('-h') + 1]

        if '-p' in sys.argv:
            port = int(sys.argv[sys.argv.index('-p') + 1])

        s = SimpleJSONRPCServer((hostname, port))
        s.register_function(gpio.set_port)
        s.register_function(gpio.get_port)
        s.serve_forever()

    if __name__ == '__main__':
        import sys
        main(sys.argv)