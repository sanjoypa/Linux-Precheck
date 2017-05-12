#!/bin/ksh
#
######################################################################
######################################################################
#
#  Script: System Information linux.ksh
#    Date: April 27, 2016
#  Author: SANJOY PAUL
# Purpose: To collect system information.
# Version: 1.00 (Last Modified: 27th April, 2016)
#
######################################################################
#
# Global Variables
LOGFILE=pre-reboot-`uname -n`-`date +%d-%m-%Y`.log
LOGFILE1=pre-reboot-`uname -n | tr -s "." "," | cut -d "," -f1`-`date +%d-%m-%Y`.log
PATH=/bin:/usr:/usr/bin:/sbin:/usr/sbin:/opt
OSTYPE=`uname -s`
HOST=`uname -n`
HOSTLINUX=`uname -n | tr -s "." " " | awk '{print $1}'`
OSVER=` test -f /etc/redhat-release && cat /etc/redhat-release`
OSREL=`cat /etc/redhat-release | sed 's/.*elease \(.\).*/\1/'`
SH=#
# Temp Directory
cd /var/tmp
# Log file Diretory
mkdir -p /var/systeminfo
#
# Logging Function
function log {
    echo "$@" >> ${LOGFILE}
}
# Main Program
log ""
	log "Starting Pre-work Activity on $HOST"
	log "Date: `date`"
	log "Server type: ${OSTYPE}"
	log "OS Version: ${OSVER}"
	log "Logfile: ${LOGFILE}"
log ""
if [[ "${OSTYPE}" != 'Linux' ]]; then
	log "Seems you are trying to run the script under ${OSTYPE} operating system, which is not recomended"
exit 0
fi
	log "################## HARDWARE & NETWORK INFORMATION ###################"
log ""
	log "${SH} dmidecode"
log ""
	log "`dmidecode | egrep -i 'product name|serial number|Vendor|Data|Size|Locator|Type|Speed:' | egrep -v 'Not Specified'|sort|uniq`"
echo " Hardware information.................Done"
log ""
	log "${SH} uname -a"
	log "`uname -a`"
echo " Uname information....................Done"
log ""
	log "${SH} uptime"
	log "`uptime`"
echo " Uptime information...................Done"
log ""
	log "${SH} date"
	log "`date`"
log ""
	log "${SH} ifconfig -a"
	log "`ifconfig -a`"
        log ""
        log "${SH} /sbin/ip addr show"
        log "`/sbin/ip addr show`"
log ""
	grep -i 'GATEWAY' /etc/sysconfig/network >/dev/null 2>&1
	if [ $? = 0 ]; then
    	log "${SH} grep -i 'GATEWAY' /etc/sysconfig/network" 
    	log "`grep -i 'GATEWAY' /etc/sysconfig/network`"
	elif [ $? != 0 ]; then
		grep -i 'GATEWAY' /etc/sysconfig/network-scripts/ifcfg-* >/dev/null 2>&1
		if [ $? = 0 ]; then
		log "${SH} cat /etc/sysconfig/network-scripts/ifcfg-* | grep -i GATEWAY"
		for gw in `grep -i 'GATEWAY' /etc/sysconfig/network-scripts/ifcfg-* | tr -s "/" " " | awk '{print $4}'`
		do
		log "$gw"
		done
                fi
fi
echo " Gateway information ..................Done"
log ""
	log "${SH} /sbin/route -n"
	log "`route -n`"
echo " Routing information..................Done"
	log ""
	log "${SH} /sbin/iptables -t filter -nvL"
	log "`iptables -t filter -nvL`"
echo " Iptables information.................Done"
log ""
	log "${SH} netstat -rn"
	log "`netstat -rn`"
log ""
	log "${SH} netstat -in"
	log "`netstat -in`"
echo " Netstat information..................Done"
#log ""
#  for t in `ls /etc/sysconfig/network-scripts/ifcfg-* | cut -d "/" -f5 | cut -d "-" -f2`
#  do
#  log "${SH} /sbin/ethtool $t"
#  log "`/sbin/ethtool $t`"
#  log ""
#  done
echo " Network interface details............Done"
  for e in `ls /etc/sysconfig/network-scripts/ifcfg-* | cut -d "/" -f5`
  do
  log "${SH} cat /etc/sysconfig/network-scripts/$e"
	log "`cat /etc/sysconfig/network-scripts/$e`"

  done
echo " IP information.......................Done"
log ""
        log "${SH} ntpq -p"
        log "`ntpq -p`"
	log ""
        log "${SH} cat /etc/resolv.conf"
        log "`cat /etc/resolv.conf`"
        log ""
        log "${SH} cat /etc/hosts"
        log "`cat /etc/hosts`"
        log ""
	log "################ END OF HARDWARE & NETWORK SECTION ##############"
log ""
	log "######################################################"
	log "############## DISK N LUNs SECTION ###################"
	log "######################################################"
log ""
	log "${SH} cat /etc/fstab"
	log "`cat /etc/fstab`"
echo " FSTAB information....................Done"
log ""
        log "${SH} swapon -s"
        log "`swapon -s`"
echo " Swap information.....................Done"
log ""
	log "${SH} df -kh"
	log "`df -kh`"
echo " Mounted filesystem information.......Done"
log ""
	log "${SH} pvs"
        log "`pvs`"
        log ""
        log "${SH} vgs"
        log "`vgs`"
        log "${SH} lvs"
        log "`lvs`"
        log ""
        log "${SH} lvs -a -o +devices"
        log "`lvs -a -o +devices`"
        log ""
        log "${SH} pvs -a -o +devices"
        log "`pvs -a -o +devices`"
echo " PV & VG information..................Done"
log""
	log "${SH} df -al"
	log "`df -al`"
	log ""
	log "${SH} mount"
	log "`mount`"
	log ""

log ""
getpartinfo() {
  raiddevs=`/bin/cat /proc/partitions | /bin/egrep -v "^major|^$" | /bin/awk '{print $4}' | /bin/grep \/ | /bin/egrep -v "p[0123456789]$"`
  disks=`/bin/cat /proc/partitions | /bin/egrep -v "^major|^$" | /bin/awk '{print $4}' | /bin/grep -v / | /bin/egrep -v "[0123456789]$"`
  for d in $raiddevs $disks ; do
    echo "<----  Disk: /dev/${d}  ---->"
    echo ""
    /sbin/fdisk -l /dev/${d} 2>&1
    echo ""
    echo "<----    END     ---->"
    done
}
	log "${SH} /sbin/fdisk -l"
	log "`getpartinfo`"
echo " Disk information.....................Done"
echo "                                               "

if [ -x /sbin/multipath ] ; then
        log "${SH} /sbin/multipath -ll"
        log "`/sbin/multipath -ll >/dev/null 2>&1`"
        else

echo "                                               "
echo          " MULTIPATH NOT FOUND"
fi
echo " Multipath information................Done"
log ""

  log "${SH} systool -v -c scsi_host"
  log "`systool -v -c scsi_host >/dev/null 2>&1`"
echo " HBA information......................Done"
	
	log ""
	log "${SH} cat /proc/meminfo | grep MemTotal"
	log "`cat /proc/meminfo | grep MemTotal`"
echo " Memory information...................Done"
log ""
	log "${SH} /sbin/iscsiadm -m node -L all"
        log "`iscsiadm -m node -L all >/dev/null 2>&1`"
echo " ISCSI information ...................Done"
log "################### End of Script ####################"
echo ""
unix2dos $LOGFILE $LOGFILE >/dev/null 2>&1
mv $LOGFILE /var/systeminfo/$LOGFILE >/dev/null 2>&1
echo " "
echo " "
sleep 5
		echo ""
		echo "End of Script. Output saved in /var/systeminfo/$LOGFILE"
		echo ""
	        echo "Use [ scp /var/systeminfo/$LOGFILE userid@10.112.13.109:~ ] to download the log to the Jump Station...."

echo ""
exit 0

