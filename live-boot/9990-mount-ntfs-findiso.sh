#!/bin/sh

if [ -n "${FINDISO}" ];then
    awk '{if ($2 == "/live/findiso") {print $3, $2} }' /proc/mounts | while read fstype devname
    do
        loopdevname=$(/sbin/losetup --noheading --list | grep /live/findiso/ | awk '{print $1}')
        isofile=$(/sbin/losetup --noheading --list | grep /live/findiso/ | awk '{print $6}')
        if [ -n "${loopdevname}" ];then 
            mountpoint=$(cat /proc/mounts | grep ${loopdevname} | awk '{print $2}')
            if [ -n "${mountpoint}" ];then
                /sbin/losetup -d ${loopdevname}
    	    umount ${mountpoint}
            fi
        fi
    
        if [ "$fstype" = "ntfs" ];then
    	modprobe fuse
    	mount -t ntfs-3g -o remount,rw,noatime "${devname}" /live/findiso
        else
    	mount -t $fstype -o remount,rw,noatime "${devname}" /live/findiso
        fi 
    
        if [ -n "${mountpoint}" ];then 
            /sbin/losetup ${loopdevname} ${isofile}
    	mount -t iso9660 -o ro,noatime "${loopdevname}" ${mountpoint}
        fi
    
    done
fi
