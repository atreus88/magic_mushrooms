sed -i '/ \/tmp/s/,noexec//' /etc/fstab

cat << EOF -> /etc/yum.repos.d/cloudera-manager.repo
[cloudera-manager]
name = Cloudera Manager, Version 4.8.1
baseurl = http://archive.cloudera.com/cm4/redhat/6/x86_64/cm/4.8.1/
gpgkey = http://archive.cloudera.com/redhat/cdh/RPM-GPG-KEY-cloudera
gpgcheck = 1
EOF
