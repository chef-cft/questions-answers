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

iis_site 'Default Web Site' do
  action [:stop, :delete]
end

iis_pool 'DefaultAppPool' do
  action :config
  pool_identity :LocalSystem
end

