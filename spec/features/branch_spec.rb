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
        feature_branch.rental { insert_cassette(feature_cassette, modify: true) }
      end

      context 'when merged to master' do
        subject(:next_rental) { master.rental { insert_cassette(master_cassette) } }

        before { master.merge(feature_branch) }

        specify { expect(master).to insert(feature_cassette) }
        specify { expect { next_rental }.not_to change { master.branches.to_a } }
        specify { expect { next_rental }.not_to change { master.cassettes.to_a } }
      end

      context 'and creates a new cassette' do
        let(:new_feature_cassette) { feature_branch.cassettes.get('feature') }

        before { feature_branch.rental { insert_cassette(new_feature_cassette) } }

        context 'when merged to master' do
          subject(:next_rental) do
            master.rental do
              insert_cassette(master_cassette)
              insert_cassette(master.cassettes.get(new_feature_cassette.name))
            end
          end

          before { master.merge(feature_branch) }

          specify { expect(master).to insert(feature_cassette, new_feature_cassette) }
          specify { expect { next_rental }.not_to change { master.branches.to_a } }
          specify { expect { next_rental }.not_to change { master.cassettes.to_a } }
        end
      end
    end
  end
end
