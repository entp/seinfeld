# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mechanical_github}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dr Nic Williams", "Lincoln Stoll"]
  s.date = %q{2009-01-23}
  s.description = %q{This gem provides a automated API for working with github.}
  s.email = ["drnicwilliams@gmail.com", "lstoll@lstoll.net"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "features/development.feature", "features/steps/common.rb", "features/steps/env.rb", "lib/mechanical_github.rb", "lib/mechanical_github/repository.rb", "lib/mechanical_github/session.rb", "lib/mechanical_github/wiki.rb", "mechanical_github.gemspec", "script/console", "script/destroy", "script/generate", "spec/mechanical_github_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://drnic.github.com/mechanical_github}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mechanical_github}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{This gem provides a automated API for working with github.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mechanize>, [">= 0"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<mechanize>, [">= 0"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<mechanize>, [">= 0"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
