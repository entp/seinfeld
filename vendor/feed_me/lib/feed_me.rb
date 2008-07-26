# make sure we're running inside Merb
if defined?(Merb::Plugins)
  dependency 'hpricot'
else
  require 'rubygems'
  require 'hpricot'
end

unless nil.respond_to? :try
  # the ultimate duck
  class Object
    def try(method, *args)
      self.send(method, *args)
    rescue NoMethodError
      nil
    end
  end
end

module FeedMe
  def self.parse(feed)
    FeedMe::FeedParser.parse(feed)
  end
  
  def self.open(file)
    FeedMe::FeedParser.parse(file)
  end
end

['consts', 'abstract_parser', 'feed_struct', 'simple_struct',
  'feed_parser', 'item_parser'].each do |f|
  require File.join(File.dirname(__FILE__), 'feed_me', f)
end