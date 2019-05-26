# Data store for files, sources, states, and checksums
class Blockbuster::Rentals
  extend Forwardable

  HashsumProbe = Class.new do
    def self.digest(cassette)
      Digest::MD5.file(cassette)
    end
  end

  MtimeProbe = Class.new do
    def self.digest(cassette)
      cassette.mtime.to_i
    end
  end

  attr_reader :cassettes
  attr_reader :logger
  attr_reader :probe

  def_delegators :cassettes, :any?

  def initialize(logger: Logger.new(nil))
    @logger = logger

    @probe = MtimeProbe
    @cassettes = {}
  end

  def choose(rental)
    previous_rental, previous_rental_digest = cassettes[rental.cassette]

    # FIXME: use Probe#<=>":W
    if previous_rental_digest && digest(rental.stat) <= previous_rental_digest
      logger.debug do
        "[rentals] #{rental.branch} " \
          " has older #{rental.cassette.relative_path}" \
          " (#{previous_rental_digest} < #{digest(rental.stat)})"
      end
      return
    end

    if previous_rental_digest
      logger.debug do
        "[rentals] #{rental.branch} " \
          "has newer #{rental.cassette.relative_path} " \
          "than #{previous_rental.branch.basename} " \
          "(#{previous_rental_digest} < #{digest(rental.stat)})"
      end
    else
      logger.debug { "[rentals] #{rental.branch} renting #{rental.cassette.relative_path}" }
    end

    cassettes[rental.cassette] = [rental, digest(rental.stat)]
  end

  def insert
    cassettes.each { |_, (rental, _)| rental.insert }
  end

  def watch(selection)
    Blockbuster::Account.take(selection, rentals: self)
  end

  def digest(cassette)
    probe.digest(cassette)
  end
end
