$: << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'rake/gempackagetask'
# If this require failes, try "gem install rspec"
require 'spec/rake/spectask'
require 'time'

file_list = FileList['spec/*_spec.rb']

Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = file_list
end

desc 'Default: run specs.'
task :default => 'spec'

desc "cron task for keeping the CAN updated.  Run once every hour."
task :cron => 'seinfeld:init' do
  if Time.now.hour % 4 == 0
    Seinfeld::User.paginated_each do |user|
      user.update_progress
    end
  end
end

namespace :seinfeld do
  task :init do
    $: << File.join(File.dirname(__FILE__), 'lib')
    require 'seinfeld/models'
    require 'seinfeld/calendar_helper'
    require File.dirname(__FILE__) + '/config/seinfeld.rb'
  end

  task :setup => :init do
    DataMapper.auto_migrate!
    puts "Database reset"
  end

  task :show => :init do
    raise "Need USER=" if ENV['USER'].to_s.size.zero?
    u = Seinfeld::User.first(:login => ENV['USER'])
    puts "#{u.login}#{" #{u.time_zone}" if u.time_zone}"
    puts "Current Streak: #{u.current_streak} #{u.streak_start} => #{u.streak_end}"
    puts "Longest Streak: #{u.longest_streak} #{u.longest_streak_start} => #{u.longest_streak_end}"
  end

  task :tz => :init do
    raise "Need USER=" if ENV['USER'].to_s.size.zero?
    raise "Need ZONE=" if ENV['ZONE'].to_s.size.zero?
    zone = ActiveSupport::TimeZone::MAPPING[ENV['ZONE']] || ActiveSupport::TimeZone::MAPPING.index(ENV['ZONE']) || raise("Bad Time Zone")
    u = Seinfeld::User.first(:login => ENV['USER'])
    u.time_zone = zone
    u.save
  end

  task :add => :init do
    raise "Need USER=" if ENV['USER'].to_s.size.zero?
    Seinfeld::User.create(:login => ENV['USER'])
  end

  task :drop => :init do
    raise "Need USER=" if ENV['USER'].to_s.size.zero?
    Seinfeld::User.first(:login => ENV['USER']).destroy
  end

  task :update => :init do
    if ENV['USER'].to_s.size.zero?
      Seinfeld::User.paginated_each do |user|
        user.update_progress
      end
    else
      user = Seinfeld::User.first(:login => ENV['USER'])
      if user
        user.update_progress
      else
        raise "No user found for #{ENV['USER'].inspect}"
      end
    end
  end

  task :clear => :init do
    raise "Need USER=" if ENV['USER'].to_s.size.zero?
    Seinfeld::User.first(:login => ENV['USER']).clear_progress
  end

  task :reset => :init do
    raise "Need USER=" if ENV['USER'].to_s.size.zero?
    Seinfeld::User.first(:login => ENV['USER']).reset_progress
  end
end
