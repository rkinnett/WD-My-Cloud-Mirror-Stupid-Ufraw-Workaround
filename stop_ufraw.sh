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
# This script periodically checks if "ufraw-batch" is running, and terminates
# each instance as it pops up.
#
#############################################################################
# TO USE THIS SCRIPT:
#
# In an SSH session, navigate to the directory where you stored the script.
# If for example you put the script in your password-protected my_private_folder
# folder, then, within your ssh session, you can get to that directory as follows:
#   cd /shares/Volume_1/my_private_folder/
#
# From there, you need to make the script executable (for root only):
#   chmod 744 ./stop_ufraw.sh
#
# Then run it via ash shell, as follows:
#   ash ./stop_ufraw.sh  
#
# And let it run until it stops finding hung processes.  
# This may take a very long time!
#############################################################################
# CONFIGURATION:
#
longWait=60;
shortWait=5;
#
#
#############################################################################
#
# Start looping forever...
while true; do
  echo ""
  date;
  
  # Check if any cr2 files are currently open.  
  # This is informational only; the script does nothing with this.
  openCr2Files=$(ps aux | grep -i CR2 | grep -v grep | sed -r 's|.*(/shares/.*\.[cC][rR]2).*|\1|g' | grep -i Volume)
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

  if [ $nUfrawPidsCurrent -gt 0 ]; then
    # Terminate each instance of ufraw-batch:
    for thisCurrentPid in $ufrawPidsCurrent; do      
      echo "    killing pid $thisCurrentPid"
      kill $thisCurrentPid;
    done
    sleep $shortWait
    
  else
    sleep $longWait
  fi
done
