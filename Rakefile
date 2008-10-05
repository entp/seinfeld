$: << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

file_list = FileList['spec/*_spec.rb']

Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = file_list
end

desc 'Default: run specs.'
task :default => 'spec'

namespace :seinfeld do
  task :init do
    require 'app/config'
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
end
