#
# Cookbook:: install-apache-tomcat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

group 'atomcat'

user 'atomcat' do
  comment 'Apache Tomcat Administrator'
  group 'atomcat'
  home '/opt/atomcat'
  system true
  shell '/sbin/nologin'
end


