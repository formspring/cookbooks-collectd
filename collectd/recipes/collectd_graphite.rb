#
# Cookbook Name:: collectd
# Definition:: collectd_plugin
#
# Copyright 2011, Formspring.me
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

include_recipe "collectd::server"

version = node[:collectd][:graphite][:version]

remote_file "/usr/src/Collectd-Plugins-Graphite-#{version}.tar.gz" do
  source 'https://github.com/downloads/joemiller/collectd-graphite/Collectd-Plugins-Graphite-#{version}.tar.gz'
end

src_path = "/usr/src/Collectd-Plugins-Graphite-#{version}/"

execute "untar collectd graphite" do
  command "tar xzf Collectd-Plugins-Graphite-#{version}.tar.gz"
  creates src_path
  cwd "/usr/src"
end

execute "configure collectd graphite build" do
  command "perl Makefile.PL"
  creates "#{src_path}/Makefile"
  cwd src_path
end

execute "build collectd graphite" do
  command "make"
  creates "#{src_path}/pm_to_blib"
  cwd src_path
end

execute "install collectd graphite" do
  command "make install"
  creates "#{node[:collectd][:perl_include_dir]}/Collectd/Plugins/Graphite.pm"
  cwd src_path
end

collectd_perl_plugin 'Graphite' do
  options :buffer => "256000", :prefix => "collectd", :host => "localhost", :port => "2003"
end
