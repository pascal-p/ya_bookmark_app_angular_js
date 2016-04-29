# -*- coding: utf-8 -*-

class Tag
  include DataMapper::Resource

  property :id, Serial
  property :label, String, :required => true

  has n, :bookmark_taggings
  has n, :bookmarks, :through => :bookmark_taggings, :order => [:title.asc]
end
