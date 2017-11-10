# WD_MyCloudMirror_Stupid_Ufraw_Workaround

In WD MyCloud devices, the thumbnail generation process hangs on Canon Raw (CR2) files.  

This script monitors the conversion process and shuts down hung instances of the ufraw-batch converter script.  

---
**WARNING 1:**  Running this script (or anything else over SSH) may void your warranty.  

**WARNING 2:**  Use at your own risk.  The author of this script is not responsible for any damage this script may cause to your system.  That said, the author does not anticipate any hardware or software risk from this script.  

---
**ABOUT THIS SCRIPT:**

Per the following thread, WD MyCloud devices are prone to an as-of-yet unknown 
firmware bug which causes the ufraw-batch process to hang indefinitely or for
inordinate durations while generating thumbnails of Canon Raw (CR2) files.
https://community.wd.com/t/help-ufraw-batch-running-for-9-days-straight-device-completely-unusable/213776/37

This script periodically checks if "ufraw-batch" is running, allows each 
instance some time to try to complete nominally, and kills the process if the
allowable duration runs out.

The effective allowable run time for each process is dictated by the check
period and allowed number of cycles, as follows: 
  allowableDuration = waitSecBetweenChecks * persistence
i.g. if persistence==4 and waitSecBetweenChecks==30 then allowableDuration=120 sec
 
---
**TO USE THIS SCRIPT:**

Download the stop_ufraw.sh script and store it anywhere on your MyCloud NAS.

In an SSH session (see warnings above), navigate to the directory where you stored the script.
If for example you put the script in your Public folder, then, within your 
ssh session, you can get to that directory as follows:
`cd /shares/Volume_1/Public/`

From there, you need to make the script executable (for root only):
`chmod u+x ./stop_ufraw.sh`

Then run it via ash shell, as follows:
`ash ./stop_ufraw.sh`

And let it run or until it stops finding hung processes. This may take a very long time!
