# -*- coding: utf-8 -*-

module ApplicationHelper

  def title(value = nil)
    @title = value if value
    @title ? "Controller Demo - #{@title}" : "Controller Demo"
  end

  # For view
  def find_template(views, name, engine, &block)
    Array(views).each do |v|
      super(v, name, engine, &block)
    end
  end

end
