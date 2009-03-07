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

task :cron => 'seinfeld:init' do
  #if Time.now.hour % 6 == 0
    Seinfeld::User.paginated_each do |user|
      puts "[#{Time.now.utc.xmlschema}] updating #{user.login}"
      user.update_progress
    end
  #end
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

  task :add_user => :init do
    raise "Need USER=" if ENV['USER'].to_s.size.zero?
    Seinfeld::User.create(:login => ENV['USER'])
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

  task :reset => :init do
    raise "Need USER=" if ENV['USER'].to_s.size.zero?
    Seinfeld::User.first(:login => ENV['USER']).reset_progress
  end
end
