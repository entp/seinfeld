module FeedMe
  
  ROOT_NODES = {
    :atom => "//feed[@xmlns='http://www.w3.org/2005/Atom']",
    :rss2 => "//rss[@version=2.0]/channel"
  }
  
  FEED_PROPERTIES = {
    :atom => {
      :title => :title,
      :updated_at => [:updated, :time],
      :feed_id => :id,
      :url => ["link[@rel=alternate]", :href],
      :href => ["link[@rel=self]", :href],
      :description => :subtitle,
      :generator => :generator,
      :author => {
        :email => 'author/email',
        :name => 'author/name',
        :uri => 'author/uri'
      },
      :entries => :special
    },
    :rss2 => {
      :title => :title,
      :updated_at => [:lastBuildDate, :time],
      :feed_id => :undefined,
      :url => :link,
      :href => :undefined,
      :description => :description,
      :generator => :generator,
      :author => :special,
      :entries => :special
    }
  }
  
  ITEM_PROPERTIES = {
    :atom => {
      :title => :title,
      :updated_at => [:updated, :time],
      :item_id => :id,
      :url => ["link[@rel=alternate]", :href],
      :content => :content,
      :author => {
        :email => 'author/email',
        :name => 'author/name',
        :uri => 'author/uri'
      }
    },
    :rss2 => {
      :title => :title,
      :updated_at => :undefined,
      :item_id => :guid,
      :url => :link,
      :content => :description,
      :author => :special
    }
  } 
  
  AUTHOR_PROPERTIES = {
    :atom => {
      :name => :name,
      :uri => :uri,
      :email => :email
    }
  } 
  
end