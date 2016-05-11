require_relative './spec_helper'
require_relative "../bin/my_app"

describe "bookmark APP:" do
  include Rack::Test::Methods

  def app
    # Modular App:
    MyApp
    # Classical Sinatra (using DSL)
    # Sinatra::Application
  end

  #
  # internal helpers

  #
  # for testing API:
  #
  HTTP_HDR = { "HTTP_ACCEPT" => "application/json",
               "HTTP_CONTENT_TYPE" => "application/json" }

  #
  # Need to specify headers (to allow distinction between html and json responses
  #
  def get_bookmark(url=nil)
    url = "/bookmarks" if url.nil?
    get url, nil, HTTP_HDR
  end

  alias_method  :get_bookmarks, :get_bookmark

  def get_bookmark_sz
    get_bookmarks
    bkmk = JSON.parse(last_response.body)
    bkmk.size
  end

  def create_bookmark_entry(opt={url: "http://www.test.org",
                                 title: "Test", tags_as_str: []})
    post "/bookmarks", opt, HTTP_HDR
  end

  def update_bookmark_entry(id, body)
    put "/bookmarks/#{id}", body, HTTP_HDR
  end

  def new_bookmark_entry(opt={url: "http://www.test.org",
                              title: "Test", tags_as_str: []})
    create_bookmark_entry opt
    bkmk_uri = last_response.body
    #
    bkmk_uri.split("/").last         # return id, unless creation failed
  end

  def check_post_update(id)
    get_bookmark "/bookmarks/#{id}"
    expect(last_response.status).to eq(200)
    JSON.parse(last_response.body)   # return bookmark instance
  end

  #
  # Read
  #
  it "sends an error code when bookmark is non existent" do
    id = -99
    get_bookmark "/bookmarks/#{id}"
    expect(last_response.status).to eq(404)
  end

  #
  # Create bookmark
  #
  it "creates a new bookmark" do
    last_sz = get_bookmark_sz
    #
    create_bookmark_entry url: "http://undeadly.org/cgi", title: "OpenBSD news"
    # expect(last_response).to respond_with_content_type(:json)
    expect(last_response.status).to eq(201)
    expect(last_response.body).to match(/\/bookmarks\/\d+/)
    #
    new_sz = get_bookmark_sz
    expect(new_sz).to eq(last_sz + 1)
  end

  it "sends an error code when invalid create request" do
   create_bookmark_entry url: "test", title: "test" # == post
   expect(last_response.status).to eq(400)
  end

  #
  # Update existing bookmark
  #
  it "updates a bookmark title" do
    # first create an ad-hoc bookmark entry
    id = new_bookmark_entry(url: "http://www.update.org", title: "Update test")
    #
    # then update it:
    update_bookmark_entry id, { title: "Success" }
    expect(last_response.status).to eq(204)
    #
    # and check:
    bkmk = check_post_update(id)
    expect(bkmk["title"]).to eq("Success")
  end

  it "updates a bookmark tags" do
    new_tags = "yoopie, friday"
    id = new_bookmark_entry(url: "http://www.super.org", title: "update test",
                            tags_as_str: "awesome, madness, monday")
    expect(id).not_to be(nil)
    update_bookmark_entry id, {tags_as_str: new_tags}
    expect(last_response.status).to eq(204)
    #
    bkmk = check_post_update(id)
    expect(bkmk['tag_lst']).to eq(new_tags.split(",").map(&:strip).sort)
  end

  #
  # Update of non-existent res
  #
  it "sends an error code when updating non-existent bookmark" do
    id = -99  # no negative id
    get_bookmark "/bookmarks/#{id}"
    expect(last_response.status).to eq(404)
    update_bookmark_entry id, {:title => "Chaos"}
    expect(last_response.status).to eq(404)
  end

  #
  # Invalid Update
  #
  it "sends an error code for an invalid update request" do
    get_bookmarks
    bookmarks = JSON.parse(last_response.body)
    id = bookmarks.first['id']
    update_bookmark_entry id, {:url => "Invalid"}
    expect(last_response.status).to eq(400)
  end

  #
  # Delete
  #
  it "delete a bookmark entry" do
    # Prep.
    create_bookmark_entry url: "http://www.2.delete", title: "delete test"
    bkmk_uri = last_response.body
    id = bkmk_uri.split("/").last
    last_sz = get_bookmark_sz
    #
    # Deletion and expectation
    delete "/bookmarks/#{id}"
    expect(last_response.status).to eq(200)
    #
    # another check/expectation
    new_sz = get_bookmark_sz
    expect(new_sz).to eq(last_sz - 1)
  end

end
