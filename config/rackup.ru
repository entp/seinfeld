$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'seinfeld/models'
DataMapper.setup :default, "#{ENV["ADAPTER"]}://#{ENV["USER"]}:#{ENV["PASSWORD"]}@#{ENV["HOST"]}/#{ENV["DATABASE"]}"
Seinfeld::User.github_login    = 'calendaraboutnothing'
Seinfeld::User.github_password = 'zwol8wak3r'
Seinfeld::User.creation_token  = 'ba2da61bf433cc0d5b036d7739dd35f8acca6e34'

require File.dirname(__FILE__) + "/../app/seinfeld_calendar.rb"
 
disable :run, :reload
set     :env, :production

run Sinatra.application
