module FeedMe
  
  class FeedParser < AbstractParser
  
    self.properties = FEED_PROPERTIES
  
    class << self
    
      def open(file)
        self.parse(Kernel.open(file).read)
      end
    
      # parses the passed feed and identifeis what kind of feed it is
      # then returns a parser object
      def parse(feed)
        xml = Hpricot.XML(feed)
    
        root_node, format = self.identify(xml)
        self.build(root_node, format)
      end
      
      protected
  
      def identify(xml)
        FeedMe::ROOT_NODES.each do |f, s|
          item = xml.at(s)
          return item, f if item
        end
      end
    
    end
  end
  
  class AtomFeedParser < FeedParser
    self.properties = FEED_PROPERTIES
    
    def entries
      xml.search('entry').map do |el|
        ItemParser.build(el, self.format, self)
      end
    end
  end
  
  class Rss2FeedParser < FeedParser
    self.properties = FEED_PROPERTIES
    
    def entries
      xml.search('item').map do |el|
        ItemParser.build(el, self.format, self)
      end
    end
    
    def author
      fetch_rss_person("managingEditor")
    end
  end
end