module FeedMe
  
  class SimpleStruct
    
    def initialize(hash = {})
      (class << self; self; end).module_eval do
        hash.each do |method, result|
          define_method( method ) { result }
        end
      end
    end
    
  end
  
end