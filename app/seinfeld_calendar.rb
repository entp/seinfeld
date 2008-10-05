unless Object.const_defined?(:Seinfeld)
  # setup a config.ru for rack, or some other ruby config file
  $: << File.join(File.dirname(__FILE__), '..', 'lib')
  require 'seinfeld/models'
  DataMapper.setup :default, 'mysql://localhost/seinfeld'
end

require 'seinfeld/calendar_helper'
require 'sinatra'

get '/' do
  @recent_users  = Seinfeld::User.all :order => [:current_streak.desc, :login], :limit=> 15
  @alltime_users = Seinfeld::User.all :order => [:longest_streak.desc, :login], :limit=> 15
  haml :index
end

get '/~:name' do
  get_user_and_progressions
end

get '/~:name/:year' do
  get_user_and_progressions
end

get '/~:name/:year/:month' do
  get_user_and_progressions
end

helpers do
  include Seinfeld::CalendarHelper

  def page_title
    "%s's Calendar" % @user.login
  end

  def get_user_and_progressions
    [:year, :month].each do |key|
      value        = params[key].to_i
      params[key] = value.zero? ? Date.today.send(key) : value
    end
    if @user = Seinfeld::User.first(:login => params[:name])
      @progressions = @user.progress_for(params[:year], params[:month])
      haml :show
    else
      redirect "/"
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
end

