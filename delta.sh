if [[ -f /tmp/medianRequestTime ]]; 
then 
  last_req_time=`cat /tmp/medianRequestTime`
  /usr/lib64/nagios/plugins/check_jmx -U service:jmx:rmi:///jndi/rmi://localhost:8082/jmxrmi -O 'solr/affinity:id=org.apache.solr.handler.component.SearchHandler,type=org.apache.solr.handler.component.SearchHandler' -A medianRequestTime | cut -d '=' -f3 > /tmp/medianRequestTime
  current_req_time=`cat /tmp/medianRequestTime`
  delta=$((last_req_time-current_req_time))
  echo "Delta:"$delta
else
  /usr/lib64/nagios/plugins/check_jmx -U service:jmx:rmi:///jndi/rmi://localhost:8082/jmxrmi -O 'solr/affinity:id=org.apache.solr.handler.component.SearchHandler,type=org.apache.solr.handler.component.SearchHandler' -A medianRequestTime | cut -d '=' -f3 > /tmp/medianRequestTime
  echo "Created new value"
fi
