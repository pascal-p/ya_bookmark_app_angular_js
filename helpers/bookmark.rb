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
    labels = (params["tagsAsString"] || "").split(",").map(&:strip)     # get the tags
    #
    # Next, by iterating over the bookmark’s previously existing tags, we compare
    # with the new list of tags. We’ll keep track of matching tags and delete those
    # that previously existed but were not sent in the current request.
    #
    exist_labels = bookmark.bookmark_taggings.inject([]) do |ary, bktagging|
      if labels.include?(bktagging.tag.label)
        ary.push bktagging.tag.label
      else
        bktagging.destroy
        ary
      end
    end
    #
    #
    (labels - exist_labels).each do |label|
      tag = {:label => label}
      existing = Tag.first tag
      existing = Tag.create tag unless existing
      BookmarkTagging.create :tag => existing, :bookmark => bookmark
    end
  end

end
