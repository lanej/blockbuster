RSpec::Matchers.define :have_cassettes do |cassettes|
  match do |branch|
    expect(blockbuster.cassettes_for(branch)).to contain_exactly(*cassettes)
  end
end
