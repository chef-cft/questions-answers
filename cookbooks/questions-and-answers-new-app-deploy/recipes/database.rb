# Installation directory gate
unless Dir.exist? 'c:/Program Files/Microsoft SQL Server'
  include_recipe 'sql_server::server'
end

execute "create #{node['database']['name']} database" do
  command "sqlcmd -Q \"CREATE DATABASE #{node['database']['name']}\""
  action :run
end
