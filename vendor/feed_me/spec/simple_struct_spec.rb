require File.join( File.dirname(__FILE__), "spec_helper" )

require 'feed_me'

describe FeedMe::SimpleStruct do
    
  it "should append methods" do
    struct = FeedMe::SimpleStruct.new(:foo => "blah", :bar => 23)
    
    struct.foo.should == "blah"
    struct.bar.should == 23
  end
  
end