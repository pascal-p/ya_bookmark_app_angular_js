require_relative "../main"

require "rspec"
require "rack/test"


#
# spec_helper.rb - Only 1 syntax, the new one
#
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


describe "bookmark app" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  #
  # internal helpers

  HTTP_HDR = { "HTTP_ACCEPT" => "application/json",
               "HTTP_CONTENT_TYPE" => "application/json" } 
  
  #
  # Need to specify headers (to allow distinction between html and json responses
  #
  def get_bookmark(url=nil)
    url = "/bookmarks"  if url.nil?
    get url, nil, HTTP_HDR
  end
  
  def get_bookmark_sz
    get_bookmark
    bkmk = JSON.parse(last_response.body)
    bkmk.size
  end

  def create_bookmark_entry(url="http://www.test.org", title="Test")
    post "/bookmarks", {'url' => url, 'title' =>  title} 
  end
  
  def update_bookmark_entry(id, body)
    put "/bookmarks/#{id}", body, HTTP_HDR
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
    create_bookmark_entry "http://undeadly.org/cgi", "OpenBSD news"
    # expect(last_response).to respond_with_content_type(:json)
    expect(last_response.status).to eq(201)
    expect(last_response.body).to match(/\/bookmarks\/\d+/)
    #
    new_sz = get_bookmark_sz
    expect(new_sz).to eq(last_sz + 1)
  end

  it "sends an error code when invalid create request" do
    create_bookmark_entry "test", "test" # == post 
    expect(last_response.status).to eq(400)
  end
  
  #
  # Update existing bookmark
  #
  it "updates a bookmark" do
    # first create an ad-hoc bookmark entry
    create_bookmark_entry "http://www.2.update", "update test"
    bkmk_uri = last_response.body
    id = bkmk_uri.split("/").last
    #
    # then update it
    update_bookmark_entry id, { title: "Success" } # , url: "http://www.2.update" }
    expect(last_response.status).to eq(204)
    #
    # and check
    get_bookmark "/bookmarks/#{id}"
    expect(last_response.status).to eq(200)
    retrieved_bkmk = JSON.parse(last_response.body)
    expect(retrieved_bkmk["title"]).to eq("Success")
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
    get_bookmark
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
    create_bookmark_entry "http://www.2.delete", "delete test" 
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
