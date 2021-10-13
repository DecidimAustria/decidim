# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    class AmendmentCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::SanitizeHelper

      def show
        render
      end

      private

      def emendation
        model.emendation
      end

      def emendation_authors
        model.emendation.authors
      end

      def emendation_excerpt
        truncate(decidim_sanitize(translated_attribute(model.emendation.body), strip_tags: true), length: 200)
      end

      def created_at
        I18n.l model.created_at, format: :long
      end

      def compare_emendation_path
        compare_proposal_path(model.emendation)
      end
    end
  end
end
