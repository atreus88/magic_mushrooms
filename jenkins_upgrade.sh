/etc/init.d/tomcat7 stop
sleep 30
ps -ef | grep tomcat | grep -v grep | awk {'print $2'} | xargs kill -9 $1
yum clean metadata
yum -y upgrade jmagick
mkdir -p /srv/zia_photo/releases/0.1.54
rm /srv/zia_photo/current
cd /tmp
wget http://build1qa.sfo2.zoosk.com:8081/nexus/service/local/repositories/releases/content/com/zoosk/service/photo/0.1.54/photo-0.1.54.war
mv photo-0.1.54.war /srv/zia_photo/releases/0.1.54/zia_photo.war
ln -s /srv/zia_photo/releases/0.1.54 /srv/zia_photo/current
chown -Rf release:release /srv/zia_photo
/etc/init.d/tomcat7 start
