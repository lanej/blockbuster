module Blockbuster::CassetteArchive
  extend Forwardable

  Stat = Struct.new(:mode, :mtime)

  def_delegators :pathname, :open, :exist?

  attr_reader :pathname

  def initialize(pathname)
    @pathname = pathname
  end

  def read(cassette)
    raise NotImplementedError
  end

  def write(cassettes)
    raise NotImplementedError
  end

  def each_cassette(cassettes_path)
    raise NotImplementedError
  end

  def each_cassette_with_stat(cassettes_path)
    raise NotImplementedError
  end
end
