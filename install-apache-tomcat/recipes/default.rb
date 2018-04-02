#
# Cookbook:: install-apache-tomcat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

yum_package 'Install Open JDK7' do
  package_name 'java-1.7.0-openjdk-devel' 
end 

group 'atomcat'

user 'atomcat' do
  comment 'Apache Tomcat Administrator'
  group 'atomcat'
  home '/opt/atomcat'
  system true
  shell '/sbin/nologin'
end

bash 'download tomcat 8.5.29' do
  user 'atomcat'
  cwd '/tmp'
  code <<-EOH
  wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.29/bin/apache-tomcat-8.5.29.tar.gz
  EOH
end

directory '/opt/atomcat' do
  owner 'atomcat'
  group 'atomcat'
  mode '0755'
  action :create
end

bash 'extract tomcat 8.5.29' do
  user 'atomcat'
  cwd '/tmp'
  code <<-EOH
  tar xvf apache-tomcat-8*tar.gz -C /opt/atomcat --strip-components=1
  EOH
  only_if { File.exist?('/tmp/apache-tomcat-8.5.29.tar.gz') }
end

execute 'change directory group permission' do
 command "chgrp -R atomcat /opt/atomcat"
end

execute 'change directory read permission' do
 command 'chmod -R g+r conf'
 cwd  '/opt/atomcat'
end

dir_list = ['/opt/atomcat/webapps','/opt/atomcat/work','/opt/atomcat/temp','/opt/atomcat/logs']

dir_list.each do |dir|
  execute 'change directory permission' do
  command "chown -R atomcat:atomcat #{dir}"
  end
end

directory '/etc/systemd/system' do
  owner 'root'
  group 'root'
  recursive true
  not_if { File.exist?('/etc/systemd/system') }
end


template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
  tomcat_home: '/opt/atomcat',
  tomcat_user: 'atomcat',
  tomcat_grp: 'atomcat',
  catalina_opts: '-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
  )
  only_if { File.exist?('/etc/systemd/system') }
end

execute 'Reload Systemd to load the Tomcat Unit file' do
 command 'systemctl daemon-reload'
end


yum_package 'Install Systemd' do
  package_name 'systemd'
end

bash 'Ensure tomcat is started and enabled' do
  code <<-EOH
  systemctl start tomcat
  systemctl enable tomcat
  EOH
  only_if { File.exist?('/etc/systemd/system/tomcat.service') }
end




