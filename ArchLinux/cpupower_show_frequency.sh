#!/bin/sh
# checks frequency of all cores, can be used with watch
cpupower -c all frequency-info | grep "current CPU frequency: [0-9]"
