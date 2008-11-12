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
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/seinfeld')
  DataMapper.auto_migrate!

  config = YAML.load(File.dirname(__FILE__) + '/config/seinfeld_user.yaml') rescue {}
  Seinfeld::User.github_login    = config['github_login']
  Seinfeld::User.github_password = config['github_password']
  Seinfeld::User.creation_token  = config['github_creation_token']
end

get '/' do
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

  def get_user_and_progressions
    [:year, :month].each do |key|
      value       = params[key].to_i
      params[key] = value.zero? ? Date.today.send(key) : value
    end
    if @user = Seinfeld::User.first(:login => params[:name])
      @progressions = Set.new @user.progress_for(params[:year], params[:month])
    end
  end

  def show_user_calendar
    get_user_and_progressions
    if @user
      haml :show
    else
      redirect "/"
    end
  end

  def show_user_json
    get_user_and_progressions
    {:days => @progressions.map { |p| p.to_s }, :longest_streak => @user.longest_streak, :current_streak => @user.current_streak}.to_json
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
end

