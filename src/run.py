#!/usr/bin/env python3
import argparse
import time
import docker
from docker_monitor import monitor_docker_service

def print_message(service_name,msg_prefix):
    (status, err_msg) = monitor_docker_service(service_name)
    if msg_prefix != "":
        err_msg = "%s\n%s" % (msg_prefix, err_msg)
    print("%s: %s" % (status, err_msg))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--slack_token', required=False, \
                        help="Slack Token.", type=str)
    parser.add_argument('--slack_channel', required=False, \
                        help="Slack channel to get alerts.", type=str)
    parser.add_argument('--service', default='', required=True, \
                        help="The name of the service to check", type=str)
    parser.add_argument('--check_interval', default='300', required=False, \
                        help="Periodical check. By seconds.", type=int)
    parser.add_argument('--msg_prefix', default = '', required=False, \
                        help="Slack message prefix.", type=str)
    parser.add_argument('--test', default = '', required=False, \
                        help="run a test and stop", type=str)

    l = parser.parse_args()
    check_interval = l.check_interval
    service_name = l.service
    is_test_str = l.test
    #slack_channel = l.slack_channel
    #slack_token = l.slack_token
    msg_prefix = l.msg_prefix

    #if slack_channel == '':
    #    print("Warning: Please provide slack channel, to receive alerts properly.")
    #if slack_token == '':
    #    print("Warning: Please provide slack token.")

    #slack_client = SlackClient(slack_token)

    # TODO
    #slack_username = "@denny"

    if is_test_str == 'true' or  is_test_str == 'yes':
        print_message(service_name,msg_prefix)
    else:
        has_send_error_alert = False
        while True:
            (status, err_msg) = monitor_docker_service(service_name)
            if msg_prefix != "":
                err_msg = "%s\n%s" % (msg_prefix, err_msg)
            print("%s: %s" % (status, err_msg))
            # if status == "OK":
            #     if has_send_error_alert is True:
            #         # TODO write OK on page
            #         has_send_error_alert = False
            # else:
            #     if has_send_error_alert is False:
            #         # TODO write something else on page
            #         # avoid send alerts over and over again
            #         has_send_error_alert = True
            time.sleep(check_interval)
