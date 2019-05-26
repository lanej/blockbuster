class Blockbuster::Branch < Pathname
  include Enumerable
  extend Forwardable

  ENCODING = /^([0-9]+)_(\w+)\./
  EXTENSION = '.tar.gz'.freeze

  def self.build(directory:, cassettes_path:, time:, name:)
    new(directory.join("#{time.to_i}_#{name}#{EXTENSION}")).tap do |branch|
      branch.send(:directory=, directory)
      branch.send(:cassettes_path=, cassettes_path)
    end
  end

  def self.load(pathname, directory:, cassettes_path:)
    new(pathname).tap do |branch|
      branch.send(:directory=, directory)
      branch.send(:cassettes_path=,  cassettes_path)
    end
  end

  def self.glob
    "*#{EXTENSION}"
  end

  def_delegators :to_a, :size

  attr_reader :directory
  attr_reader :cassettes_path

  def each
    return to_enum unless block_given?
    return unless exist?

    open(File::RDONLY, binmode: true) do |file|
      Zlib::GzipReader.wrap(file) do |gz|
        Gem::Package::TarReader.new(gz) do |tar|
          tar.each_entry do |entry|
            next unless entry.file?

            yield entry
          end
        end
      end
    end
  end

  def cassettes
    map do |entry|
      Blockbuster::Cassette.for(
        cassettes_path.dirname.join(entry.full_name),
        directory: cassettes_path,
      )
    end
  end

  def epoch_timestamp
    Integer(
      basename.to_s.match(ENCODING)[1],
    )
  end

  def timestamp
    Time.at(
      epoch_timestamp,
    )
  end

  def name
    basename.to_s.match(ENCODING)[2]
  end

  def to_human
    "#<#{self.class.name}:#{basename}[#{map(&:full_name).join(",")}]>"
  end

  def inspect
    "#<#{self.class.name}:#{basename}>"
  end

  private

  attr_writer :directory
  attr_writer :cassettes_path
end
