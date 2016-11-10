#
# Cookbook Name:: build_cookbook
# Recipe:: publish
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe "delivery-truck::publish"

# Remove existing war file, the mvn package command should recreate it
directory 'c:/Users/chef/deploy/' do
  action :delete
end

log "Building artifact"

# Build Package
execute 'running msbuild' do
  command 'C:/Windows/Microsoft.NET/Framework64/v4.0.30319/MSBuild.exe ./ModuleZeroSampleProject.sln /p:VisualStudioVersion=14.0 /p:PublishProfile=Release /p:DeployOnBuild=true'
  cwd "C:/delivery/ws/aut-workflow-server/Automate/automate-org/questions-and-answers/master/build/publish/repo/src"
  action :run
end

software_version = Time.now.strftime('%F_%H%M')

windows_zipfile "c:/Users/chef/deploy/QandA-#{software_version}.zip" do
  source "c:/Users/chef/deploy"
  action :zip
end

# Upload Package to S3
require 'rubygems'
#require 'aws-sdk'
require 'aws/s3'

bucket_name = node['build-cookbook']['s3']['bucket_name']
file_name = "c:/Users/chef/deploy/QandA-#{software_version}.zip"
key = File.basename(file_name)

log "Uploading artifact to S3"

with_server_config do
  # Reading AWS creds from encrypted data bag

 ruby_block 'upload zip to S3' do
  block do
    s3 = AWS::S3.new
    s3.buckets[bucket_name].objects[key].write(:file => file_name)
   end
 end
end
ruby_block 'upload data bag' do
  block do
    with_server_config do
      dbag = Chef::DataBag.new
      dbag.name(node['delivery']['change']['project'])
      dbag.save
      dbag_data = {
        'id' => "app_details",
        'version' => software_version,
        'artifact_location' => "https://s3-eu-west-1.amazonaws.com/emea-techcft/deploy",
        'artifact_type' => 'http',
        'delivery_data' => node['delivery']
      }
      dbag_item = Chef::DataBagItem.new
      dbag_item.data_bag(dbag.name)
      dbag_item.raw_data = dbag_data
      dbag_item.save
    end
  end
end

ruby_block 'set the version in the env' do
  block do
    with_server_config do
      begin
        to_env = Chef::Environment.load(get_acceptance_environment)
      rescue Net::HTTPServerException => http_e
        raise http_e unless http_e.response.code == "404"
        Chef::Log.info("Creating Environment #{get_acceptance_environment}")
        to_env = Chef::Environment.new()
        to_env.name(get_acceptance_environment)
        to_env.create
      end

      to_env.override_attributes['applications'] ||= {}
      to_env.override_attributes['applications'][node['delivery']['change']['project']] = software_version
      to_env.save
      ::Chef::Log.info("Set #{node['delivery']['change']['project']}'s version to #{software_version} in #{node['delivery']['change']['project']}.")
    end
  end
end