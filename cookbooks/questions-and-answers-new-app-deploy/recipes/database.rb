# Installation directory gate
unless Dir.exist? 'c:/Program Files/Microsoft SQL Server'
  include_recipe 'sql_server::server'
end

execute "create #{node['database']['name']} database" do
  command "sqlcmd -Q \"CREATE DATABASE #{node['database']['name']}\""
  action :run
end

cookbook_file 'C:/inetpub/wwwroot/qanda/bin/migrate.exe' do
  source 'migrate.exe'
  action :create
end

execute "migrate database" do
  command "migrate.exe ModuleZeroSampleProject.EntityFramework.dll /connectionString=\"Server=localhost; Database=ModuleZeroSampleProject;Integrated Security=true\"  /connectionProviderName=\"System.Data.SqlClient\""
  cwd "C:/inetpub/wwwroot/qanda/bin"
  action :run
end