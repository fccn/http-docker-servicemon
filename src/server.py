from http.server import BaseHTTPRequestHandler
from docker_monitor import monitor_docker_service
import os

class Server(BaseHTTPRequestHandler):
  service_name = os.environ.get('SERVICE_NAME')

  def do_HEAD(self):
    return

  def do_GET(self):
    self.respond()

  def do_POST(self):
    return

  def handle_http(self, status, content_type):
    self.send_response(status)
    self.send_header('Content-type', content_type)
    self.end_headers()
    #(status, err_msg) = monitor_docker_slack("/var/run/docker.sock", self.white_pattern_list)
    (status, err_msg) = monitor_docker_service(self.service_name)
    print("%s: %s" % (status, err_msg))
    return bytes(("%s: %s" % (status, err_msg)), "UTF-8")

  def respond(self):
    content = self.handle_http(200, 'text/html')
    self.wfile.write(content)
