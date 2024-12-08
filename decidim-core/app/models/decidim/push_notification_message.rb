# frozen_string_literal: true

module Decidim
<<<<<<< HEAD
  # A messsage from a conversation that will be sent as a push notification
=======
  # A message from a conversation that will be sent as a push notification
>>>>>>> tags/v0.29.1
  class PushNotificationMessage
    class InvalidActionError < StandardError; end

    include SanitizeHelper

    def initialize(recipient:, conversation:, message:)
      @recipient = recipient
      @conversation = conversation
      @message = message
    end

    attr_reader :recipient, :conversation, :message

    alias user recipient

    def body
      decidim_escape_translated(message)
    end

    def icon
      organization.attached_uploader(:favicon).variant_url(:big, host: organization.host)
    end

    def url
      EngineRouter.new("decidim", {}).public_send(:conversation_path, host: organization.host, id: @conversation)
    end

    private

    def organization
      @organization ||= recipient.organization
    end
  end
end
