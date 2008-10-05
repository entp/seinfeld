$: << File.join(File.dirname(__FILE__), '..', '..', 'vendor', 'feed_me', 'lib')
require 'rubygems'
require 'open-uri'
require 'dm-core'
require 'feed_me'
require 'set'

module Seinfeld
  class User
    include DataMapper::Resource
    property :id,             Integer, :serial => true
    property :login,          String
    property :email,          String
    property :last_entry_id,  String
    property :current_streak, Integer, :default => 0
    property :longest_streak, Integer, :default => 0
    property :streak_start,   Date
    property :streak_end,     Date
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

    def update_progress
      transaction do
        days = committed_days_in_feed
        save
        unless days.empty?
          existing = progressions(:created_at => days).map { |p| p.created_at }
          streaks = []
          current_streak = Streak.new(streak_start, streak_end)
          days = days - existing
          days.sort!
          days.reverse!
          days.each do |day|
            if current_streak.ended
              current_streak.started = day
            else
              streaks << (current_streak = Streak.new(nil, day))
            end
            puts current_streak.inspect
            progressions.create(:created_at => day)
          end
          highest_streak      = streaks.max { |st| st.days }.days
          latest_streak       = streaks.first
          self.streak_start   = latest_streak.started
          self.streak_end     = latest_streak.ended
          self.current_streak = latest_streak.days if latest_streak.current?
          self.longest_streak = highest_streak if highest_streak > longest_streak.to_i
          save
        end
      end
    end

    def committed_days_in_feed(page = 1)
      feed          = get_feed(page)
      entry_id      = nil # track the first entry id to store in the user model
      skipped_early = nil
      return [] if feed.entries.empty?
      days = feed.entries.inject({}) do |selected, entry|
        this_entry_id = entry.item_id
        if last_entry_id == this_entry_id
          skipped_early = true
          break selected
        end
        entry_id ||= this_entry_id

        if entry.title =~ %r{^#{login} committed}
          updated = entry.updated_at
          date    = Date.civil(updated.year, updated.month, updated.day)
          selected.update date => nil
        else
          selected
        end
      end.keys
      self.last_entry_id = entry_id if page == 1
      unless skipped_early
        days += committed_days_in_feed(page + 1)
        days.uniq!
      end
      days
    end

    def progress_for(year, month)
      start = Date.new(year, month)
      Set.new progressions(:created_at => start..((start >> 1) - 1)).map { |p| Date.new(p.created_at.year, p.created_at.month, p.created_at.day) }
    end

  private
    def get_feed(page = 1)
      feed = nil
      open("http://github.com/#{login}.atom?page=#{page}") { |f| feed = FeedMe.parse(f.read) }
      feed
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
      @ended   = ended
    end

    def days
      if @started && @ended
        1 + (@ended - @started).to_i.abs
      else
        0
      end
    end

    def current?
      @ended && (@ended + 1) >= (Date.today)
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