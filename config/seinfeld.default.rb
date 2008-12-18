DataMapper.setup(:default, 'mysql://localhost/seinfeld')

Seinfeld::User.github_login    = ''
Seinfeld::User.github_password = ''
Seinfeld::User.creation_token  = ''