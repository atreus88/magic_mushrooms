for i in {1..14}; do n=`printf "%03d\n" $i`; echo -n "sea-z-worker${n}:   ";ssh root@sea-z-worker$n "initctl list | grep master_zoosk_worker_facebookjobsWithoutDelayworker"; done
