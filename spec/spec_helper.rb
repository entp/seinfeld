$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'seinfeld_calendar'
require 'ruby-debug'
require 'ostruct'
require 'spec'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

Debugger.start