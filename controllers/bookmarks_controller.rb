# -*- coding: utf-8 -*-

class BookmarksController < ApplicationController
  helpers BookmarkHelper

  # for json rendering
  def with_tag_list
    {:methods => [:tag_lst]}
  end

  before do
    # $logger.debug " ===> request #{request.inspect} "
    # $logger.debug " ===> params  #{params.inspect} "
    # $logger.debug " ===> env     #{env.inspect} "
  end

  #
  # take into account negative id
  #
  before %r{/bookmarks/([\-]?\d+)} do |id|
    if id.to_i > 0
      @bookmark = Bookmark.get(id)
      # $logger.debug "===> Found bookmark: #{@bookmark.inspect}"
    end

    if !@bookmark || id.to_i <= 0
      halt 404, "bookmark #{id.inspect} not found"
    end
  end

  #
  # FROM HERE C.R.U.D. bookmark
  #

  #
  # Create Part -
  #  Not using before filter
  #
  post "/bookmarks" do
    request.body.rewind
    params = JSON.parse request.body.read
    input = hslice params, "url", "title"

    @bookmark = Bookmark.new input
    # A bit of validation with the model constraints
    status = if @bookmark.save
               add_tags(@bookmark)
               :ok # Created
             else
               :ko
             end
    #
    # request.accept is an array - hence the following loop
    # first match  => halt action to escape the loop
    #
    _json = -1
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        status == :ok ? halt(erb :bookmark_show) : halt(erb :bookmark_new, status: 400)

      when 'text/json'
      when 'application/json'
        # 400 == Bad request
        # OK: [201, "/bookmarks/#{bookmark['id']}"]
        #
        _json = (status == :ok) ? [201, "/bookmarks/#{@bookmark['id']}"] : 400
        break
      end
    end
    #
    _json if _json != -1
  end

  #
  # Read Part -
  #

  # =========================================
  # Frontend access  STARTS
  #
  get "/" do
    redirect "/example/base"
  end

  get "/example/:example" do
    @examples = [
      {example: "base", label:  "Base"},
      {example: "validation", label: "Validation"},
      {example: "tagfilter", label: "Tag Filter"},
      {example: "routing", label: "Routing"}
    ]
    @example = params[:example]

    @examples.each do |example|
      if example[:example] == @example
        example[:active] = true
      end
    end

    @example_template = IO.read("views/#{@example}.html")

    erb :index
  end
  #
  # Frontend access  ENDS
  # =========================================

  #
  # edit - order matters, this clause should comme before %r{/bookmarks/\d+}
  # using before filter top get the id and set the @bookmark
  #
  get %r{/bookmarks/\d+/edit} do
    my_render(request, :bookmark_edit)
  end

  #
  # using before filter top get the id and set the @bookmark
  #
  get %r{/bookmarks/[\-]?\d+} do
    # filter before will intercept this call and will do some checks
    my_render(request, :bookmark_show)
  end

  #
  # by tags - this method MUST go after [ "/", "/bookmarks" ].each do ... end above
  #
  get "/bookmarks/*" do |*splat|
    tags = splat.first.split(/\//)
    @bookmarks = Bookmark.all.select {|bmk| tags & bmk.tag_lst == tags}
    my_render(request, :bookmark_index, @bookmarks)
  end

  # New - using erb - only for html view
  get "/bookmark/new" do
    erb :bookmark_new
  end

  [ "/", %r{/bookmarks[/]?} ].each do |url|
    get(url, provides: [:html, :json]) do
      ## return json or HTML depending on header content
      @bookmarks = get_all_bookmarks
      resp = respond_with :bookmark_index, @bookmarks
      # \__ Accept: application/json or HTML view for the Accept: text/html
      resp
    end
  end

  #
  # Update Part - allow partial updates
  # using before filter top get the id and set the @bookmark
  #
  put %r{/bookmarks/\d+} do
    input = hslice params, "url", "title"
    input['url']   = @bookmark.url   if input['url'].nil?
    input['title'] = @bookmark.title if input['title'].nil?
    #
    status = if @bookmark.update input
               add_tags(@bookmark)  # tags update here, using params
               :ok
             else
               :ko
             end
    #
    # request.accept is an array - hence the following loop
    # first match  => halt action to escape the loop
    #
    _json = -1
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        status == :ok ? halt(erb :bookmark_show) : halt(erb :bookmark_edit, status: 400)

      when 'text/json'
      when 'application/json'
        _json = (status == :ok) ? 204 : 400
        break
      end
    end
    _json if _json != -1
  end

  #
  # Delete Part
  # using before filter top get the id and set the @bookmark
  #
  delete %r{/bookmarks/\d+} do
    @bookmark.destroy
    200
  end

end
