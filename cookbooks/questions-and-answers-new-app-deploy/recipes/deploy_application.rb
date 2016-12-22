directory node['application']['web_root'] do
  recursive true
  action :create
end

iis_site 'Chef Site' do
  protocol :http
  port 80
  path node['site']['web_root']
  action [:add, :start]
end

# Create the application on IIS
#iis_app 'QandA' do
#  site_name 'Chef Site'
#  path '/'
#  physical_path node['application']['web_root']
#  enabled_protocols 'http'
#  action :add
#end

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

# add a virtual directory to an application under a site
iis_vdir 'Chef Site/' do
  action :add
  path '/'
  physical_path node['application']['web_root']
end