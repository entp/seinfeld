require File.join( File.dirname(__FILE__), "spec_helper" )

require 'feed_me'

describe "all parsing methods", :shared => true do
  it "should identify an atom feed" do
    @atom.should be_an_instance_of(FeedMe::AtomFeedParser)
    @atom.format.should == :atom
    @atom.root_node.xpath == "//feed[@xmlns='http://www.w3.org/2005/Atom']"
  end
  
  it "should identify an rss2 feed" do
    @rss2.should be_an_instance_of(FeedMe::Rss2FeedParser)
    @rss2.format.should == :rss2
    @rss2.root_node.xpath == "//rss[@version=2.0]/channel"
  end
end

describe FeedMe::FeedParser do

  before :each do
    @atom_feed = hpricot_fixture('welformed.atom') / "//feed[@xmlns='http://www.w3.org/2005/Atom']"
    @atom = FeedMe::FeedParser.build(@atom_feed, :atom)
    @rss2_feed = hpricot_fixture('welformed.rss2') / "//rss[@version=2.0]/channel"
    @rss2 = FeedMe::FeedParser.build(@rss2_feed, :rss2)
  end

  it "should be an atom parser for an atom feed" do
    @atom.should be_an_instance_of(FeedMe::AtomFeedParser)
  end

  describe ".parse" do
    before(:each) do
      @atom = FeedMe::FeedParser.parse(open(fixture('welformed.atom')).read)
      @rss2 = FeedMe::FeedParser.parse(open(fixture('welformed.rss2')).read)
    end
    
    it_should_behave_like "all parsing methods"
  end
  
  describe ".open" do
    before(:each) do
      @atom = FeedMe::FeedParser.open(fixture('welformed.atom'))
      @rss2 = FeedMe::FeedParser.open(fixture('welformed.rss2'))
    end
    
    it_should_behave_like "all parsing methods"
  end
    
  describe '#title' do
    it "should be valid for an atom feed" do
      @atom.title.should == "Test feed"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.title.should == "Lift Off News"
    end
  end
  
  describe '#description' do
    it "should be valid for an atom feed" do
      @atom.description.should == "Monkey test feed"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.description.should == "Liftoff to Space Exploration."
    end
  end
  
  describe '#feed_id' do
    it "should be valid for an atom feed" do
      @atom.feed_id.should == "tag:imaginary.host:nyheter"
    end
    
    it "should be nil for an rss2 feed" do
      @rss2.feed_id.should be_nil
    end
  end
  
  describe '#updated_at' do
    it "should be valid for an atom feed" do
      @atom.updated_at.should == Date.civil(2008, 3, 7, 20, 41, 10)
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.updated_at.should == Date.civil(2003, 6, 10, 9, 41, 1)
    end
  end
  
  describe '#href' do
    it "should be valid for an atom feed" do
      @atom.href.should == "http://imaginary.host/posts.atom"
    end
    
    it "should be nil for an atom feed" do
      @rss2.href.should be_nil
    end
  end
  
  describe '#url' do
    it "should be valid for an atom feed" do
      @atom.url.should == "http://imaginary.host/posts"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.url.should == "http://liftoff.msfc.nasa.gov/"
    end
  end
  
  describe '#generator' do
    it "should be valid for an atom feed" do
      @atom.generator.should == "Roll your own"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.generator.should == "Weblog Editor 2.0"
    end
  end
  
  describe '#format' do
    it "should be :atom for an atom feed" do
      @atom.format.should == :atom
    end
    
    it "should be :rss2 for an rss2 feed" do
      @rss2.format.should == :rss2
    end
  end
  
  describe '#author.name' do
    it "should be valid for an atom feed" do
      @atom.author.name.should == "Frank"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.author.name.should == "Mary Jo"
    end
  end
  
  describe '#author.email' do
    it "should be valid for an atom feed" do
      @atom.author.email.should == "frank@imaginary.host"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.author.email.should == "editor@example.com"
    end
  end
  
  describe '#author.uri' do
    it "should be valid for an atom feed" do
      @atom.author.uri.should == "http://imaginary.host/students/frank"
    end
    
    it "should be nil for an rss2 feed" do
      @rss2.author.uri.should be_nil
    end
  end
  
  describe '#entries' do
    it "should return an array of entries for an atom feed" do
      @atom.entries.should be_an_instance_of(Array)
    end
    
    it "should have the correct length for an atom feed" do
      @atom.should have(3).entries
    end
    
    it "should return items that are properly parsed for an atom feed" do
      @atom.entries.first.title.should == "First title"
      @atom.entries.first.url.should == "http://imaginary.host/posts/3"
    end
    
    it "should return an array of entries for an rss2 feed" do
      @rss2.entries.should be_an_instance_of(Array)
    end
    
    it "should have the correct length for an rss2 feed" do
      @rss2.should have(4).entries
    end
    
    it "should return items that are properly parsed for an rss2 feed" do
      @rss2.entries.first.title.should == "Star City"
      @rss2.entries.first.url.should == "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp"
    end
  end
  
  describe '#to_hash' do
    it "should serialize the title of an atom feed" do
      @atom.to_hash[:title].should == "Test feed"
    end
    
    it "should serialize the description of an atom feed" do
      @atom.to_hash[:description].should == "Monkey test feed"
    end
    
    it "should serialize the feed_id of an atom feed" do
      @atom.to_hash[:feed_id].should == "tag:imaginary.host:nyheter"
    end
    
    it "should serialize the updated_at time of an atom feed" do
      @atom.to_hash[:updated_at].should == Date.civil(2008, 3, 7, 20, 41, 10)
    end
    
    it "should serialize the href of an atom feed" do
      @atom.to_hash[:href].should == "http://imaginary.host/posts.atom"
    end
    
    it "should serialize the url of an atom feed" do
      @atom.to_hash[:url].should == "http://imaginary.host/posts"
    end
    
    it "should serialize the generator of an atom feed" do
      @atom.to_hash[:generator].should == "Roll your own"
    end
    
    it "should serialize the entries of an atom feed" do
      @atom.to_hash[:entries].should be_an_instance_of(Array)
      @atom.to_hash[:entries].first.title.should == "First title"
      @atom.to_hash[:entries].first.url.should == "http://imaginary.host/posts/3"
    end
    
    it "should serialize the author of an atom feed" do
      author = @atom.to_hash[:author]
      
      author.name.should == "Frank"
      author.email.should == "frank@imaginary.host"
      author.uri.should == "http://imaginary.host/students/frank"
    end
    
    it "should serialize the title of an rss2 feed" do
      @rss2.to_hash[:title].should == "Lift Off News"
    end
    
    it "should serialize the description of an rss2 feed" do
      @rss2.to_hash[:description].should == "Liftoff to Space Exploration."
    end
    
    it "should serialize the feed_id of an rss2 feed" do
      @rss2.to_hash[:feed_id].should be_nil
    end
    
    it "should serialize the updated_at time of an rss2 feed" do
      @rss2.to_hash[:updated_at].should == Date.civil(2003, 6, 10, 9, 41, 1)
    end
    
    it "should serialize the href of an rss2 feed" do
      @rss2.to_hash[:href].should be_nil
    end
    
    it "should serialize the url of an rss2 feed" do
      @rss2.to_hash[:url].should == "http://liftoff.msfc.nasa.gov/"
    end
    
    it "should serialize the generator of an rss2 feed" do
      @rss2.to_hash[:generator].should == "Weblog Editor 2.0"
    end
    
    it "should serialize the entries of an rss2 feed" do
      @rss2.to_hash[:entries].should be_an_instance_of(Array)
      @rss2.to_hash[:entries].first.title.should == "Star City"
      @rss2.to_hash[:entries].first.url.should == "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp"
    end
    
    it "should serialize the author of an rss2 feed" do
      
      author = @rss2.to_hash[:author]
      
      author.name.should == "Mary Jo"
      author.email.should == "editor@example.com"
      author.uri.should be_nil
    end
  end

end