# Manages blockbuster configuration
class Blockbuster::Configuration
  # user
  VERBOSE = false
  DEFAULT_BRANCHES_PATH = 'blockbuster'.freeze
  DEFAULT_BRANCH = 'master'.freeze
  DEFAULT_ARCHIVER = :tar

  # vcr
  DEFAULT_CASSETTES_PATH = 'cassettes'.freeze

  ARCHIVER_MAP = {
    tar: Blockbuster::Archive::TAR_EXTNAME,
    zip: Blockbuster::Archive::ZIP_EXTNAME,
  }.freeze

  attr_writer :branch

  def branches_path=(branches_path)
    @branches_path = Pathname.new(branches_path)
  end

  alias current_branch= branch=

  def cassettes_path=(cassettes_path)
    @cassettes_path = Pathname.new(cassettes_path)
  end

  attr_writer :archiver
  attr_writer :logger

  def branch
    @branch ||= DEFAULT_BRANCH
  end

  def cassettes_path
    @cassettes_path ||= Pathname.new(DEFAULT_CASSETTES_PATH)
  end

  alias current_branch branch

  def archiver
    @archiver ||= DEFAULT_ARCHIVER
  end

  def archive_extname
    ARCHIVER_MAP.fetch(archiver)
  end

  def logger
    @logger ||= Logger.new(nil)
  end

  def branches_path
    @branches_path ||= Pathname.new(DEFAULT_BRANCHES_PATH)
  end
end
