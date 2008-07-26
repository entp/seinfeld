$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'ruby-debug'

module Fixtures
  
  def fixture_path
    File.join(File.dirname(__FILE__), 'fixtures')
  end
  
  def fixture(name)
    File.join(fixture_path, name)
  end
  
  def hpricot_fixture(name)
    Hpricot.XML(open(fixture(name)).read)
  end
  
end

Spec::Runner.configure do |config|
  config.include(Fixtures)
end
