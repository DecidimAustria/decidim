# frozen_string_literal: true

require "webmock/rspec"

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [
    %r{https://validator\.w3\.org/},
    Decidim::Dev::Test::MapServer.host
  ]
)
