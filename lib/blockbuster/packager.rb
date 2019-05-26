class Blockbuster::Packager
  extend Forwardable

  def self.call(*args, **kwargs)
    new(*args, ** kwargs).package
  end

  def_delegators :audit, :additions, :modifications, :deletions, :updates?

  attr_reader :audit
  attr_reader :branches
  attr_reader :next_branch
  attr_reader :logger

  def initialize(branches, audit, next_branch:, logger: Logger.new(nil))
    @logger = logger
    @audit = audit
    @branches = branches
    @next_branch = next_branch
  end

  def older_branches
    branches.select { |b| b.name == next_branch.name }
  end

  def current_files
    Set.new(older_branches.flat_map(&:cassettes))
  end

  def branch_cassettes
    (Set.new(additions) + current_files + modifications) - Set.new(deletions)
  end

  def package
    logger.info { audit.to_diff }
    remove_older_branches
    write_next_branch
  end

  def remove_older_branches
    if additions.none? && modifications.none? && branch_cassettes.any?
      logger.info "[packager] will not remove #{next_branch}"
      return
    end

    logger.info "[packager] removing #{older_branches}"
    older_branches.each { |d| d.delete if d.exist? }
  end

  def write_next_branch
    package_files = branch_cassettes

    if !(package_files.any? && updates?)
      logger.info "[packager] will not package #{next_branch.name}"
      return
    end

    logger.info "[packager] writing #{next_branch.name} branch with #{package_files.map(&:relative_path).map(&:to_s)}"
    write(package_files)
  end

  def write(cassettes)
    next_branch.open('w', binmode: true) do |file|
      Zlib::GzipWriter.wrap(file) do |gz|
        Blockbuster::TarWriter.new(gz) do |tar|
          cassettes.each do |cassette|
            cassette.open(File::RDONLY, binmode: true) do |cassette_io|
              tar.add(file: cassette, path: cassette.package_path) do |package_io|
                IO.copy_stream(cassette_io, package_io)
              end
            end
          end
        end
      end
    end
  end
end
