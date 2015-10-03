#
# Cookbook Name:: eboss
# Recipe:: jboss_standalone_getsources
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#defining variables for less typing
jboss_base = node['eboss']['jboss_base']
jboss_user = node['eboss']['jboss_user']
jboss_ext = node['eboss']['package_ext']
jboss_pkg = "jboss.zip"

#get name of package for folder variable
homedir_name = node['eboss']['download_link'].
        split('/')[-1].
        sub!("#{jboss_ext}","")

#create default jboss user
user jboss_user do
        action :create
        home "#{jboss_base}/#{homedir_name}"
        shell "/bin/bash"
        supports :manage_home => true
end

#unpack jboss
remote_file "#{jboss_base}/#{jboss_pkg}" do
  owner "root"
  group "root"
  mode "0644"
  source node['eboss']['download_link']
  notifies :run, "execute[unpack]", :immediately
end

execute "unpack" do
        cwd node['eboss']['jboss_base']
        command "unzip -o #{jboss_base}/#{jboss_pkg} -d #{jboss_base}/"
        action :nothing
	notifies :run, "execute[fixrights]", :immediately
end

#unpack example
remote_file "#{jboss_base}/example.zip" do
  owner "root"
  group "root"
  mode "0644"
  source node['eboss']['sample_link']
  notifies :run, "execute[unpack_example]", :immediately
end

execute "unpack_example" do
        cwd node['eboss']['jboss_base']
        command "unzip -o #{jboss_base}/example.zip -d #{jboss_base}/#{homedir_name}/standalone/deployments"
	action :nothing
	notifies :run, "execute[fixrights]", :immediately
end

execute "fixrights" do
	command "chown #{jboss_user}. #{jboss_base}/#{homedir_name} -R"
	action :nothing
end

#adding run-script for jboss
template "/etc/init.d/jboss" do
  source "jboss-as-standalone.sh.erb"
  mode 0775
  owner "root"
  group "root"
end

directory '/etc/jboss-as' do
 action :create
 owner "root"
 group "root"
 mode "0644"
end

template "/etc/jboss-as/jboss-as.conf" do
 source "jboss-as.conf.erb"
 owner "root"
 group "root"
 mode "0644"
 variables({
      :jboss_home  => "#{jboss_base}/#{homedir_name}",
      :jboss_log  => '/var/log/jboss.log',
      :jboss_user  => jboss_user
      })
  notifies :enable, "service[jboss]", :delayed
  notifies :start, "service[jboss]", :delayed
end

#allowing any ip to connect
template "#{jboss_base}/#{homedir_name}/standalone/configuration/standalone.xml" do
        source "standalone.xml.erb"
        owner jboss_user
        group jboss_user
        mode "0644"
end

#adding testuser for mgmt
template "#{jboss_base}/#{homedir_name}/standalone/configuration/mgmt-users.properties" do
        source "mgmt-users.properties.erb"
        owner jboss_user
        group jboss_user
        mode "0644"
end

#adding testuser for mgmt
template "#{jboss_base}/#{homedir_name}/domain/configuration/mgmt-users.properties" do
        source "mgmt-users.properties.erb"
        owner jboss_user
        group jboss_user
        mode "0644"
	notifies :restart, "service[jboss]", :delayed	
end

service 'jboss' do
  provider Chef::Provider::Service::Init::Redhat
  start_command "nohup /etc/init.d/jboss start >/dev/null 2>&1 &"
  stop_command "/etc/init.d/jboss stop >/dev/null 2>&1 &"  
  restart_command "/etc/init.d/jboss stop; sleep 10; nohup /etc/init.d/jboss start >/dev/null 2>&1 &"
action [ :nothing ]
end
