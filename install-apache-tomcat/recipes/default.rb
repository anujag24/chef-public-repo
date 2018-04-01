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


