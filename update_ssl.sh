#!/bin/bash
MYHOST=`hostname -s | awk -F "-" {'print $1'}`
configured_server_key=/var/ops/ssl/server.key
configured_server_crt=/var/ops/ssl/server.crt
configured_intermediate_crt=/var/ops/ssl/ca.crt/rapidssl-ca.crt
new_server_key=/var/ops/ssl/new_ssl/server.key
new_server_crt=/var/ops/ssl/new_ssl/server.crt
new_intermediate_crt=/var/ops/ssl/new_ssl/rapidssl-ca.crt

echo "Proposed new SSL files below. Usage: -f update -b revert to last SSL cert"
echo $new_server_key
echo $new_server_crt
echo $new_intermediate_crt

if [[ ! -d /var/ops/ssl/old_ssl ]]
then
  mkdir /var/ops/ssl/old_ssl
fi

while getopts fb options
do
  case $options in
    f) 
      if [[ -f $new_server_key && -f $new_server_crt && -f $new_intermediate_crt ]]
      then
	 if [[ -f $configured_intermediate_crt && -f $configured_server_crt && -f $configured_intermediate_crt ]]
	 then
	   echo "Backing up older certificates..."
           cp $configured_server_key /var/ops/ssl/old_ssl/server.key.`date +%F%S`
           cp $configured_server_crt /var/ops/ssl/old_ssl/server.crt.`date +%F%S`
           cp $configured_intermediate_crt /var/ops/ssl/old_ssl/intermediate.crt.`date +%F%S`
	   echo "Updating certificates..."
           cp $new_server_key $configured_server_key
           cp $new_server_crt $configured_server_crt
           cp $new_intermediate_crt $configured_intermediate_crt
	   echo "Restarting Apache..."
	   service httpd graceful
	   echo "Test"
	   #exit 0;;
	else
	   echo "ERROR: Configured certs in script do not exist"
	   #exit 1;;
	fi
      else
        echo "ERROR: Configured replacement certs in script do not exist"
        #exit 1;;
      fi	
      exit 0;;
    b) 
         last_ssl_date=`ls -ltr /var/ops/ssl/old_ssl/ | tail -1 | awk '{print $9}' | awk -F "." '{print $3}'`
	 cp /var/ops/ssl/old_ssl/server.key.${last_ssl_date} $configured_server_key
	 cp /var/ops/ssl/old_ssl/server.crt.${last_ssl_date} $configured_server_crt
	 cp /var/ops/ssl/old_ssl/intermediate.crt.${last_ssl_date} $configured_intermediate_crt
	 service httpd graceful
	 exit 0;;
    \?)
	 echo "Usage: -f update -b revert to last SSL cert"
	 exit 1;;
  esac
done
