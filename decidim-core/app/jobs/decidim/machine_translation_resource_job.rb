# frozen_string_literal: true

module Decidim
  # This job is part of the machine translation flow. This one is fired every
  # time a `Decidim::TranslatableResource` is created or updated. If any of the
  # attributes defines as translatable is modified, then for each of those
  # attributes this job will schedule a `Decidim::MachineTranslationFieldsJob`.
  class MachineTranslationResourceJob < ApplicationJob
    queue_as :translations

    # rubocop: disable Metrics/CyclomaticComplexity

    # Performs the job.
    #
    # resource - Any kind of `Decidim::TranslatableResource` model instance
    # previous_changes - A Hash with the set fo changes. This is intended to be
    #   taken from `resource.previous_changes`, but we need to manually pass
    #   them to the job because the value gets lost when serializing the
    #   resource.
    # source_locale - A Symbol representing the source locale for the translation
    def perform(resource, previous_changes, source_locale)
      return unless Decidim.machine_translation_service_klass

      @resource = resource
      @locales_to_be_translated = []
      translatable_fields = @resource.class.translatable_fields_list.map(&:to_s)
      translatable_fields.each do |field|
        next unless @resource[field].is_a?(Hash) && previous_changes.keys.include?(field)

        translated_locales = translated_locales_list(field)
        remove_duplicate_translations(field, translated_locales) if @resource[field]["machine_translations"].present?

        next unless source_locale_value_changed_or_translation_removed(previous_changes, field, source_locale)

        @locales_to_be_translated += pending_locales(translated_locales) if @locales_to_be_translated.blank?

        @locales_to_be_translated.each do |target_locale|
          Decidim::MachineTranslationFieldsJob.perform_later(
            @resource,
            field,
            resource_field_value(
              previous_changes,
              field,
              source_locale
            ),
            target_locale,
            source_locale
          )
        end
      end
    end
    # rubocop: enable Metrics/CyclomaticComplexity

    def source_locale_value_changed_or_translation_removed(previous_changes, field, source_locale)
      #default_locale = default_locale(@resource) || source_locale
      values = previous_changes[field]
      old_value = values.first
      new_value = values.last

      return true unless old_value.is_a?(Hash)

      return true if old_value[source_locale] != new_value[source_locale]

      # In a case where the default locale isn't changed
      # but a translation of a different locale is deleted
      # We trigger a job to translate only for that locale
      if old_value[source_locale] == new_value[source_locale]
        locales_present = old_value.keys
        locales_present.each do |locale|
          @locales_to_be_translated << locale if old_value[locale] != new_value[locale] && new_value[locale] == ""
        end
      end

      @locales_to_be_translated.present?
    end

    def resource_field_value(previous_changes, field, source_locale)
      values = previous_changes[field]
      new_value = values.last
      if new_value.is_a?(Hash)
        locale = source_locale || default_locale(@resource)
        return new_value[locale]
      end

      new_value
    end

    def default_locale(resource)
      # TODO: This does not work for resources that are not scoped to an organization
      if resource.is_a?(Decidim::Organization)
        resource.default_locale.to_s
      elsif resource.respond_to? :organization
        resource.organization.default_locale.to_s
      else
        # TODO: For multi-tenancy, we need to find out the organization for the resource!
        #Decidim.available_locales.first.to_s
        # Don't return anything if we can't find the default locale
        nil
      end
    end

    def translated_locales_list(field)
      return nil unless @resource[field].is_a? Hash

      translated_locales = []
      existing_locales = @resource[field].keys - ["machine_translations"]
      existing_locales.each do |locale|
        translated_locales << locale if @resource[field][locale].present?
      end

      translated_locales
    end

    def remove_duplicate_translations(field, translated_locales)
      machine_translated_locale = @resource[field]["machine_translations"].keys
      unless (translated_locales & machine_translated_locale).nil?
        (translated_locales & machine_translated_locale).each { |key| @resource[field]["machine_translations"].delete key }
      end
    end

    def pending_locales(translated_locales)
      # TODO: This does not work for resources that are not scoped to an organization
      organization = @resource if @resource.is_a?(Decidim::Organization)
      organization ||= @resource.organization if @resource.respond_to? :organization
      available_locales = organization.available_locales.map(&:to_s) if organization.present?
      # TODO: For multi-tenancy, we need to find out the organization for the resource!
      # At the moment we translate to all available locales of the platform
      available_locales ||= Decidim.available_locales.map(&:to_s)
      available_locales - translated_locales
    end
  end
end
