# 
# automates the creation of a git repository on github.
require 'rubygems'
require 'mechanize'
 
# load all files
Dir["#{File.join(File.dirname(__FILE__), "mechanical_github")}/*.rb"].each { |file| require(file) }