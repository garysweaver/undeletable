# -*- encoding: utf-8 -*-  
$:.push File.expand_path("../lib", __FILE__)  
require "undeletable/version" 

Gem::Specification.new do |s|
  s.name        = 'undeletable'
  s.version     = Undeletable::VERSION
  s.authors     = ['Gary S. Weaver']
  s.email       = ['garysweaver@gmail.com']
  s.homepage    = 'https://github.com/garysweaver/undeletable'
  s.summary     = "Stop destroy/delete on certain ActiveRecord models without disallowing other actions"
  s.description = "Ignores or raises error on destroy/delete of an ActiveRecord model instance, but is not marked as read-only and can be created/updated. This is a significantly modified fork of the Paranoia gem (by Ryan Bigg and others)."
  s.required_rubygems_version = ">= 1.3.6"
  s.files = Dir['lib/**/*'] + ['Rakefile', 'README.md']
  s.license = 'MIT'
  s.add_runtime_dependency 'activerecord', '>= 3.0.0'
  s.add_development_dependency "activerecord", ">= 3.0.0"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rake", "0.8.7"
end
