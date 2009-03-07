require 'rubygems'
require 'sinatra'
require 'json'

$: << File.join(File.dirname(__FILE__), 'lib')
require 'seinfeld/models'
require 'seinfeld/calendar_helper'

$0 = __FILE__

error do
  e = request.env['sinatra.error']
  puts "#{e.class}: #{e.message}\n#{e.backtrace.join("\n  ")}"
end

configure do
  require File.dirname(__FILE__) + '/config/seinfeld.rb'
end

before do
  Time.zone = "UTC"
end

get '/' do
  response['Cache-Control'] = 'public, max-age=3600'
  @recent_users  = Seinfeld::User.best_current_streak
  @alltime_users = Seinfeld::User.best_alltime_streak
  haml :index
end

get '/~:name' do
  show_user_calendar
end

get '/~:name.json' do
  show_user_json
end

get '/~:name/:year' do
  show_user_calendar
end

get '/~:name/:year.json' do
  show_user_json
end

get '/~:name/:year/:month' do
  show_user_calendar
end

get '/~:name/:year/:month.json' do
  show_user_json
end

get '/group/:names' do
  show_group_calendar
end

post '/github' do
  if params[:token] == Seinfeld::User.creation_token
    Seinfeld::User.process_new_github_user(params[:subject])
  else
    redirect "/"
  end
end

helpers do
  include Seinfeld::CalendarHelper

  def page_title
    "%s's Calendar" % @user.login
  end

  def get_user_and_progressions(extra = 0)
    [:year, :month].each do |key|
      value       = params[key].to_i
      params[key] = value.zero? ? Date.today.send(key) : value
    end
    if @user = Seinfeld::User.first(:login => params[:name])
      Time.zone    = @user.time_zone || "UTC"
      progressions = @user.progress_for(params[:year], params[:month], extra)
    end
    Set.new(progressions || [])
  end

  def show_user_calendar
    response['Cache-Control'] = 'public, max-age=3600'
    @progressions = get_user_and_progressions(6)
    if @user
      haml :show
    else
      redirect "/"
    end
  end
  
  def show_group_calendar
    response['Cache-Control'] = 'public, max-age=3600'
    @progressions = Set.new
    @users = params[:names].split(',')
    @users.each do |name|
      params[:name] = name # hack
      @progressions.merge get_user_and_progressions(6)
    end
    haml :group
  end

  def show_user_json
    response['Cache-Control'] = 'public, max-age=3600'
    @progressions = get_user_and_progressions
    json = {:days => @progressions.map { |p| p.to_s }.sort!, :longest_streak => @user.longest_streak, :current_streak => @user.current_streak}.to_json
    if params[:callback]
      "#{params[:callback]}(#{json})"
    else
      json
    end
  end

  def link_to_user(user, streak_count = :current_streak)
    %(<a href="/~#{user.login}">#{user.login} (#{user.send(streak_count)})</a>)
  end

  def seinfeld
    now        = Date.new(params[:year], params[:month])
    prev_month = now << 1
    next_month = now >> 1
    calendar :year => now.year, :month => now.month,
      :previous_month_text => %(<a href="/~#{@user.login}/#{prev_month.year}/#{prev_month.month}">Previous Month</a>), 
      :next_month_text     => %(<a href="/~#{@user.login}/#{next_month.year}/#{next_month.month}" class="next">Next Month</a>) do |d|
      if @progressions.include? d
        [d.mday, {:class => "progressed"}]
      else
        [d.mday, {:class => "slacked"}]
      end
    end
  end
  
  def group_seinfeld
    now        = Date.new(params[:year], params[:month])
    prev_month = now << 1
    next_month = now >> 1
    calendar :year => now.year, :month => now.month do |d|
      if @progressions.include? d
        [d.mday, {:class => "progressed"}]
      else
        [d.mday, {:class => "slacked"}]
      end
    end
  end
end

