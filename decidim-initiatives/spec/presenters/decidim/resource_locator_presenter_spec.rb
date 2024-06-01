# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceLocatorPresenter, type: :helper do
    it_behaves_like "generates routes without query strings on slug" do
      let(:route_fragment) { "initiatives/#{participatory_space.slug}" }
      let(:admin_route_fragment) { "initiatives/#{participatory_space.slug}" }
      let(:factory_name) { :initiative }
    end
  end
end
