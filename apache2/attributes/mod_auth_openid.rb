#
# Cookbook Name:: apache22
# Attributes:: mod_auth_cas
#
# Copyright 2015, Cloudenablers
#
# Licensed under the apache2 License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache2.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['apache2']['mod_auth_openid']['ref']        = '95043901eab868400937642d9bc55d17e9dd069f'
default['apache2']['mod_auth_openid']['source_url'] = "https://github.com/bmuller/mod_auth_openid/archive/#{node['apache2']['mod_auth_openid']['ref']}.tar.gz"
default['apache2']['mod_auth_openid']['cache_dir']  = '/var/cache/mod_auth_openid'
default['apache2']['mod_auth_openid']['dblocation'] = "#{node['apache2']['mod_auth_openid']['cache_dir']}/mod_auth_openid.db"

case node['platform_family']
when 'freebsd'
  default['apache2']['mod_auth_openid']['configure_flags'] = [
    'CPPFLAGS=-I/usr/local/include',
    'LDFLAGS=-I/usr/local/lib -lsqlite3'
  ]
else
  default['apache2']['mod_auth_openid']['configure_flags'] = []
end
