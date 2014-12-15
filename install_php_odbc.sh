#!/bin/bash
if [[ $# = 0 ]]
then
  echo "ERROR: First argument must be remote host"
else
ssh root@${1} "mkdir ~/odbc"
for i in `echo "odbcinst.ini odbc.ini cloudera.impalaodbc.ini ClouderaImpalaODBC-2.5.17.1017-1.el6.x86_64.rpm"`
do
  scp $i root@${1}:~/odbc/
done
ssh root@${1} "yum -y install php-odbc && yum -y --nogpgcheck localinstall /root/odbc/ClouderaImpalaODBC-2.5.17.1017-1.el6.x86_64.rpm && cp /root/odbc/*.ini /etc && odbcinst -i -d -f /etc/odbcinst.ini && odbcinst -i -s -l -f /etc/odbc.ini"
fi
