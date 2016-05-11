#
# spec_helper.rb - Only 1 syntax, the new one
#

require "rspec"
require 'rack/test'

require 'data_mapper'
# require 'dm-migrations'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods

  conf.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
