#
# Cookbook Name:: build_cookbook
# Recipe:: syntax
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'delivery-truck::syntax'

# Build and Debug Package
execute 'running msbuild debug' do
  command '"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe" ./ModuleZeroSampleProject.sln /p:VisualStudioVersion=14.0'
  cwd "#{node['delivery']['workspace']['repo']}/src"
  action :run
end