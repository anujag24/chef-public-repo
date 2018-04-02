#
# Cookbook:: install-apache-tomcat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

# Install OpenJDK 7 JDK using yum
yum_package 'Install Open JDK7' do
  package_name 'java-1.7.0-openjdk-devel' 
end 

group 'tomcat'

# Create UNIX user tomcat and set required attributes
user 'tomcat' do
  comment 'Apache Tomcat Administrator'
  group 'tomcat'
  home '/opt/tomcat'
  system true
  shell '/sbin/nologin'
end

# Download the Tomcat Binary
bash 'download tomcat 8.5.29' do
  user 'tomcat'
  cwd '/tmp'
  code <<-EOH
  wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.29/bin/apache-tomcat-8.5.29.tar.gz
  EOH
end

# Create the directory to extract tomcat binaries 
directory '/opt/tomcat' do
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
  action :create
end

# Extract the Tomcat Binary
bash 'extract tomcat 8.5.29' do
  user 'tomcat'
  cwd '/tmp'
  code <<-EOH
  tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
  EOH
  only_if { File.exist?('/tmp/apache-tomcat-8.5.29.tar.gz') }
end

# Update the Permissions
execute 'change directory group permission' do
 command "chgrp -R tomcat /opt/tomcat"
end

execute 'change directory read permission' do
 command 'chmod -R g+r conf'
 cwd  '/opt/tomcat'
end

dir_list = ['/opt/tomcat/webapps','/opt/tomcat/work','/opt/tomcat/temp','/opt/tomcat/logs']

dir_list.each do |dir|
  execute 'change directory permission' do
  command "chown -R tomcat:tomcat #{dir}"
  end
end

# Create the directory if not already present
directory '/etc/systemd/system' do
  owner 'root'
  group 'root'
  recursive true
  not_if { File.exist?('/etc/systemd/system') }
end

# Create tomcat system unit file
template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
  tomcat_home: '/opt/tomcat',
  tomcat_user: 'tomcat',
  tomcat_grp: 'tomcat',
  catalina_opts: '-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
  )
  only_if { File.exist?('/etc/systemd/system') }
end

# Reload Systemd to load the Tomcat Unit file
execute 'Reload Systemd to load the Tomcat Unit file' do
 command 'systemctl daemon-reload'
end

# Ensure tomcat is started and enabled
bash 'Ensure tomcat is started and enabled' do
  code <<-EOH
  systemctl start tomcat
  systemctl enable tomcat
  EOH
  only_if { File.exist?('/etc/systemd/system/tomcat.service') }
end

