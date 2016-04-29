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

require 'tilt/erubis'
require 'tilt/haml'
# require 'tilt/sass'
require 'tilt/less'
require 'tilt/builder'
require 'tilt/asciidoc'
require 'tilt/markaby'
require 'tilt/nokogiri'
require 'tilt/coffee'
require 'tilt/creole' 
require 'tilt/sass'
require 'tilt/redcarpet'
require 'tilt/redcloth'
require 'tilt/rdoc'
require 'tilt/radius'
require 'tilt/yajl'
require 'tilt/wikicloth'
require 'tilt/liquid'
#
require 'slim'

configure :development do
  DataMapper::Logger.new($stdout, :debug)  
  # DataMapper::Model.raise_on_save_failure = true
  # \__ save or update will return true or false instead of raising an exception (default actually)
end 

DataMapper.setup(:default,
                 ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/bookmarks.db")
#
SITE_TITLE = "Bookmark REST API (test)"
#
require_relative '../models/bookmark'
require_relative '../models/bookmark_tagging'
require_relative '../models/tag'
require_relative '../controllers/bookmark'

set :root, File.join(File.dirname(__FILE__), '..')
set :app_file, __FILE__
set :views, settings.root + '/views/erb'
set :public_folder, settings.root + '/resources'

#
# Create the table if it does not exist yet
# Update the table by adding columns to it if new property were added
# Keep previous data
# 
DataMapper.finalize.auto_upgrade!

# for testing use (wipeout at each start)
# DataMapper.finalize.auto_migrate!
