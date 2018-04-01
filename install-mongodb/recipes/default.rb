#
# Cookbook:: install-mongodb
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

group 'mongodbgrp'

user 'mongodbadm' do
  group 'mongodbgrp'
  system true
  shell '/bin/bash'
end

yum_repository 'mongodb' do
  description 'MongoDB Repository'
  baseurl 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/'
  gpgcheck false
  enabled true
  action :create
end

#file '/etc/yum.repos.d/mongodb.repo' do
#  content '
#[mongodb-org]
#name=MongoDB Repository
#baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
#gpgcheck=0
#enabled=1'
#  mode '0755'
#  owner 'mongodbadm'
#  group 'mongodbgrp'
#end

package 'Install MongoDB' do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'mongodb-org'
  end
end

service 'mongod' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

bash 'start mongodb service on server restart' do
  code <<-EOH
  sudo chkconfig mongod on
  EOH
end
