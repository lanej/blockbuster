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
    branch.each do |entry|
      next unless entry.full_name == cassette.package_path

      cassette.open('w', binmode: true) { |cassette_io| IO.copy_stream(entry, cassette_io) }
      break
    end
  end
end
