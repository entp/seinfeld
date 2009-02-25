$LOAD_PATH.push *Dir[File.join(File.dirname(__FILE__), '..', '..', 'vendor', '*', 'lib')]
require 'uri'
require 'rubygems'
require 'dm-core'
require 'active_support/time_with_zone'
require 'active_support/values/time_zone'
require 'active_support/core_ext/object'
require 'active_support/core_ext/date'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/time'
require 'active_support/basic_object'
require 'active_support/duration'
require 'open-uri'
require 'feed_me'
require 'mechanical_github'
require 'set'

module Seinfeld
  # Some of this is destined to be broken out into modules when support for
  # more services than just github is added.
  class User
    class << self
      attr_accessor :feed_format
      attr_accessor :creation_token
      attr_accessor :github_login
      attr_accessor :github_password
    end

    self.feed_format = "http://github.com/%s.atom?page=%d"

    include DataMapper::Resource
    property :id,                   Integer, :serial => true
    property :login,                String, :unique => true
    property :email,                String
    property :last_entry_id,        String
    property :current_streak,       Integer, :default => 0, :index => true
    property :longest_streak,       Integer, :default => 0, :index => true
    property :streak_start,         Date
    property :streak_end,           Date
    property :longest_streak_start, Date
    property :longest_streak_end,   Date
    property :time_zone,            String

    has n, :progressions, :class_name => "Seinfeld::Progression", :order => [:created_at.desc]

    def self.paginated_each(&block)
      max_id = 0
      while batch = next_batch(max_id)
        batch.each(&block)
        max_id = batch.map { |u| u.id }.max
      end
    end

    def self.next_batch(id)
      batch = all :order => [:id], :limit => 15, :id.gt => id
      batch.size.zero? ? nil : batch
    end

    def self.best_current_streak 
      all :current_streak.gt => 0, :order => [:current_streak.desc, :login], :limit => 15
    end

    def self.best_alltime_streak 
      all :longest_streak.gt => 0, :order => [:longest_streak.desc, :login], :limit => 15
    end

    def reset_progress
      clear_progress
      update_progress
    end

    def clear_progress
      transaction do
        progressions.destroy!
        update_attributes \
          :streak_start => nil, :streak_end => nil, :current_streak => nil,
          :longest_streak => nil, :longest_streak_start => nil, :longest_streak_end => nil,
          :last_entry_id => nil
      end
    end

    def update_progress
      transaction do
        days = committed_days_in_feed || []
        save

        unless days.empty?
          existing = progressions(:created_at => days).map { |p| p.created_at }
          days = days - existing
        end

        streaks = [current_streak = Streak.new(streak_start, streak_end)]

        days.sort!
        days.each do |day|
          if current_streak.current?(day)
            current_streak.ended = day
          else
            streaks << (current_streak = Streak.new(day))
          end
          progressions.create(:created_at => day)
        end
        highest_streak = streaks.empty? ? 0 : streaks.max { |a, b| a.days <=> b.days }

        if latest_streak = streaks.last
          self.streak_start   = latest_streak.started
          self.streak_end     = latest_streak.ended
          self.current_streak = latest_streak.current? ? latest_streak.days : 0
        end

        if highest_streak.days > longest_streak.to_i
          self.longest_streak       = highest_streak.days
          self.longest_streak_start = highest_streak.started
          self.longest_streak_end   = highest_streak.ended
        end

        save
      end
    end

    def committed_days_in_feed(page = 1)
      Time.zone     = time_zone || "UTC"
      feed          = get_feed(page)
      return nil if feed.nil?
      entry_id      = nil # track the first entry id to store in the user model
      skipped_early = nil
      return nil if feed.entries.empty?
      days = feed.entries.inject({}) do |selected, entry|
        this_entry_id = entry.item_id
        entry_id    ||= this_entry_id
        if last_entry_id == this_entry_id
          skipped_early = true
          break selected
        end

        if entry.title.downcase =~ %r{^#{login.downcase} (pushed|committed|applied fork commits|created branch)}
          updated = entry.updated_at.in_time_zone
          date    = Date.civil(updated.year, updated.month, updated.day)
          selected.update date => nil
        else
          selected
        end
      end.keys
      if page == 1
        self.last_entry_id = entry_id 
        unless skipped_early
          while paged_days = committed_days_in_feed(page += 1)
            days += paged_days
          end
          days.uniq!
        end
      end
      days
    end

    def progress_for(year, month, extra = 0)
      beginning = Date.new(year, month)
      ending    = (beginning >> 1) - 1
      progressions(:created_at => (beginning - extra)..(ending + extra), :order => [:created_at]).map { |p| Date.new(p.created_at.year, p.created_at.month, p.created_at.day) }
    end

    def longest_streak_url
      if longest_streak_start.nil? || longest_streak_end.nil?
        "/~#{login}"
      else
        "/~#{login}/#{longest_streak_start.year}/#{longest_streak_start.month}"
      end
    end

    def self.process_new_github_user(subject)
      login_name = subject.downcase.scan(/([\w\_\-]+) sent you a message/).first.to_s
      return if login_name.size.zero?
      if user = first(:login => login_name)
        if github_login && github_password
          session = MechanicalGithub::Session.new
          session.login github_login, github_password
          session.send_message login_name, "[CAN] You've already registered!", "Thanks for your enthusiasm, but you've already registered for a Calendar About Nothing: http://calendaraboutnothing.com/~#{user.login}"
        end
        nil
      else
        user = new(:login => login_name)
        yield user if block_given?
        if github_login && github_password
          session = MechanicalGithub::Session.new
          session.login github_login, github_password
          session.send_message login_name, "[CAN] Here's your calendar!", "Here's your calendar, but it may be a few minutes before I've had a chance to scan all your public github updates: http://calendaraboutnothing.com/~#{user.login}"
        end
        user.update_progress
      end
    end

  private
    def get_feed(page = 1)
      feed = nil
      open(self.class.feed_format % [login, page]) { |f| feed = FeedMe.parse(f.read) }
      feed
    rescue
      nil
    end
  end

  class Progression
    include DataMapper::Resource
    property :id,         Integer, :serial => true
    property :created_at, Date
    belongs_to :user, :class_name => "Seinfeld::User"
  end

  class Streak
    attr_accessor :started, :ended

    def initialize(started = nil, ended = nil)
      @started = started
      @ended   = ended || started
    end

    def days
      if @started && @ended
        1 + (@ended - @started).to_i.abs
      else
        0
      end
    end

    def current?(date = Date.today)
      @ended && (@ended + 1) >= date
    end

    def include?(date)
      if @started && @ended
        @started <= date && @ended >= date
      else
        false
      end
    end

    def inspect
      %(#{@started ? ("#{@started.year}-#{@started.month}-#{@started.day}") : :nil}..#{@ended ? ("#{@ended.year}-#{@ended.month}-#{@ended.day}") : :nil}:Streak)
    end
  end
end
