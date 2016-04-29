#
# spec_helper.rb - Only 1 syntax, the new one
#

require "rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
