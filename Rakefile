# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rake'
require 'appraisal'

task :default => [:all]

task :test do |t|
  load 'test/undeletable_test.rb'
end

task all: ['appraisal:install'] do |t|
  exec 'rake appraisal test'
end
