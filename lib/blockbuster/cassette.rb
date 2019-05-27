class Blockbuster::Cassette < Pathname
  def self.for(filename, directory:)
    new(filename).tap { |cassette| cassette.send(:cassettes_path=, directory) }
  end

  attr_reader :cassettes_path

  def relative_path
    Pathname.new(self).relative_path_from(cassettes_path)
  end

  def name
    relative_path.to_s.sub(extname, '')
  end

  def inspect
    File.join(cassettes_path.parent.basename.to_s, relative_path.to_s)
  end

  private

  attr_writer :cassettes_path
end
