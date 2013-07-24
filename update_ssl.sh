#!/bin/bash
MYHOST=`hostname -s | awk -F "-" {'print $1'}`
configured_server_key=/var/ops/ssl/server.key
configured_server_crt=/var/ops/ssl/server.crt
configured_intermediate_crt=/var/ops/ssl/ca.crt/rapidssl-intermediate.crt
new_server_key=/var/ops/ssl/new_ssl/server.key
new_server_crt=/var/ops/ssl/new_ssl/server.crt
new_intermediate_crt=/var/ops/ssl/new_ssl/rapidssl-ca.crt

echo "Proposed new SSL files below. Usage: -f update -b revert to last SSL cert"
conf_cert=`openssl x509 -in $configured_server_crt -text -noout | grep Subject | grep CN | cut -d " " -f 20 | sed 's/CN\=//g'`
new_cert=`openssl x509 -in $new_server_crt -text -noout | grep Subject | grep CN | cut -d " " -f 20 | sed 's/CN\=//g'`
if [ $conf_cert = $new_cert ]
then
echo "Good: Domain of replacement cert matchs existing cert"
else
echo "CRITICAL WARNING: configured cert $conf_cert domain does not match proposed cert $new_cert. Only proceed if you know what you are doing"
fi
sdate=`openssl x509 -in $new_server_crt -text -noout | grep "Not Before" | sed 's/^ *//g' | cut -d ':' -f2,3,4`
edate=`openssl x509 -in $new_server_crt -text -noout | grep "Not After" | sed 's/^ *//g' | cut -d ':' -f2,3,4`
sdate_cert=`echo "'$sdate'" | xargs date +%s -d`
today=`date +%s`
edate_cert=`echo "'$edate'" | xargs date +%s -d`
if [ $today -lt $sdate_cert ]
then
echo "CRITICAL WARNING: the replacement SSL certificate is not valid yet. It will become valid on $sdate"
elif [ $edate_cert -lt $today ]
then
echo "CRITICAL WARNING: the replacement SSL certificate is EXPIRED. It expired on $edate"
else
echo "Good: date for proposed certificate is valid"
fi
cert_mod=`openssl x509 -noout -modulus -in $new_server_crt | openssl md5`
key_mod=`openssl rsa -noout -modulus -in $new_server_key | openssl md5`
# req_mod=`openssl req -noout -modulus -in $new_server_csr | openssl md5` not necessary, but could be nice
if [ $cert_mod = $key_mod ]
then
echo "Good: the modulas of the new server certificate matches the key. Valid pair."
else
echo "CRITICAL ERROR: the replacement SSL certificate private key and certificate do not match. FAIL"
fi

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
	 if [[ -f $configured_server_key && -f $configured_server_crt && -f $configured_intermediate_crt ]]
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
	   if [[ ! -f $configured_server_key ]]
	   then
	     echo "File $configured_server_key does not exist, please fix line #3 of this script"
	   fi
	   if [[ ! -f $configured_server_crt ]]
	   then
	     echo "File $configured_server_crt does not exist, please fix line #4 of this script"
	   fi
	   if [[ ! -f $configured_intermediate_crt ]]
	   then
	     echo "File $configured_intermediate_crt does not exist, please fix line #5 of this script"
	   fi
	   #exit 1;;
	fi
      else
        echo "ERROR: Configured replacement certs in script do not exist"
	if [[ ! -f $new_server_key ]]
           then
             echo "File $new_server_key does not exist, please fix line #6 of this script"
         fi
         if [[ ! -f $new_server_crt ]]
         then
           echo "File $new_server_crt does not exist, please fix line #7 of this script"
         fi
         if [[ ! -f $new_intermediate_crt ]]
         then
           echo "File $new_intermediate_crt does not exist, please fix line #8 of this script"
         fi

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
