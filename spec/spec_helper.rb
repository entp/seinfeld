$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'seinfeld/models'
require 'ruby-debug'
require 'ostruct'
require 'spec'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

Debugger.start