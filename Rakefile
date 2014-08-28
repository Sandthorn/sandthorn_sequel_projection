#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :console do
  require 'awesome_print'
  require 'pry'
  require 'bundler'
  require 'sandthorn_sequel_projection'
  ARGV.clear
  Pry.start
end
