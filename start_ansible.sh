#!/bin/bash

sh ip_setup.sh

sh ip_vars_setup.sh

ansible-playbook -i inventory.ini setup_connect.yml