# frozen_string_literal: true

module Decidim
  module Initiatives
    class ApproveMembershipRequestEvent < Decidim::Events::SimpleEvent
<<<<<<< HEAD
      def email_subject
        I18n.t(
          "decidim.initiatives.events.approve_membership_request.email_subject",
          author_nickname:
        )
      end

      def email_intro
        I18n.t(
          "decidim.initiatives.events.approve_membership_request.email_intro",
=======
      def i18n_scope = "decidim.initiatives.events.approve_membership_request"

      def i18n_options
        {
          author_nickname:,
          author_profile_url:,
          participatory_space_title:,
          participatory_space_url:,
          resource_path:,
>>>>>>> tags/v0.29.1
          resource_title:,
          resource_url:,
          scope: i18n_scope
        }
      end

      private

      def author_nickname
        author.nickname
      end

      def author_profile_url
        author.profile_url
      end

      def author
        @author ||= Decidim::UserPresenter.new(
          Decidim::User.find(@extra["author"]["id"])
        )
      end
    end
  end
end
