# Installation directory gate
unless Dir.exist? 'c:/Program Files/Microsoft SQL Server'
  include_recipe 'sql_server::server'
end

# Create a sql server database
sql_server_database 'ModuleZeroSampleProject' do
  connection(
    :host     => 'localhost',
    :port     => node['sql_server']['port'],
    :username => 'sa',
    :password => node['sql_server']['server_sa_password'],
    :options  => { 'ANSI_NULLS' => 'ON', 'QUOTED_IDENTIFIER' => 'OFF' }
  )
  action :create
end