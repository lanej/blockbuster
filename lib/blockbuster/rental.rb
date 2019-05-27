class Blockbuster::Rental
  extend Forwardable

  attr_reader :branch
  attr_reader :stat
  attr_reader :cassette

  def initialize(branch:, stat:, cassette:)
    @branch = branch
    @stat = stat
    @cassette = cassette
  end

  def insert
    FileUtils.mkdir_p(cassette.dirname)
    write_cassette

    File.chmod(stat.mode, cassette)
    FileUtils.touch(cassette, mtime: stat.mtime)
  end

  protected

  def write_cassette
    branch.read(cassette) do |entry|
      cassette.open('w', binmode: true) do |cassette_io|
        IO.copy_stream(entry, cassette_io)
      end
    end
  end
end
