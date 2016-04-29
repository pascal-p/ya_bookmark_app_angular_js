# -*- coding: utf-8 -*-

class Bookmark
  include DataMapper::Resource

  property :id, Serial
  property :url, String,      :required => true, :format => :url
  property :title, String,    :required => true
  property :created_at, Time, :default => Time.now

  # Add tag support
  has n, :bookmark_taggings, :constraint => :destroy
  has n, :tags, :through => :bookmark_taggings, :order => [:label.asc]

  def tag_lst
    tags.collect {|tag| tag.label}
  end
end
