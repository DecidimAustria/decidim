# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to import a collection of proposals
      # from a participatory text written in a rich text editor.
      class ImportEditorParticipatoryTextForm < Decidim::Form
        include TranslatableAttributes

        # WARNING: consider adding/removing the relative translation key at
        # decidim.assemblies.admin.new_import.accepted_types when modifying this hash
        ACCEPTED_MIME_TYPES = Decidim::Proposals::DocToMarkdown::ACCEPTED_MIME_TYPES

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :content

        validates :title, translatable_presence: true
        validates :content, presence: true, if: :new_participatory_text?

        # Assume it's a NEW participatory_text if there are no proposals
        # Validate content presence while CREATING proposals from content
        # Allow skipping content validation while UPDATING title/description
        def new_participatory_text?
          Decidim::Proposals::Proposal.where(component: current_component).blank?
        end

        def default_locale
          current_participatory_space.organization.default_locale
        end
      end
    end
  end
end
