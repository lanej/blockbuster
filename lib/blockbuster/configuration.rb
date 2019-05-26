# Manages blockbuster configuration
class Blockbuster::Configuration
  # user
  VERBOSE = false
  DEFAULT_BRANCHES_PATH = 'blockbuster'.freeze
  DEFAULT_BRANCH = 'master'.freeze

  # vcr
  DEFAULT_CASSETTES_PATH = 'cassettes'.freeze

  def branch
    @branch ||= DEFAULT_BRANCH
  end
  attr_writer :branch

  alias current_branch branch
  alias current_branch= branch=

  def cassettes_path
    @cassettes_path ||= Pathname.new(DEFAULT_CASSETTES_PATH)
  end

  def cassettes_path=(cassettes_path)
    @cassettes_path = Pathname.new(cassettes_path)
  end

  def logger
    @logger ||= Logger.new(nil)
  end
  attr_writer :logger

  def branches_path
    @branches_path ||= Pathname.new(DEFAULT_BRANCHES_PATH)
  end

  def branches_path=(branches_path)
    @branches_path = Pathname.new(branches_path)
  end
end
