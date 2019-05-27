RSpec.describe 'blockbuster', type: :feature do
  subject { blockbuster.manager }

  let(:blockbuster) { SupportBlockbuster.new }

  before { blockbuster.setup }

  after { blockbuster.teardown }

  describe 'branches' do
    subject { blockbuster.branches }

    it { is_expected.to be_empty }
  end

  describe 'cassettes' do
    subject { blockbuster.cassettes }

    it { is_expected.to be_empty }
  end

  context 'when a rental creates a cassette' do
    subject(:rental) { blockbuster.rental { insert_cassette(cassette) } }

    let(:cassette) { blockbuster.cassettes.get('master') }

    specify { expect { rental }.to change { blockbuster.branches.count }.by(1) }
    specify { expect { rental }.to change { blockbuster.cassettes.to_a }.to([cassette]) }

    describe 'the branch' do
      subject(:branch) { blockbuster.branches.last }

      before { rental }

      specify { expect(branch.cassettes).to contain_exactly(cassette) }
    end

    context 'when next rented' do
      subject(:next_rental) { blockbuster.rental { insert_cassette(cassette) } }

      before { rental }

      specify { expect { next_rental }.not_to change { blockbuster.branches.to_a } }
      specify { expect { next_rental }.not_to change { blockbuster.cassettes.to_a } }
    end
  end

  context 'when rental modifies cassette' do
    subject(:rent_and_modify) { blockbuster.rental { insert_cassette(cassette, modify: true) } }

    let(:cassette) { blockbuster.cassettes.get('master') }

    before { blockbuster.rental { insert_cassette(cassette) } }

    specify { expect { rent_and_modify }.not_to change { blockbuster.branches.count } }
    specify { expect { rent_and_modify }.to change { blockbuster.branches.last } }
    specify { expect { rent_and_modify }.not_to change { blockbuster.cassettes.to_a } }
  end
end
