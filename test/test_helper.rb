$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'pry'
require 'timecop'
require 'blockbuster'

require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/setup'
require_relative 'support'

Timecop.scale(600)
