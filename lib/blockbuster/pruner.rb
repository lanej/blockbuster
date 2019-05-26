class Blockbuster::Pruner
  def self.call(*args, **kwargs)
    new(*args, **kwargs).prune
  end

  attr_reader :branches
  attr_reader :diff
  attr_reader :logger

  def initialize(branches, diff, logger: Logger.new(nil))
    @branches = branches
    @diff = diff
    @logger = logger
  end

  def prune
    branches.each do |branch|
      remaining = account.rentals_for(branch: branch) & branch

      if remaining.none?
        logger.debug "[pruner] #{branch.basename} cassettes have been completely revised"
        branch.delete
      end
    end
  end
end
