#
# Cookbook Name:: apache2
# Attributes:: apache
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

if node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 13.10
default['apache2']['version'] = '2.4'
elsif node['platform'] == 'debian' && node['platform_version'].to_f >= 8.0
default['apache2']['version'] = '2.4'
elsif node['platform'] == 'redhat' && node['platform_version'].to_f >= 7.0
default['apache2']['version'] = '2.4'
elsif node['platform'] == 'centos' && node['platform_version'].to_f >= 7.0
default['apache2']['version'] = '2.4'
elsif node['platform'] == 'fedora' && node['platform_version'].to_f >= 18
default['apache2']['version'] = '2.4'
elsif node['platform'] == 'opensuse' && node['platform_version'].to_f >= 13.1
default['apache2']['version'] = '2.4'
elsif node['platform'] == 'freebsd' && node['platform_version'].to_f >= 10.0
default['apache2']['version'] = '2.4'
else
default['apache2']['version'] = '2.2'
end

default['apache2']['root_group'] = 'root'

# Where the various parts of apache are
case node['platform']
when 'redhat', 'centos', 'scientific', 'fedora', 'suse', 'amazon', 'oracle'
  default['apache2']['package']     = 'httpd'
  default['apache2']['dir']         = '/etc/httpd'
  default['apache2']['log_dir']     = '/var/log/httpd'
  default['apache2']['error_log']   = 'error.log'
  default['apache2']['access_log']  = 'access.log'
  default['apache2']['user']        = 'apache'
  default['apache2']['group']       = 'apache'
  default['apache2']['binary']      = '/usr/sbin/httpd'
  default['apache2']['docroot_dir'] = '/var/www/html'
  default['apache2']['cgibin_dir']  = '/var/www/cgi-bin'
  default['apache2']['icondir']     = '/var/www/icons'
  default['apache2']['cache_dir']   = '/var/cache/httpd'
  default['apache2']['pid_file']    = if node['platform_version'].to_f >= 6
                                       '/var/run/httpd/httpd.pid'
                                     else
                                       '/var/run/httpd.pid'
                                     end
  default['apache2']['lib_dir']     = node['kernel']['machine'] =~ /^i[36]86$/ ? '/usr/lib/httpd' : '/usr/lib64/httpd'
  default['apache2']['libexecdir']  = "#{node['apache2']['lib_dir']}/modules"
  default['apache2']['default_site_enabled'] = false
  default['apache2']['lock_dir'] = '/var/run/httpd'
when 'debian', 'ubuntu'
  default['apache2']['package']     = 'apache2'
  default['apache2']['dir']         = '/etc/apache2'
  default['apache2']['log_dir']     = '/var/log/apache2'
  default['apache2']['error_log']   = 'error.log'
  default['apache2']['access_log']  = 'access.log'
  default['apache2']['user']        = 'www-data'
  default['apache2']['group']       = 'www-data'
  default['apache2']['binary']      = '/usr/sbin/apache2'
  default['apache2']['cgibin_dir']  = '/usr/lib/cgi-bin'
  default['apache2']['icondir']     = '/usr/share/apache2/icons'
  default['apache2']['cache_dir']   = '/var/cache/apache2'
  default['apache2']['lib_dir']     = '/usr/lib/apache2'
  default['apache2']['libexecdir']  = "#{node['apache2']['lib_dir']}/modules"
  default['apache2']['default_site_enabled'] = false
  default['apache2']['lock_dir'] = '/var/lock/apache2'
  if node['apache2']['version'] == '2.4'
    default['apache2']['pid_file'] = '/var/run/apache2/apache2.pid'
    default['apache2']['docroot_dir'] = '/var/www/html'
  else
    default['apache2']['pid_file'] = '/var/run/apache2.pid'
    default['apache2']['docroot_dir'] = '/var/www'
  end  
when 'arch'
  default['apache2']['package']     = 'apache2'
  default['apache2']['dir']         = '/etc/httpd'
  default['apache2']['log_dir']     = '/var/log/httpd'
  default['apache2']['error_log']   = 'error.log'
  default['apache2']['access_log']  = 'access.log'
  default['apache2']['user']        = 'http'
  default['apache2']['group']       = 'http'
  default['apache2']['binary']      = '/usr/sbin/httpd'
  default['apache2']['docroot_dir'] = '/srv/http'
  default['apache2']['cgibin_dir']  = '/usr/share/httpd/cgi-bin'
  default['apache2']['icondir']     = '/usr/share/httpd/icons'
  default['apache2']['cache_dir']   = '/var/cache/httpd'
  default['apache2']['pid_file']    = '/var/run/httpd/httpd.pid'
  default['apache2']['lib_dir']     = '/usr/lib/httpd'
  default['apache2']['libexecdir']  = "#{node['apache2']['lib_dir']}/modules"
  default['apache2']['default_site_enabled'] = false
  default['apache2']['lock_dir'] = '/var/run/httpd'  
when 'freebsd'
  if node['apache2']['version'] == '2.4'
    default['apache2']['package'] = 'apache24'
    default['apache2']['dir'] = '/usr/local/etc/apache24'
    default['apache2']['conf_dir'] = '/usr/local/etc/apache24'
    default['apache2']['docroot_dir'] = '/usr/local/www/apache24/data'
    default['apache2']['cgibin_dir'] = '/usr/local/www/apache24/cgi-bin'
    default['apache2']['icondir'] = '/usr/local/www/apache24/icons'
    default['apache2']['cache_dir'] = '/var/cache/apache24'
    default['apache2']['run_dir'] = '/var/run'
    default['apache2']['lock_dir'] = '/var/run'
    default['apache2']['lib_dir'] = '/usr/local/libexec/apache24'
  else
    default['apache2']['package'] = 'apache22'
	default['apache2']['dir'] = '/usr/local/etc/apache22'
	default['apache2']['conf_dir'] = '/usr/local/etc/apache22'
	default['apache2']['docroot_dir'] = '/usr/local/www/apache22/data'
	default['apache2']['cgibin_dir'] = '/usr/local/www/apache22/cgi-bin'
	default['apache2']['icondir'] = '/usr/local/www/apache22/icons'
	default['apache2']['cache_dir'] = '/var/cache/apache22'
	default['apache2']['run_dir'] = '/var/run'
	default['apache2']['lock_dir'] = '/var/run'
	default['apache2']['lib_dir'] = '/usr/local/libexec/apache22'
  end
	default['apache2']['perl_pkg'] = 'perl5'
	default['apache2']['apachectl'] = '/usr/local/sbin/apachectl'
	default['apache2']['pid_file'] = '/var/run/httpd.pid'
	default['apache2']['log_dir'] = '/var/log'
	default['apache2']['error_log'] = 'httpd-error.log'
	default['apache2']['access_log'] = 'httpd-access.log'
	default['apache2']['root_group'] = 'wheel'
	default['apache2']['user'] = 'www'
	default['apache2']['group'] = 'www'
	default['apache2']['binary'] = '/usr/local/sbin/httpd'
	default['apache2']['libexec_dir'] = node['apache2']['lib_dir']
else
  default['apache2']['dir']         = '/etc/apache2'
  default['apache2']['log_dir']     = '/var/log/apache2'
  default['apache2']['error_log']   = 'error.log'
  default['apache2']['access_log']  = 'access.log'
  default['apache2']['user']        = 'www-data'
  default['apache2']['group']       = 'www-data'
  default['apache2']['binary']      = '/usr/sbin/apache2'
  default['apache2']['docroot_dir'] = '/var/www'
  default['apache2']['cgibin_dir']  = '/usr/lib/cgi-bin'
  default['apache2']['icondir']     = '/usr/share/apache2/icons'
  default['apache2']['cache_dir']   = '/var/cache/apache2'
  default['apache2']['pid_file']    = 'logs/httpd.pid'
  default['apache2']['lib_dir']     = '/usr/lib/apache2'
  default['apache2']['libexecdir']  = "#{node['apache2']['lib_dir']}/modules"
  default['apache2']['default_site_enabled'] = false
  default['apache2']['lock_dir'] = 'logs'
end

###
# These settings need the unless, since we want them to be tunable,
# and we don't want to override the tunings.
###

# General settings
default['apache2']['listen_addresses']  = %w[*]
default['apache2']['listen_ports']      = %w[80]
default['apache2']['contact']           = 'ops@example.com'
default['apache2']['timeout']           = 300
default['apache2']['keepalive']         = 'On'
default['apache2']['keepaliverequests'] = 100
default['apache2']['keepalivetimeout']  = 5

# Security
default['apache2']['servertokens']    = 'Prod'
default['apache2']['serversignature'] = 'On'
default['apache2']['traceenable']     = 'On'

# mod_auth_openids
default['apache2']['allowed_openids'] = []

# mod_status Allow list, space seprated list of allowed entries.
default['apache2']['status_allow_list'] = 'localhost ip6-localhost'

# mod_status ExtendedStatus, set to 'true' to enable
default['apache2']['ext_status'] = false

# mod_info Allow list, space seprated list of allowed entries.
default['apache2']['info_allow_list'] = 'localhost ip6-localhost'

# Prefork Attributes
default['apache2']['prefork']['startservers']        = 16
default['apache2']['prefork']['minspareservers']     = 16
default['apache2']['prefork']['maxspareservers']     = 32
default['apache2']['prefork']['serverlimit']         = 400
default['apache2']['prefork']['maxclients']          = 400
default['apache2']['prefork']['maxrequestsperchild'] = 10_000

# Worker Attributes
default['apache2']['worker']['startservers']        = 4
default['apache2']['worker']['serverlimit']         = 16
default['apache2']['worker']['maxclients']          = 1024
default['apache2']['worker']['minsparethreads']     = 64
default['apache2']['worker']['maxsparethreads']     = 192
default['apache2']['worker']['threadsperchild']     = 64
default['apache2']['worker']['maxrequestsperchild'] = 0

# mod_proxy settings
default['apache2']['proxy']['order']      = 'deny,allow'
default['apache2']['proxy']['deny_from']  = 'all'
default['apache2']['proxy']['allow_from'] = 'none'

# Default modules to enable via include_recipe

default['apache2']['default_modules'] = %w[
  status alias auth_basic authn_file authz_groupfile authz_host authz_user autoindex
  dir env mime negotiation setenvif
]

if node['apache2']['version'] != '2.4'
	default['apache2']['default_modules'] << 'authz_default'
end

%w[log_config logio].each do |log_mod|
  default['apache2']['default_modules'] << log_mod if %w[rhel fedora suse arch freebsd].include?(node['platform_family'])
end
