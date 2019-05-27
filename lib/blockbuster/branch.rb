class Blockbuster::Branch < Pathname
  include Enumerable
  extend Forwardable

  ENCODING = /^([0-9]+)_(\w+)\./
  # FIXME: this is not longer safe
  EXTENSION = '.tar.gz'.freeze

  def self.build(directory:, cassettes_path:, time:, name:, extname: EXTENSION)
    new(directory.join("#{time.to_i}_#{name}#{extname}")).tap do |branch|
      branch.send(:directory=, directory)
      branch.send(:cassettes_path=, cassettes_path)
    end
  end

  def self.load(pathname, directory:, cassettes_path:)
    new(pathname).tap do |branch|
      branch.send(:directory=, directory)
      branch.send(:cassettes_path=, cassettes_path)
    end
  end

  # FIXME: maybe compile a regex based on supported extnames
  def self.glob
    "*#{EXTENSION}"
  end

  def_delegators :to_a, :size
  def_delegators :archive, :read, :write, :each

  attr_reader :directory
  attr_reader :cassettes_path

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

  def extname
    basename.sub(/[^\.]+/, '').to_s
  end

  private

  def archive
    Blockbuster::Archive.for(self)
  end

  attr_writer :directory
  attr_writer :cassettes_path
end
