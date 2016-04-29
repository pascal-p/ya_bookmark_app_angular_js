#!/usr/bin/env ruby
# coding: utf-8

begin
 require 'rubygems'
 require 'bundler/setup'
 
rescue Exception => e
 STDERR.puts("[!] ignoring #{e.message} - this is is fine if you are not using bundler") if $VERBOSE
end

require 'json'
require 'sinatra'
require "sinatra/respond_with"   # from sinatra-contrib
require 'data_mapper'
require 'dm-migrations'
require "dm-serializer"          # resp. will be json serialized

configure :development do
  DataMapper::Logger.new($stdout, :debug)  
  # DataMapper::Model.raise_on_save_failure = true  # save or update will return true or false instead of raising an exception (default actually)
  DataMapper.setup(:default,
                   ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/bookmarks.db")
  #
  SITE_TITLE = "Bookmark REST API (test)"
end 

require_relative 'models/bookmark'
require_relative 'controllers/bookmark'

set :app_file, __FILE__
set :views, settings.root + '/views/erb'
set :public_folder, settings.root + '/resources'

#
# Create the table if it does not exist yet
# Update the table by adding columns to it if new property were added
# Keep previous data
# 
DataMapper.finalize.auto_upgrade!

# for testing use (wipeout at eahc start)
#DataMapper.finalize.auto_migrate!
