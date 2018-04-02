#
# Cookbook:: install-mongodb
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

# Creating UNIX group

group 'mongodbgrp'

user 'mongodbadm' do
  group 'mongodbgrp'
  system true
  shell '/bin/bash'
end

# Creating Mongo DB Repository
yum_repository 'mongodb' do
  description 'MongoDB Repository'
  baseurl 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/'
  gpgcheck false
  enabled true
  action :create
end

# Installing MongoDB using yum install
package 'Install MongoDB' do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'mongodb-org'
  end
end

# Starting Mongo DB as a service
service 'mongod' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# ensure that MongoDB will start following a system reboot
bash 'start mongodb service on server restart' do
  code <<-EOH
  sudo chkconfig mongod on
  EOH
end
