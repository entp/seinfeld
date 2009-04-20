require File.dirname(__FILE__) + "/../seinfeld_calendar.rb"

set :run, false
set :env, ENV['APP_ENV'] || :production

run Sinatra::Application
