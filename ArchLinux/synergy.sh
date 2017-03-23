#!/bin/bash

# silently kill synergyc
killall synergyc 2>/dev/null

synergyc -d ERROR 192.168.51.210
