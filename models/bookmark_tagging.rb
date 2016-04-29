# -*- coding: utf-8 -*-

class BookmarkTagging
  include DataMapper::Resource

  belongs_to :tag, :key => true
  belongs_to :bookmark, :key => true
end
