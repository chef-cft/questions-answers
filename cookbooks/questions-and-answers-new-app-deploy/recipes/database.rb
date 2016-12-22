# Installation directory gate
unless Dir.exist? 'c:/Program Files/Microsoft SQL Server'
  include_recipe 'sql_server::server'
end

cookbook_file "#{node['site']['web_root']}/bin/migrate.exe" do
  source 'migrate.exe'
  action :create
end

execute "migrate database" do
  command "migrate.exe ModuleZeroSampleProject.EntityFramework.dll /connectionString=\"Server=localhost; Database=ModuleZeroSampleProject;Integrated Security=true\"  /connectionProviderName=\"System.Data.SqlClient\""
  cwd node['site']['web_root']  + "/bin"
  action :run
end