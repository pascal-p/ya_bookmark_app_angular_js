# -*- coding: utf-8 -*-

class Bookmark
  include DataMapper::Resource

  property :id, Serial
  property :url, String, :required => true, :format => :url
  property :title, String, :required => true
  property :created_at, Time, :default => Time.now

  # Add tag support
  has n, :bkmk_taggings, :constraint => :destroy
  has n, :tags, :through => :bkmk_taggings, :order => [:label.asc]

  def tag_lst
    tags.collect {|tag| tag.label}
  end
end

class BkmkTagging
  include DataMapper::Resource

  belongs_to :tag, :key => true
  belongs_to :bookmark, :key => true
end

class Tag
  include DataMapper::Resource

  property :id, Serial
  property :label, String, :required => true

  has n, :bkmk_taggings
  has n, :bookmarks, :through => :bkmk_taggings, :order => [:title.asc]
end
