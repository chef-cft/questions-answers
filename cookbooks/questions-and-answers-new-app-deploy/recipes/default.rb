#
# Cookbook Name:: questions-and-answers-new-app-deploy
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Enable IIS Features
windows_feature 'IIS-WebServerRole' do
  action :install
  all true
end

windows_feature 'IIS-ASPNET45' do
  action :install
  all true
end

windows_package "Install webdeploy" do
    source 'http://download.microsoft.com/download/D/4/4/D446D154-2232-49A1-9D64-F5A9429913A4/WebDeploy_amd64_en-US.msi'
    installer_type :msi
    action :install
end

# Stop and delete the default site
iis_site 'Default Web Site' do
  action [:stop, :delete]
end

directory node['application']['web_root'] do
  recursive true
  action :create
end

iis_pool 'DefaultAppPool' do
  action :config
  pool_identity :LocalSystem
end

iis_site 'Chef Site' do
  protocol :http
  port 80
  path node['application']['web_root']
  action [:add, :start]
end

include_recipe 'questions-and-answers-new-app-deploy::database'

# Create the application on IIS
iis_app 'QandA' do
  site_name 'Chef Site'
  path '/QandA'
  physical_path "${node['application']['web_root']}/QandA"
  enabled_protocols 'http'
  action :add
end

app_data = data_bag_item('questions-and-answers', 'app_details')

directory node['application']['staging_dir'] do
  action :delete
  recursive true
end

windows_zipfile node['application']['staging_dir'] do
  source app_data['artifact_location']
  action :unzip
end

# Build Package
execute 'deploying app' do
  command 'QandA.deploy.cmd /Y'
  cwd node['application']['staging_dir']
  action :run
end
