#!/usr/bin/env python3
import argparse
import time
import os
from http.server import HTTPServer
from server import Server

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--hostname', default='0.0.0.0', required=False, \
                        help="the hostname for this server", type=str)
    parser.add_argument('--port', default='8000', required=False, \
                        help="the port where the server is running", type=int)
    parser.add_argument('--service', default='', required=True, \
                        help="The name of the service to check", type=str)
    l = parser.parse_args()
    host_name = l.hostname
    port_number = l.port
    service_name = l.service

    httpd = HTTPServer((host_name, port_number), Server)
    print(time.asctime(), 'Server UP - %s:%s' % (host_name, port_number))
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
print(time.asctime(), 'Server DOWN - %s:%s' % (host_name, port_number))
