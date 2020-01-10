#!/bin/bash
# full power cpu!
echo ".:: "`date`" setting cpu to full power"
for i in {8..15..1}
do
 sudo cpupower -c "$i" frequency-set -g performance >/dev/null 2>&1
done

# full volume!
echo ".:: "`date`" setting volume to 100%"
pactl set-sink-volume $(pactl list short sinks | grep RUNNING | cut -f1) 100% >/dev/null 2>&1

# wait a bit
sleep 1

# start vm
echo ".:: "`date`" starting vm"
virsh -c "qemu:///system" start win10-2 >/dev/null 2>&1

# wait a bit before looping
sleep 10

# loop around till vm is shut down
echo ".:: "`date`" start looping to check running state"
status=$(virsh -c "qemu:///system" list --all | grep " win10-2 " | awk '{ print $3}')
while ([ "$status" != "" ] && [ "$status" == "running" ])
do
  sleep 10
  status=$(virsh -c "qemu:///system" list --all | grep " win10-2 " | awk '{ print $3}')
done
echo ".:: "`date`" vm seems to be shutdown"

# volume back to normal
echo ".:: "`date`" setting volume to 25%"
pactl set-sink-volume $(pactl list short sinks | grep RUNNING | cut -f1) 25% >/dev/null 2>&1

# cpu back to normal
echo ".:: "`date`" setting cpu back to normal"
for i in {8..15..1}
do
  sudo cpupower -c "$i" frequency-set -g ondemand >/dev/null 2>&1
done
