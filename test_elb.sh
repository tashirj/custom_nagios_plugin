#!/bin/bash
N=0
CRITICAL=0
cat /etc/ahalife/elblist | while read LINE ; do
        N=$((N+1))
        ELB_DETAILS=`echo $LINE`

        ELB_NAME=`echo $LINE | awk '{print $1}'`  #### Load balancer name

        ELB_INSTANCES=`echo $LINE | awk '{print $2}'` #### Defined Number of instances on ELB

	THRESHOLD_VALUE=`echo $LINE | awk '{print $3}'` ### Min Number of instances should be on ELB
	ACTUAL_VALUE=`/usr/local/bin/aws elb describe-instance-health --load-balancer $ELB_NAME | grep -i inservice | wc -l` 
	if [ "$ACTUAL_VALUE" -le "$CRITICAL" ] ; then
		echo  "Number of Standard Instances behind $ELB_NAME: $ELB_INSTANCES

THRESHOLD VALUE of Instances for $ELB_NAME: $THRESHOLD_VALUE

ACTUAL VALUE of  Instances for $ELB_NAME: $ACTUAL_VALUE" | mail -s "CRITICAL: Load Balancer $ELB_NAME : InService Instances: $ACTUAL_VALUE" "engineering@ahalife.com"
	else
	if [ "$ACTUAL_VALUE" -ge "$THRESHOLD_VALUE" ] ; then
		echo  "Number of Standard Instances behind $ELB_NAME: $ELB_INSTANCES

THRESHOLD VALUE of Instances for $ELB_NAME: $THRESHOLD_VALUE

ACTUAL VALUE of  Instances for $ELB_NAME: $ACTUAL_VALUE" | mail -s "WARNING: Load Balancer $ELB_NAME : InService Instances: $ACTUAL_VALUE" "engineering@ahalife.com"
	
	else
	if [[ "$ACTUAL_VALUE" -gt "$THRESHOLD_VALUE" ] ; then
		echo  "OK: All servers are running InService behind ELB $ELB_NAME" 
	fi
	
done
