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

directory 'c:\inetpub\wwwroot\qanda' do
  recursive true
  action :create
end

iis_site 'Chef Site' do
  protocol :http
  port 80
  path 'c:/inetpub/wwwroot/qanda'
  action [:add, :start]
end

# Create the application on IIS
iis_app 'QandA' do
  site_name 'Chef Site'
  path '/QandA'
  physical_path 'c:/inetpub/wwwroot/qanda'
  enabled_protocols 'http'
  action :add
end

app_data = data_bag_item('questions-and-answers', 'app_details')

windows_zipfile 'c:/Users/chef/QandA/' do
  source app_data['artifact_location']
  action :unzip
end

# Installation directory gate
unless Dir.exist? 'c:/Program Files/Microsoft SQL Server'
  include_recipe 'sql_server::server'
end
