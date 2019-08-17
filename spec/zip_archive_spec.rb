RSpec.describe Blockbuster::ZipArchive do
  subject(:archive) { described_class.new(branch) }

  let(:cassette) do
    Blockbuster::Cassette.for(
      blockbuster.cassettes_path.join('a.yml'),
      directory: blockbuster.cassettes_path,
    ).tap { |c| c.write 'foo' }
  end
  let(:blockbuster) { SupportBlockbuster.new }
  let(:branch) { Pathname.new(File.join(blockbuster.branches_path, 'test')) }

  before { blockbuster.setup(scaffold: true) }

  after { blockbuster.teardown }

  context 'after write' do
    subject(:write) { archive.write([cassette]) }

    before { write }

    specify do
      expect(archive.each_cassette(blockbuster.cassettes_path)).
        to contain_exactly(cassette)
    end

    specify do
      expect(archive.each_cassette_with_stat(blockbuster.cassettes_path)).
        to contain_exactly([cassette, duck_type(:mode, :mtime)])
    end

    specify do
      expect { |b| archive.read(cassette, &b) }.to yield_with_args(duck_type(:read))
    end
  end
end
