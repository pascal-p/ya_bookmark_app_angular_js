
# require 'sinatra/base'           # instead of require 'sinatra' => modular Sinatra App
# require "sinatra/contrib" 
# require "sinatra/respond_with"   # from sinatra-contrib
# require 'sinatra/content_for'    #   "    "       "
# require 'sinatra/namespace'
# #
# require 'data_mapper'
# require 'dm-migrations'
# require "dm-serializer"          # resp. will be json serialized
# #
# require 'erb'  # instead of slim
# require 'json'


# #
# Dir.glob('./{helpers,controllers,models}/*.rb').each {|f| puts " -- loading #{f}"; require f}


#[ '/', '/bookmarks[/.*]?' ].each do |route|       # [ '/', %r{/bookmarks[/.*]?} ].each do |route|
#[ '/' ].each do |route|       # [ '/', %r{/bookmarks[/.*]?} ].each do |route|
#  $logger.debug "===> route: #{route.inspect}"
# map('/bookmarks/2') { run BookmarksController }
# map('/') { run BookmarksController }

#end


require_relative './bin/my_app'
run MyApp

