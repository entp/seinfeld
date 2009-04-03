class FeedMe::AbstractParser
  
  class << self
    
    attr_accessor :properties, :root_nodes
    
    def build(xml, format, *args)
      # in a world with activesupport this would have been written as
      #   format_parser = (format.to_s.camelize + self.to_s).constantize
      camelized_format = format.to_s.split('_').map{ |w| w.capitalize }.join('')
      bare_class = self.to_s.split('::').last
            
      begin
        format_parser = FeedMe.const_get(camelized_format + bare_class)
      rescue NameError
      end

      if format_parser.is_a?(Class) and format_parser.ancestors.include?(self)
        return format_parser.new(xml, format, *args)
      else
        return self.new(xml, format, *args)
      end

    end
    
  end

  def initialize(xml, format)
    self.xml = xml
    self.format = format
    self.properties = self.class.properties[self.format]
    
    append_methods
  end
  
  def to_hash
    hash = {}
    self.properties.each do |method, p|
      hash[method] = self.send(method)
    end
    return hash
  end
  
  attr_accessor :xml, :format, :properties

  alias_method :root_node, :xml
  
  protected
  
  def fetch_rss_person(selector)
    item = fetch(selector)
    if(item)
      email, name = item.split(/\s+/, 2)
      name = name.match( /\((.*?)\)/ ).to_a[1] if name # strip parentheses
    else
      name, email = nil
    end
    FeedMe::SimpleStruct.new(:email => email, :name => name, :uri => nil)
  end
  
  def append_methods
    self.properties.each do |method, p|
      unless respond_to?(method)
        block = get_proc_for_property(method, p)
        # meta programming magic
        (class << self; self; end).module_eval do
          define_method method, &block
        end
      end
    end
  end
  
  def get_proc_for_property(method, p)
    if p.class == Array
      return caching_proc(method, &proc { fetch("/#{p[0]}", root_node, p[1].to_sym) })
    elsif p.class == Hash
      return caching_proc(method, &proc { FeedMe::FeedStruct.new(root_node, p) })
    elsif p != :undefined
      return caching_proc(method, &proc { fetch("/#{p}", root_node) })
    else
      return proc { nil }
    end
  end
  
  def caching_proc(name, &block)
    proc do
      unless result = instance_variable_get("@#{name}")
        result = yield
        instance_variable_set("@#{name}", result)
      end
      result
    end
  end

  def fetch(selector, search_in = xml, method = :inner_html)
    item = search_in.at(selector)
    
    self.try("extract_" + method.to_s, item) if item
  end
  
  def extract_inner_html(item)
    item.inner_html
  end
  
  def extract_href(item)
    item[:href]
  end
  
  def extract_time(item)
    Time.parse(item.inner_html).utc
  end
  
end