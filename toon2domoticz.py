#!/usr/bin/python
# -*- coding: utf-8 -*-

# domoticz server & port information
domoticzserver = "192.168.1.50:8084"

# domoticz uservariable name to set the Toon state
uservariable = "varToonState"


# Do not change anything beyond this line
#___________________________________________________________________________________________________

import pprint
from Toon import Toon
import argparse
import urllib
import urllib2
import urlparse

parser = argparse.ArgumentParser(description='Communicate with the Eneco Toon thermostat')
parser.add_argument('-U', '--username', help='the Toon username', required=True, dest='username')
parser.add_argument('-P', '--password', help='the Toon password', required=True, dest='password')

args = parser.parse_args()

username = args.username
password = args.password

toon = Toon(username, password)
toon.login()

state = toon.get_program_state()
url = 'http://'+domoticzserver+'/json.htm?type=command&param=updateuservariable&vname='+uservariable+'&vtype=0'
params = {'vvalue':state}
url_parts = list(urlparse.urlparse(url))
query = dict(urlparse.parse_qsl(url_parts[4]))
query.update(params)
url_parts[4] = urllib.urlencode(query)
urllib2.urlopen(urlparse.urlunparse(url_parts))

toon.logout()
