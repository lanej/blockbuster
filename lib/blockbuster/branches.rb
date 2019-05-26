class Blockbuster::Branches
  include Enumerable
  extend Forwardable

  def_delegators :to_a, :last, :first, :empty?, :to_set

  attr_reader :cassettes_path
  attr_reader :directory

  def initialize(directory:, cassettes_path:, logger: Logger.new(nil))
    @directory = directory
    @cassettes_path = cassettes_path
    @logger = logger
  end

  def rent
    flat_map do |branch|
      branch.map do |entry|
        next unless entry.file?

        cassette = Blockbuster::Cassette.for(
          cassettes_path.dirname.join(entry.full_name),
          directory: cassettes_path,
        )

        Blockbuster::Rental.new(branch: branch, stat: entry.header, cassette: cassette)
      end
    end
  end

  def each
    return to_enum unless block_given?

    directory.
      glob(Blockbuster::Branch.glob).
      each do |pathname|
      yield Blockbuster::Branch.load(pathname, directory: directory, cassettes_path: cassettes_path)
    end
  end

  def get(name)
    select { |d| d.name == name }
  end

  protected

  attr_reader :logger
end
