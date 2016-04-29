# -*- coding: utf-8 -*-

#
# Below using the all method from DataMapper
#
def get_all_bookmarks
  Bookmark.all(:order => :title)
end

def hslice(params, *wl)
  STDOUT.print("\n>> #{wl.inspect}\n") if $DEBUG
  l = wl.inject({}) {|hr, key| hr.merge(key => params[key])}
  STDOUT.print(">>>> #{l.inspect}\n") if $DEBUG
  l
end

# view and controller helpers
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  before "/bookmarks/:id" do
    id = params['id']
    STDOUT.print("\n==> found id to be: [#{id.inspect}] // params: #{params.inspect}\n")
    @bookmark = Bookmark.get(id)
    
    if !@bookmark
      halt 404, "bookmark #{id} not found"
    end
  end

  def add_tags(bookmark)
    #
    # get the tags
    labels = (params["tagsAsString"] || "").split(",").map(&:strip)
    #
    # Next, by iterating over the bookmark’s previously existing tags, we compare
    # with the new list of tags. We’ll keep track of matching tags and delete those
    # that previously existed but were not sent in the current request.
    #
    exist_labels = bookmark.bkmk_taggings.inject([]) do |ary, bkmk_tagging|
      if labels.include?(bkmk_tagging.tag.label)
        ary.push bkmk_tagging.tag.label
      else
        bkmk_tagging.destroy
        ary
      end        
    end
    #
    #
    (labels - exist_labels).each do |label|
      tag = {:label => label}
      existing = Tag.first tag
      if !existing
        existing = Tag.create tag
      end
      BkmkTagging.create :tag => existing, :bookmark => bookmark
    end
  end
 
end

