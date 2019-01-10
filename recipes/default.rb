#
# Cookbook Name:: apache2
# Recipe:: default
#
# Copyright 2015, Cloudenablers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when 'fedora'
  include_recipe 'yum-fedora::default'
end

package 'apache2' do
  package_name node['apache2']['package']
end

service 'apache2' do
  case node['platform_family']
  when 'rhel', 'fedora', 'suse'
    service_name 'httpd'
    # If restarted/reloaded too quickly httpd has a habit of failing.
    # This may happen with multiple recipes notifying apache to restart - like
    # during the initial bootstrap.
    restart_command '/sbin/service httpd restart && sleep 1'
    reload_command '/sbin/service httpd reload && sleep 1'
  when 'debian'
    service_name 'apache2'
    restart_command '/usr/sbin/invoke-rc.d apache2 restart && sleep 1'
    reload_command '/usr/sbin/invoke-rc.d apache2 reload && sleep 1'
  when 'arch'
    service_name 'httpd'
  when 'freebsd'
    service_name 'apache22'
  end
  supports [:restart, :reload, :status]
  action :enable
end

if platform_family?('rhel', 'fedora', 'arch', 'suse', 'freebsd')
  directory node['apache2']['log_dir'] do
    mode '0755'
  end

  package 'perl'

  cookbook_file '/usr/local/bin/apache2_module_conf_generate.pl' do
    source 'apache2_module_conf_generate.pl'
    mode   '0755'
    owner  'root'
    group  node['apache2']['root_group']
  end

  %w[sites-available sites-enabled mods-available mods-enabled].each do |dir|
    directory "#{node['apache2']['dir']}/#{dir}" do
      mode  '0755'
      owner 'root'
      group node['apache2']['root_group']
    end
  end

  execute 'generate-module-list' do
    command "/usr/local/bin/apache2_module_conf_generate.pl #{node['apache2']['lib_dir']} #{node['apache2']['dir']}/mods-available"
    action  :nothing
  end

  %w[a2ensite a2dissite a2enmod a2dismod].each do |modscript|
    template "/usr/sbin/#{modscript}" do
      source "#{modscript}.erb"
      mode  '0700'
      owner 'root'
      group node['apache2']['root_group']
    end
  end

  # installed by default on centos/rhel, remove in favour of mods-enabled
  %w[proxy_ajp auth_pam authz_ldap webalizer ssl welcome].each do |f|
    file "#{node['apache2']['dir']}/conf.d/#{f}.conf" do
      action :delete
      backup false
    end
  end

  # installed by default on centos/rhel, remove in favour of mods-enabled
  file "#{node['apache2']['dir']}/conf.d/README" do
    action :delete
    backup false
  end

  # enable mod_deflate for consistency across distributions
  include_recipe 'apache2::mod_deflate'
end

if platform_family?('freebsd')
  file "#{node['apache2']['dir']}/Includes/no-accf.conf" do
    action :delete
    backup false
  end

  directory "#{node['apache2']['dir']}/Includes" do
    action :delete
  end

  %w[
      httpd-autoindex.conf httpd-dav.conf httpd-default.conf httpd-info.conf
      httpd-languages.conf httpd-manual.conf httpd-mpm.conf
      httpd-multilang-errordoc.conf httpd-ssl.conf httpd-userdir.conf
      httpd-vhosts.conf
  ].each do |f|
    file "#{node['apache2']['dir']}/extra/#{f}" do
      action :delete
      backup false
    end
  end

  directory "#{node['apache2']['dir']}/extra" do
    action :delete
  end
end

%W[
  #{node['apache2']['dir']}/ssl
  #{node['apache2']['dir']}/conf.d
  #{node['apache2']['cache_dir']}
].each do |path|
  directory path do
    mode  '0755'
    owner 'root'
    group node['apache2']['root_group']
  end
end

# Set the preferred execution binary - prefork or worker
template '/etc/sysconfig/httpd' do
  source   'etc-sysconfig-httpd.erb'
  owner    'root'
  group    node['apache2']['root_group']
  mode     '0644'
  notifies :restart, 'service[apache2]'
  only_if  { platform_family?('rhel', 'fedora') }
end

template 'apache2.conf' do
  case node['platform_family']
  when 'rhel', 'fedora', 'arch'
    path "#{node['apache2']['dir']}/conf/httpd.conf"
  when 'debian'
    path "#{node['apache2']['dir']}/apache2.conf"
  when 'freebsd'
    path "#{node['apache2']['dir']}/httpd.conf"
  end
  source   'apache2.conf.erb'
  owner    'root'
  group    node['apache2']['root_group']
  mode     '0644'
  notifies :restart, 'service[apache2]'
end

if node['platform'] == "centos"
  template "#{node['apache2']['docroot_dir']}/index.html" do
    source "index.html.erb"
    owner    'root'
	group    node['apache2']['root_group']
	mode     '0644'
	notifies :restart, 'service[apache2]'
  end
end

template 'apache2-conf-security' do
  path     "#{node['apache2']['dir']}/conf.d/security.conf"
  source   'security.erb'
  owner    'root'
  group    node['apache2']['root_group']
  mode     '0644'
  backup   false
  notifies :restart, 'service[apache2]'
end

template 'apache2-conf-charset' do
  path      "#{node['apache2']['dir']}/conf.d/charset.conf"
  source   'charset.erb'
  owner    'root'
  group    node['apache2']['root_group']
  mode     '0644'
  backup   false
  notifies :restart, 'service[apache2]'
end

template "#{node['apache2']['dir']}/ports.conf" do
  source   'ports.conf.erb'
  owner    'root'
  group    node['apache2']['root_group']
  mode     '0644'
  notifies :restart, 'service[apache2]'
end

template "#{node['apache2']['dir']}/sites-available/default" do
  source   'default-site.erb'
  owner    'root'
  group    node['apache2']['root_group']
  mode     '0644'
  notifies :restart, 'service[apache2]'
end

node['apache2']['default_modules'].each do |mod|
  module_recipe_name = mod =~ /^mod_/ ? mod : "mod_#{mod}"
  include_recipe "apache2::#{module_recipe_name}"
end

apache_site 'default' do
  enable node['apache2']['default_site_enabled']
end

#GCM-2363,GCM-2784 - Apache fail to start in CentOS 7.x and Fedora >= 18 due to missing mime.types
if ((node['platform'] == 'centos' || node['platform'] == 'redhat') && node['platform_version'].to_f >= 7.0) ||
  (node['platform'] == 'fedora' && node['platform_version'].to_f >=18.0)
  file "#{node['apache2']['dir'] }/conf/mime.types" do
    owner 'root'
    group 'root'
    mode 0755
    if File.exist?('/etc/mime.types') # To skip file existence check in compiling stage
      content ::File.open("/etc/mime.types").read
    end
    action :create
  end
end

if ((node['platform'] == 'centos' || node['platform'] == 'redhat') && node['platform_version'].to_f >= 7.0) || (node['platform'] == 'fedora' && node['platform_version'].to_f >= 18)
  bash "Configure iptables" do
    code <<-EOH
    systemctl mask firewalld
    systemctl stop firewalld
    yum -y install iptables-services
    systemctl enable iptables
    systemctl start iptables 
    EOH
  end
end

if node['platform'] == 'centos' || node['platform'] == 'redhat' || node['platform'] == 'fedora'
  node['apache2']['listen_ports'].each do |port|
    execute "Enable http port in iptables" do
	  command "iptables -I INPUT 1 -p tcp --dport #{port} -j ACCEPT"
    end
  end
  bash "Save and Restart iptables" do
    code <<-EOH
    service iptables save
    service iptables restart
    EOH
  end
end


service 'apache2' do
  action :start
end
