# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying a component from the admin panel.
    class DestroyComponent < Decidim::Commands::DestroyResource
      private

      def run_before_hooks
<<<<<<< HEAD
        Decidim::Reminder.where(component: @component).destroy_all
        @component.manifest.run_hooks(:before_destroy, @component)
=======
        Decidim::Reminder.where(component: resource).destroy_all
        resource.manifest.run_hooks(:before_destroy, resource)
>>>>>>> tags/v0.29.1
      end

      def run_after_hooks
        resource.manifest.run_hooks(:destroy, resource)
      end
    end
  end
end
