require 'tmpdir'
require 'pathname'

class SupportBlockbuster
  extend Forwardable

  def self.debug?
    ENV['DEBUG'] == '1'
  end

  attr_reader :branches
  attr_reader :configuration
  attr_reader :directory
  attr_reader :name
  attr_reader :logger

  def_delegators :manager, :cassettes, :branches, :rentals
  def_delegators :configuration, :cassettes_path, :branches_path

  def initialize(name: 'master', configuration: Blockbuster::Configuration.new)
    yield configuration if block_given?

    @forks = []
    @name = name
    @configuration = configuration
    @logger =
      configuration.logger =
        Logger.new(
          debug? ? STDOUT : nil
        ).tap do |logger|
          logger.level = Logger::DEBUG
          logger.formatter = ->(sev, datetime, _, msg) {
            "[#{datetime.to_i}] #{sev.to_s.rjust(5, ' ')} : #{msg}\n"
          }
        end
  end

  def setup(scaffold: false)
    @directory = Pathname.new(Dir.mktmpdir(name))

    configuration.cassettes_path = File.join(directory, configuration.cassettes_path)
    configuration.branches_path = File.join(directory, configuration.branches_path)

    if scaffold
      configuration.cassettes_path.mkpath
      configuration.branches_path.mkpath
    end
  end

  def teardown
    ([self] + @forks.to_a).each { |d| d.directory.rmtree }
  end

  def branch(name:)
    copy = self.class.new(
      name: name,
      configuration: configuration.clone,
    ) do |config|
      config.current_branch = name
      config.cassettes_path = configuration.cassettes_path.relative_path_from(directory)
      config.branches_path = configuration.branches_path.relative_path_from(directory)
    end

    @forks << copy

    copy.setup
    FileUtils.cp_r(directory.children, copy.directory, verbose: debug?)

    yield copy if block_given?
    copy
  end

  def merge(store_location)
    logger.debug "[support] merging #{store_location.name} into #{name}"

    cassettes_path.mkpath
    branches_path.mkpath

    FileUtils.cp_r(store_location.cassettes_path.children, cassettes_path, verbose: debug?)
    FileUtils.cp_r(store_location.branches_path.children, branches_path, verbose: debug?)
    self
  end

  def manager
    Blockbuster::Manager.new(configuration: configuration)
  end

  def rental
    manager.tap do |rental_manager|
      rental_manager.rent
      yield(rental_manager).tap do
        rental_manager.drop_off
      end
    end
  end

  def tree(output: STDOUT)
    walk(directory) do |node, depth|
      label = node.basename.to_s +
        (node.directory? ? "/" : "[#{Digest::MD5.file(node).to_s[0..7]}]")

      print ' ' * depth
      output.puts label
    end
  end

  def walk(node, depth: 0, &block)
    return to_enum(node, depth: depth) unless block_given?

    yield node, depth

    if node.directory?
      depth += 1
      node.children.each { |leaf| walk(leaf, depth: depth, &block) }
    end
  end

  private

  def debug?
    self.class.debug?
  end
end
