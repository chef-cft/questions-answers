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

# Grap app archive from S3
remote_file 'c:/qanda.zip' do
  source 'https://s3-eu-west-1.amazonaws.com/emea-techcft/ModuleZeroSampleProject.Web.zip'
  action :create_if_missing
end

# Installation directory gate
unless Dir.exist? 'c:/Program Files/Microsoft SQL Server'
  include_recipe 'sql_server::server'
end
