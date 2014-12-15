#!/bin/bash
for i in $(seq -f "%03g" 1 4)
do
  echo "add-entries.py --assignhosttohostgroup --host sea-z-admin${i} --hostgroup zoosk-cage-sea-a03"
done
