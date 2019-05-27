class Blockbuster::Manager
  attr_reader :branches
  attr_reader :cassettes
  attr_reader :configuration

  def initialize(configuration: Blockbuster::Configuration.new)
    yield configuration if block_given?

    @configuration = configuration

    @branches = Blockbuster::Branches.new(directory: configuration.branches_path,
                                          cassettes_path: configuration.cassettes_path,
                                          logger: configuration.logger)
    @rentals = Blockbuster::Rentals.new(logger: configuration.logger)
    @cassettes = Blockbuster::Cassettes.new(directory: configuration.cassettes_path,
                                            logger: configuration.logger)
  end

  def rent
    branches.rent.each { |rental| rentals.choose(rental) }

    # FIXME: only purchase what is inserted
    rentals.insert
  end

  def drop_off
    configuration.branches_path.mkpath

    watched = rentals.watch(selection)

    Blockbuster::Packager.call(branches, watched,
                               next_branch: next_branch,
                               logger: configuration.logger)
    # if branches.count > 1
    #   Blockbuster::Pruner.call(branches, watched,
    #                            logger: configuration.logger)
    # end
  end

  alias setup rent
  alias teardown drop_off

  protected

  attr_reader :rentals

  # FIXME: don't always watch all cassettes
  def selection
    cassettes.to_a
  end

  def next_branch
    Blockbuster::Branch.build(
      cassettes_path: configuration.cassettes_path,
      directory: configuration.branches_path,
      extname: configuration.archive_extname,
      name: configuration.branch,
      time: Time.now,
    )
  end
end
