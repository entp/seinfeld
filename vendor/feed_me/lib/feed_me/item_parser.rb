module FeedMe
  
  class ItemParser < AbstractParser
  
    self.properties = ITEM_PROPERTIES
    
    attr_accessor :feed
    
    def initialize(xml, format, feed)
      super(xml, format)
      self.feed = feed
    end
  
  end
  
  class Rss2ItemParser < ItemParser
    
    self.properties = ITEM_PROPERTIES
    
    def author
      fetch_rss_person("author")
    end
    
  end
end