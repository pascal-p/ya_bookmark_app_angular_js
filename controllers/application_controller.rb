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

  set :root,          File.realpath(File.join(File.dirname(__FILE__), '..'))
  set :app_file,      __FILE__
  set :views,         settings.root + '/views/erb'
  set :public_folder, settings.root + '/public'   # set :public_folder, settings.root + '/assets'
  set :environment,   :development

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
    $logger = Logger.new(settings.root + '/logs/common.log','weekly')
    $logger.level = Logger::WARN
  end

  configure(:test) do
    disable :logging
  end

  configure(:development) do
    $logger.level = Logger::DEBUG
    # $logger = Logger.new(STDOUT)
  end

  # will be used to display 404 error pages
  not_found do
    title 'Not Found!'
    erb :not_found
  end

end
