#!/usr/bin/env ruby
# coding: utf-8

begin
 require 'rubygems'
 require 'bundler/setup'

rescue Exception => e
 STDERR.puts("[!] ignoring #{e.message} - this is is fine if you are not using bundler") if $VERBOSE
end

require 'json'
require 'sinatra/base'           # instead of require 'sinatra' => modular Sinatra App
#
require "sinatra/contrib"
require "sinatra/respond_with"   # from sinatra-contrib
require 'sinatra/content_for'    #   "    "       "
require 'sinatra/namespace'
#
require 'data_mapper'
require 'dm-migrations'
require "dm-serializer"          # resp. will be json serialized
#
require 'erubis'                 #require 'erb'  # instead of slim
require 'tilt/erubis'
#
#
Dir.glob('./{helpers,models}/**/*.rb').each {|f| require f}
# WARN: Hum... This won't allways work! application_controller needs to be loaded
# before bookmark_controller
Dir.glob('./controllers/**/*.rb').sort.each {|f| require f}

class MyApp < Sinatra::Application

  self.configure(:development) do
    DataMapper::Logger.new($stdout, :debug)
    # DataMapper::Model.raise_on_save_failure = true
    # \__ save or update will return true or false instead of raising an exception (default actually)

    DataMapper.setup(:default,
                     ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/bookmarks_development.db")
    #
    # Create the table if it does not exist yet
    # Update the table by adding columns to it if new property were added
    # Keep previous data
    #
    DataMapper.finalize.auto_upgrade!
  end

  self.configure(:test) do
    DataMapper.setup(:default,
                     ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/bookmarks_test.db")


    # for testing use (wipeout at each start) => spec/spec_helper.rb
    DataMapper.finalize.auto_migrate!
  end

  self.configure(:production) do
    DataMapper::Logger.new($stdout, :warn)

    DataMapper.setup(:default,
                     ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/bookmarks_development.db")
    #
    # Create the table if it does not exist yet
    # Update the table by adding columns to it if new property were added
    # Keep previous data
    #
    DataMapper.finalize.auto_upgrade!
  end

  #
  # Global setup for this app
  #
  SITE_TITLE = "Bookmark REST API"
  #
  set :root,          File.join(File.dirname(__FILE__), '..')
  set :app_file,      __FILE__
  set :views,         settings.root + '/views/erb'
  set :public_folder, settings.root + '/resources'
  # The following only applied with erubis
  set :erb,           escape_html: true

  use ApplicationController
  use BookmarksController

  run! if __FILE__ == $0
end
