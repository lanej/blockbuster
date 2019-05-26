class Blockbuster::Account
  extend Forwardable

  def self.take(selection, rentals:)
    new(
      rentals: rentals,
      additions: selection.reject { |cassette| rentals.cassettes.key?(cassette) },
      deletions: rentals.cassettes.reject { |cassette, _| cassette.exist? }.keys,
      modifications: rentals.cassettes.select { |cassette, (rental, digest)|
        cassette.exist? && digest != rentals.digest(rental.cassette)
      }.keys,
    )
  end

  attr_reader :rentals
  attr_reader :additions
  attr_reader :modifications
  attr_reader :deletions

  def initialize(rentals:, additions:, modifications:, deletions:)
    @rentals = rentals
    @additions = additions
    @modifications = modifications
    @deletions = deletions
  end

  def updates?
    modifications.any? || additions.any?
  end

  def to_diff
    diff = []

    additions.each     { |a| diff << "\t+#{a}" }
    modifications.each { |a| diff << "\t~#{a}" }
    deletions.each     { |a| diff << "\t-#{a}" }

    diff.join("\n")
  end
end
