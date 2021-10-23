# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A command with all the business logic when a user destroys a draft proposal.
      class DestroyProposal < Rectify::Command
        # Public: Initializes the command.
        #
        # proposal     - The proposal to destroy.
        def initialize(proposal)
          @proposal = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid and the proposal is deleted.
        # - :invalid if the proposal is not a draft.
        # - :invalid if the proposal's author is not the current user.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @proposal.draft?

          @proposal.destroy!

          broadcast(:ok, @proposal)
        end
      end
    end
  end
end
