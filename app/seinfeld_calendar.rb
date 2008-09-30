require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
require 'seinfeld/calendar_helper'
require 'sinatra'

get '/' do
  'oy!'
end

get '/~:name' do
  haml :show
end

get '/~:name/:year' do
  haml :show
end

get '/~:name/:year/:month' do
  haml :show
end

helpers do
  include Seinfeld::CalendarHelper

  def seinfeld
    [:year, :month].each do |key|
      value        = params[key].to_i
      params[key] = value.zero? ? Date.today.send(key) : value
    end
    user         = Seinfeld::User.first :login => params[:name]
    progressions = user.progress_for(params[:year], params[:month])
    now        = Date.new(params[:year], params[:month])
    prev_month = now << 1
    next_month = now >> 1
    calendar :year => now.year, :month => now.month,
      :previous_month_text => %(<a href="/~#{user.login}/#{prev_month.year}/#{prev_month.month}">Previous Month</a>), 
      :next_month_text     => %(<a href="/~#{user.login}/#{next_month.year}/#{next_month.month}" class="next">Next Month</a>) do |d|
      if progressions.include? d
        [d.mday, {:class => "progressed"}]
      else
        [d.mday, {:class => "slacked"}]
      end
    end
  end
end

