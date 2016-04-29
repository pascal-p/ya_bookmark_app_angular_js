# -*- coding: utf-8 -*-

require_relative '../helpers/bookmark.rb'

#
# Create
#
post "/bookmarks" do
  input = hslice params, "url", "title"
  bookmark = Bookmark.new input
  # A bit of validation with the model constraints
  if bookmark.save
    add_tags(bookmark)
    # Created
    [201, "/bookmarks/#{bookmark['id']}"]
  else
    # Bad Request
    400
  end
end

with_tag_list = {:methods => [:tag_lst]}

#
# Read - list all bookmark(s)
#
get %r{/bookmarks/\d+} do
  # filter before will intercept this call and will do some checks   
  content_type :json
  @bookmark.to_json with_tag_list
end

get "/bookmarks/*" do |*splat|
  tags = splat.first.split(/\//)
  bookmarks = Bookmark.all
  bookmarks.select {|bmk| tags & bmk.tag_lst == tags}
  content_type :json
  bookmarks.to_json with_tag_list 
end

get "/bookmarks" do
  ## return json or HTML depending on header contains:
  @bookmarks = get_all_bookmarks
  resp = respond_with :bookmark_list, @bookmarks # Accept: application/json or HTML view for the Accept: text/html
  STDERR.print("resp: #{resp.inspect}\n") if $VERBOSE
  resp
end

# using erb
get "/bookmark/new" do
  erb :bookmark_form_new
end

#
# Update - allow partial updates
#
put "/bookmarks/:id" do |id|
  # filter before will intercept this call and will do some checks   
  input = hslice params,  "url", "title"
  input['url'] =  @bookmark.url if input['url'].nil?
  input['title'] =  @bookmark.title if input['title'].nil?
  #
  if @bookmark.update input
    204 # No Content
  else
    400 # Bad Request
  end
end

#
# Delete
#
delete "/bookmarks/:id" do |id|
  # filter before will intercept this call and will do some checks
  @bookmark.destroy
  200
end
