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
    require 'seinfeld/models'
    DataMapper.setup :default, Seinfeld.connection
  end

  task :setup => :init do
    DataMapper.auto_migrate!
    puts "Database reset"
  end

  task :update => :init do
    Seinfeld::User.paginated_each do |user|
      user.update_progress
    end
  end
end