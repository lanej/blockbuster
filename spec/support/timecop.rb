require 'timecop'

RSpec.configure do |config|
  config.before(:each) { Timecop.scale(600) }
end
