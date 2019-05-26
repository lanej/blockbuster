# Collection of branchs in a given directory
class Blockbuster::Cassettes
  include Enumerable
  extend Forwardable

  EXTENSION = '.yml'.freeze
  GLOB = "**/*#{EXTENSION}".freeze

  def_delegators :to_a, :last, :first, :inspect, :empty?

  attr_reader :directory

  def initialize(directory:, logger: _)
    @directory = directory
  end

  def get(name)
    Blockbuster::Cassette.for(File.join(directory, name + EXTENSION), directory: directory)
  end

  def each
    return to_enum unless block_given?

    directory.glob(GLOB).each { |file| yield Blockbuster::Cassette.for(file, directory: directory) }
  end
end
