RSpec::Matchers.define :insert do |*cassettes|
  match do |branch|
    expected = cassettes.each_with_object({}) do |cassette, versions|
      versions[cassette.name] = Digest::MD5.file(cassette)
    end

    actual = {}

    branch.rental do
      actual = cassettes.each_with_object({}) do |cassette, versions|
        versions[cassette.name] = Digest::MD5.file(branch.cassettes.get(cassette.name))
      end
    end

    expect(expected).to eq(actual)
  end
end
