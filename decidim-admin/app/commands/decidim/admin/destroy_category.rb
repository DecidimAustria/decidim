# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a category in the
    # system.
    class DestroyCategory < Decidim::Commands::DestroyResource
      protected

<<<<<<< HEAD
      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the data was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if category.nil? || category.subcategories.any? || !category.unused?

        destroy_category
        broadcast(:ok)
      end

      private

      attr_reader :category

      def destroy_category
        Decidim.traceability.perform_action!(:delete, category, @user) do
          category.destroy!
        end
=======
      def invalid?
        resource.nil? || resource.subcategories.any? || !resource.unused?
>>>>>>> tags/v0.29.1
      end
    end
  end
end
