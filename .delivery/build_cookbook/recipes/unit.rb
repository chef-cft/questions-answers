#
# Cookbook Name:: build_cookbook
# Recipe:: unit
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'delivery-truck::unit'

# Build and Debug Package
execute 'running msbuild debug' do
  command '"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe" ./ModuleZeroSampleProject.sln /p:VisualStudioVersion=14.0'
  cwd "#{node['delivery']['workspace']['repo']}/src"
  action :run
end

# Running unit tests
execute 'running vsconsole tests' do
  command '"C:/Program Files (x86)/Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe" .\Tests\ModuleZeroSampleProject.Tests\bin\Debug\ModuleZeroSampleProject.Tests.dll /TestAdapterPath:"."'
  cwd "#{node['delivery']['workspace']['repo']}/src"
  action :run
end
