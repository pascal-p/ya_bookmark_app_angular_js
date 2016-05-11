# -*- coding: utf-8 -*-
require 'logger'

class ApplicationController < Sinatra::Application
  helpers ApplicationHelper
  helpers Sinatra::ContentFor
  helpers Sinatra::RespondWith
  #
  register Sinatra::Namespace
  register Sinatra::Contrib

  SITE_TITLE = "Bookmark REST API"

  set :root, File.realpath(File.join(File.dirname(__FILE__), '..'))
  # /usr/home/pascal/git/7web_framework_in_7weeks/Sinatra/02_bookmarks_REST_WEB_TAG/controllers/
  #
  set :app_file,      __FILE__
  set :views,         settings.root + '/views/erb'
  set :public_folder, settings.root + '/assets'

  set :environment, :development

  # Views - customization
  # configure do
  #   set :views, [
  #                 settings.root + '/views/erb/bookmarks',
  #                 settings.root + '/views/erb/shared',
  #                 settings.root + '/views/erb/layouts' ]
  #   # settings.root + '/views/erb',
  # end

  # don't enable logging when running tests
  configure(:production, :development) do
    enable :logging
    #
    Dir.mkdir('logs') unless File.exist?('logs')
    $logger = Logger.new('logs/common.log','weekly')
    $logger.level = Logger::WARN
  end

  configure(:test) do
    disable :logging
  end

  configure(:development) do
    $logger.level = Logger::DEBUG
    # $logger = Logger.new(STDOUT)
    DataMapper::Logger.new($stdout, :debug)
    # DataMapper::Model.raise_on_save_failure = true
    # \__ save or update will return true or false instead of raising an exception (default actually)
  end

  DataMapper.setup(:default,
                   ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/bookmarks.db")

  #
  # Create the table if it does not exist yet
  # Update the table by adding columns to it if new property were added
  # Keep previous data
  #
  DataMapper.finalize.auto_upgrade!

  # for testing use (wipeout at each start)
  # DataMapper.finalize.auto_migrate!

  # will be used to display 404 error pages
  not_found do
    title 'Not Found!'
    erb :not_found
  end

end
