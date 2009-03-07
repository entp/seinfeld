DataMapper.setup(:default, ENV['DATABASE_URL'])
DataMapper.auto_migrate!

Seinfeld::User.github_login    = 'calendaraboutnothing'
Seinfeld::User.github_password = 'xeE9LofzghzJT7bQ'
Seinfeld::User.creation_token  = 'fXvefRp8g3QVmCkT'