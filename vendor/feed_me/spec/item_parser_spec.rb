require File.join( File.dirname(__FILE__), "spec_helper" )

require 'feed_me'

describe FeedMe::ItemParser do

  before :each do
    @atom_feed = FeedMe::FeedParser.open(fixture('welformed.atom'))
    @atom = FeedMe::ItemParser.build(@atom_feed.root_node.search('/entry').first, :atom, @atom_feed)
    @rss2_feed = FeedMe::FeedParser.open(fixture('welformed.rss2'))
    @rss2 = FeedMe::ItemParser.build(@rss2_feed.root_node.search('/item').first, :rss2, @rss2_feed)
  end
  
  describe '#to_hash' do
    it "should serialize the parsed properties to a hash" do
      
    end
  end
    
  describe '#title' do
    it "should be valid for an atom feed" do
      @atom.title.should == "First title"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.title.should == "Star City"
    end
  end
  
  describe '#content' do
    it "should be valid for an atom feed" do
      @atom.content.should == "Here be content"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.content.should == "This is content"
    end
  end
  
  describe '#item_id' do
    it "should be valid for an atom feed" do
      @atom.item_id.should == "tag:imaginary.host,2008-03-07:nyheter/3"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.item_id.should == "http://liftoff.msfc.nasa.gov/2003/06/03.html#item573"
    end
  end
  
  describe '#updated_at' do
    it "should be valid for an atom feed" do
      @atom.updated_at.should == Date.civil( 2008, 3, 7, 20, 41, 10 )
    end
    
    it "should be nil for an rss2 feed" do
      @rss2.updated_at.should be_nil
    end
  end
  
  describe '#url' do
    it "should be valid for an atom feed" do
      @atom.url.should == "http://imaginary.host/posts/3"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.url.should == "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp"
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
      @atom.author.name.should == "Jonas Nicklas"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.author.name.should == "Chuck Norris"
    end
  end
  
  describe '#author.email' do
    it "should be valid for an atom feed" do
      @atom.author.email.should == "jonas.nicklas@imaginary.host"
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.author.email.should == "da_man@example.com"
    end
  end
  
  describe '#author.uri' do
    it "should be valid for an atom feed" do
      @atom.author.uri.should == "http://imaginary.host/students/jnicklas"
    end
    
    it "should be nil for an rss2 feed" do
      @rss2.author.uri.should be_nil
    end
  end
  
  describe '#to_hash' do
    
    it "should serialize the title for an atom feed" do
      @atom.to_hash[:title].should == "First title"
    end
    
    it "should serialize the item_id for an atom feed" do
      @atom.to_hash[:item_id].should == "tag:imaginary.host,2008-03-07:nyheter/3"
    end
    
    it "should serialize updated_at for an atom feed" do
      @atom.to_hash[:updated_at].should == Date.civil( 2008, 3, 7, 20, 41, 10 )
    end
    
    it "should serialize the url for an atom feed" do
      @atom.to_hash[:url].should == "http://imaginary.host/posts/3"
    end
    
    it "should serialize the author of an atom feed" do
      author = @atom.to_hash[:author]
      
      author.name.should == "Jonas Nicklas"
      author.email.should == "jonas.nicklas@imaginary.host"
      author.uri.should == "http://imaginary.host/students/jnicklas"
    end
    
    it "should serialize the title for an rss2 feed" do
      @rss2.to_hash[:title].should == "Star City"
    end
    
    it "should serialize the item_id for an rss2 feed" do
      @rss2.to_hash[:item_id].should == "http://liftoff.msfc.nasa.gov/2003/06/03.html#item573"
    end
    
    it "should serialize updated_at for an rss2 feed" do
      @rss2.to_hash[:updated_at].should be_nil
    end
    
    it "should serialize the url for an rss2 feed" do
      @rss2.to_hash[:url].should == "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp"
    end
    
    it "should serialize the author of an rss2 feed" do
      author = @rss2.to_hash[:author]
      
      author.name.should == "Chuck Norris"
      author.email.should == "da_man@example.com"
      author.uri.should be_nil
    end
  end

end

describe "Without an author", FeedMe::ItemParser do

  before :each do
    @atom_feed = FeedMe::FeedParser.open(fixture('welformed.atom'))
    @atom = FeedMe::ItemParser.build(@atom_feed.root_node.search('/entry')[1], :atom, @atom_feed)
    @rss2_feed = FeedMe::FeedParser.open(fixture('welformed.rss2'))
    @rss2 = FeedMe::ItemParser.build(@rss2_feed.root_node.search('/item')[1], :rss2, @rss2_feed)
  end
  
  describe '#author.name' do
    it "should be valid for an atom feed" do
      @atom.author.name.should be_nil
    end
    
    it "should be valid for an rss2 feed" do
      @rss2.author.name.should be_nil
    end
  end

end