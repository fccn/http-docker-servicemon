#import requests
#import requests
#import re
#import requests_unixsocket
import json
import time
import docker


def name_in_list(name, name_pattern_list):
    for name_pattern in name_pattern_list:
        if re.search(name_pattern, name) is not None:
            return True
    return False
################################################################################

def list_docker_services(service_name):
    service_list = []
    client = docker.from_env()
    for service in client.services.list(filters={"name": service_name}):
        for task in service.tasks({"desired-state":"Running"}):
            item = (service.name,task["Status"]["State"],task["Status"]["Message"])
            service_list.append(item)
    return service_list

def count_running_services(service_list):
    running = 0
    for service in service_list:
        (names, status, message) = service
        if "running" in status:
            running += 1
    return running

def count_not_running_services(service_list):
    not_running = 0
    for service in service_list:
        (names, status, message) = service
        if not "running" in status:
            not_running += 1
    return not_running

def service_list_to_str(service_list):
    msg = ""
    for service in service_list:
        (name, status, message) = service
        msg += " - %s[%s] - %s \n" % (name, status, message)
    return msg

def monitor_docker_service(service_name):
   service_list = list_docker_services(service_name)
   service_list_str = service_list_to_str(service_list)
   total_num = len(service_list)
   num_running = count_running_services(service_list)
   num_not_running = count_not_running_services(service_list)

   if num_running > 0 and num_not_running == 0:
       return("OK\n", service_list_str)
   elif num_running == 0:
       if num_not_running == 0:
           return ("ERROR", "service is stopped")
       else:
           return ("ERROR", "service is not started: \n%s" % (service_list_str))
   else:
       return("FAIL", "not all services are started [%s/%s]:  \n%s" % (num_running,total_num,service_list_str))
