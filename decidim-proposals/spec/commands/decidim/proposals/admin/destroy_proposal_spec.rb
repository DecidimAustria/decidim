# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe DestroyProposal do
        describe "call" do
          let(:current_component) do
            create(
              :proposal_component,
              participatory_space: create(:participatory_process)
            )
          end
          # let(:command) { described_class.new(current_component) }
          # let(:component) { create(:proposal_component) }
          let(:organization) { current_component.organization }
          let(:current_user) { create(:user, organization: organization) }
          # let(:other_user) { create(:user, organization: organization) }
          let!(:proposal) { create :proposal, component: current_component, users: [current_user] }
          let(:proposal_draft) { create(:proposal, :draft, component: current_component) }

          it "broadcasts ok and deletes the draft" do
            expect { described_class.new(proposal_draft).call }.to broadcast(:ok)
            expect { proposal_draft.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "broadcasts invalid when the proposal is not a draft" do
            expect { described_class.new(proposal).call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end