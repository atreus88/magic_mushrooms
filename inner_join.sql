select hostname 
from servers s 
left join nagiosHosts on s.id=nagiosHosts.servers_id 
left join nagiosHosts_to_hostgroups on nagiosHosts.id=nagiosHosts_to_hostgroups.host_id
where nagiosHosts.monitor='YES' and servers.colo='sea' and nagiosHosts_to_hostgroups.host_id<>67;
