class Blockbuster::Packager
  extend Forwardable

  def self.call(*args, **kwargs)
    new(*args, ** kwargs).package
  end

  def_delegators :account, :additions, :modifications, :deletions, :updates?

  attr_reader :account
  attr_reader :branches
  attr_reader :next_branch
  attr_reader :logger

  def initialize(branches, account, next_branch:, logger: Logger.new(nil))
    @logger = logger
    @account = account
    @branches = branches
    @next_branch = next_branch
  end

  def package
    logger.info { account.to_diff }
    remove_older_branches
    create_next_branch
  end

  protected

  def older_branches
    branches.select { |b| b.name == next_branch.name }
  end

  def current_files
    Set.new(older_branches.flat_map(&:cassettes))
  end

  def branch_cassettes
    (Set.new(additions) + current_files + modifications) - Set.new(deletions)
  end

  def remove_older_branches
    if additions.none? && modifications.none? && branch_cassettes.any?
      logger.info "[packager] will not remove #{next_branch}"
      return
    end

    logger.info "[packager] removing #{older_branches}"
    older_branches.each { |d| d.delete if d.exist? }
  end

  def create_next_branch
    package_files = branch_cassettes

    if !(package_files.any? && updates?)
      logger.info "[packager] will not package #{next_branch.name}"
      return
    end

    logger.info do
      "[packager] writing #{next_branch.name} branch " \
                  "with #{package_files.map(&:relative_path).map(&:to_s)}"
    end

    next_branch.write(package_files)
  end
end
