#!/bin/sh
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# WARNING:  Running this script (or anything else over SSH) may void your warranty.
#
# WARNING:  Use at your own risk.  The author of this script is not responsible
# for any damage this script may cause to your system.  That said, the author 
# does not anticipate any hardware or software risk from this script.
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#############################################################################
# ABOUT THIS SCRIPT:
#
# Per the following thread, WD MyCloud devices are prone to an as-of-yet unknown 
# firmware bug which causes the ufraw-batch process to hang indefinitely or for
# inordinate durations while generating thumbnails of Canon Raw (CR2) files.
# https://community.wd.com/t/help-ufraw-batch-running-for-9-days-straight-device-completely-unusable/213776/37
#
# This script periodically checks if "ufraw-batch" is running, allows each 
# instance some time to try to complete nominally, and kills the process if the
# allowable duration runs out.
#
# The effective allowable run time for each process is dictated by the check
# period and allowed number of cycles, as follows: 
#      allowableDuration = waitSecBetweenChecks * persistence
# i.g. if persistence==4 and waitSecBetweenChecks==30 then allowableDuration=120 sec
waitSecBetweenChecks=30  # sec between checks cycles
persistence=4   # number of check cycles the process is allowed to live
#  
#############################################################################
# TO USE THIS SCRIPT:
#
# In an SSH session, navigate to the directory where you stored the script.
# If for example you put the script in your Public folder, then, within your 
# ssh session, you can get to that directory as follows:
#   cd /shares/Volume_1/Public/
#
# From there, you need to make the script executable (for root only):
#   chmod u+x ./stop_ufraw.sh
#
# Then run it via ash shell, as follows:
#   ash ./stop_ufraw.sh  
#
# And let it run or until it stops finding hung processes.  
# This may take a very long time!
#############################################################################
#
#
#
# Start looping forever...
while true; do
	echo ""
	date;
	
	openCr2Files=$(ps aux | grep CR2 | grep -v grep | sed -r 's|.*(/shares/.*\.CR2).*|\1|g' | grep -i Volume)
	nOpenCr2Files=$(echo "$openCr2Files" | grep -i -c Volume)
	if [ $nOpenCr2Files -gt 0 ]; then
		echo "$nOpenCr2Files open cr2 files:"
		echo "$openCr2Files" | sed 's|^|  |g'
	else
		echo "$nOpenCr2Files open cr2 files"
	fi
	
	# Get current list of ufraw pids:
	ufrawProcessesCurrent=$(ps aux | grep 'ufraw-batch' | grep -v grep | sed 's|^ *||g')
	ufrawPidsCurrent=$(echo "$ufrawProcessesCurrent" | cut -d' ' -f1 | egrep '^[0-9]+' | sort -n )
	
	# Get count:
	nUfrawPidsCurrent=$(echo "$ufrawPidsCurrent" | egrep -c '^[0-9]')
	echo "$nUfrawPidsCurrent ufraw-batch processes are currently running"
	
	# If there are currently some ufraw processes running then check if they've been running for awhile
	if [ $nUfrawPidsCurrent -gt 0 ]; then
	
		# Concatenate current pids list to running list:
		ufrawPidsHistory=$(echo "%s\n%s" "$ufrawPidsHistory" "$ufrawProcessesCurrent")

		# For each currently running process, check if it has been running too long
		for thisCurrentPid in $ufrawPidsCurrent; do
			#
			# If this pid shows up [persistence] times in running list then it's time too kill it
			checkCyclesElapsed=$(echo "$ufrawPidsHistory" | grep -c "$thisCurrentPid")
			echo "  process $thisCurrentPid has been running for $checkCyclesElapsed cycles"
			if [ $checkCyclesElapsed -ge $persistence ]; then
				echo "    killing pid $thisCurrentPid"
				kill $thisCurrentPid;
			fi		
		done
	fi
	
	sleep $waitSecBetweenChecks
done
