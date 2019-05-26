RSpec.describe 'blockbuster', type: :feature do
  subject { master.manager }

  let(:master) { SupportBlockbuster.new }

  before { master.setup }

  after { master.teardown }

  context 'with a new branch' do
    let(:feature_branch) { master.branch(name: 'feature') }

    context 'with a new cassette' do
      before { feature_branch.rental { insert_cassette(feature_cassette) } }

      let(:feature_cassette) { feature_branch.cassettes.get('feature_a') }

      context 'when merged to master' do
        subject(:next_rental) { master.rental { insert_cassette(feature_cassette) } }

        before { master.merge(feature_branch) }

        specify { expect { next_rental }.not_to change { master.branches.to_a } }
        specify { expect { next_rental }.not_to change { master.cassettes.to_a } }
      end
    end

    context 'when it modifies an existing cassette' do
      let(:master_cassette) { master.cassettes.get('master') }
      let(:feature_cassette) { feature_branch.cassettes.get('master') }

      before do
        master.rental { insert_cassette(master_cassette) }
        feature_branch.rental { modify_cassette(feature_cassette) }
      end

      context 'when merged to master' do
        subject(:next_rental) { master.rental { insert_cassette(master_cassette) } }

        before { master.merge(feature_branch) }

        specify { expect { next_rental }.not_to change { master.branches.to_a } }
        specify { expect { next_rental }.not_to change { master.cassettes.to_a } }
      end
    end
  end
end
