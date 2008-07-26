require 'seinfeld/models'
require 'seinfeld/calendar_helper'
require 'sinatra'

DataMapper.setup :default, Seinfeld.connection

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
    calendar :year => params[:year], :month => params[:month] do |d|
      if progressions.include? d
        [d.mday, {:class => "progressed"}]
      else
        [d.mday, {:class => "slacked"}]
      end
    end
  end
end

