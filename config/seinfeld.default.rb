SINATRA_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

DataMapper.setup(:default, "sqlite3://#{SINATRA_ROOT}/development.sqlite3")

Seinfeld::User.github_login    = ''
Seinfeld::User.github_password = ''
Seinfeld::User.creation_token  = ''