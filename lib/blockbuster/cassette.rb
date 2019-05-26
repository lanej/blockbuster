class Blockbuster::Cassette < Pathname
  def self.for(filename, directory:)
    new(filename).tap do |cassette|
      cassette.send(:package_path=, Pathname.new(cassette).relative_path_from(directory.parent))
      cassette.send(:relative_path=, Pathname.new(cassette).relative_path_from(directory))
    end
  end

  attr_reader :relative_path
  attr_reader :package_path

  def name
    basename.to_s.sub(extname, '')
  end

  def inspect
    super + "[#{mtime.to_i}]"
  end

  private

  attr_writer :package_path
  attr_writer :relative_path
end
