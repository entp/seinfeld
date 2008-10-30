require File.dirname(__FILE__) + "/../myapp.rb"
 
disable :run, :reload
set     :env, :production
 
run Sinatra.application
