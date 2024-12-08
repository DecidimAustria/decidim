# frozen_string_literal: true

require "webmock/rspec"

<<<<<<< HEAD
WebMock.disable_net_connect!(allow_localhost: true, allow: %r{https://validator\.w3\.org/})
=======
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [
    %r{https://validator\.w3\.org/},
    Decidim::Dev::Test::MapServer.host
  ]
)
>>>>>>> tags/v0.29.1
