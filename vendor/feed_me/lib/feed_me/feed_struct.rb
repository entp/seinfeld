module FeedMe
  
  class FeedStruct < AbstractParser
    
    def initialize(xml, properties)
      self.xml = xml
      self.properties = properties
      append_methods
    end
    
  end
  
end