#!/bin/bash

#The architecture of your operating system and its kernel version.
arch=$(uname -a)

#The number of physical processors.
core=$(lscpu | grep "Core(s)" | awk '{print $4}')
socket=$(lscpu | grep "Socket(s)" | awk '{print $2}')
cpup=$((core * socket))

#The number of virtual processors.
thread=$(lscpu | grep "Thread(s)" | awk '{print $4}')
cpuv=$((thread * core))

#The current available RAM on your server and its utilization rate as a percentage.
used=$(free -m | grep "Mem:" | awk '{print $3}')
total=$(free -m | grep "Mem:" | awk '{print $2}')
rate=$(printf "%.2f" "$(echo "100 * $used / $total" | bc)")
muse="$used/$(echo "$total")MB ($rate%)"

#The current available storage on your server and its utilization rate as a percentage.
duse="$(df --total -h | grep total | sed 's/G//g' | awk '{print $3 "/" $2 "GB (" $5 ")"}')"

#The current utilization rate of your processors as a percentage.
idle="$(mpstat -u | tail -1 | awk '{print $13}')"
cpul="$(printf "%.2f" "$(echo "100 - $idle" | bc)")%"

#The date and time of the last reboot.
lstb="$(uptime -s | sed 's/\(.*\):.*/\1/')"

#Whether LVM is active or not.
lvm_use="$(lsblk | grep "lvm")"
lvm="$(if [ -n "$lvm_use" ]; then echo "yes"; fi)"

#The number of active connections.
tcp="$(ss -t state established | sed '1d' | wc -l) ESTABLISHED"

#The number of users using the server.
log="$(w | sed '1,2d' | wc -l)"

#The IPv4 address of your server and its MAC address.
ip="IP $(hostname -I)"
mac="$(ip link | grep "ether" | awk '{print $2}')"
net="$ip ($mac)"

#The number of commands executed with the sudo program.
sudo_cnt=$(grep "COMMAND=" /var/log/sudo/sudo.log | wc -l)
sudo=""$sudo_cnt" cmd"

#The script of monitoring.
monitor="
        #Architecture: $arch
        #CPU physical: $cpup
        #vCPU: $cpuv
        #Memory Usage: $muse
        #Disk Usage: $duse
        #CPU load: $cpul
        #Last boot: $lstb
        #LVM use: $lvm
        #Connection TCP: $tcp
        #User log: $log
        Network: $net
        #Sudo: $sudo
"

#Command to monitor.
wall "$monitor"
