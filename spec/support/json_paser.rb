# frozen_string_literal: true

module JsonParser
  def json_body
    JSON.parse(response.body).deep_symbolize_keys
  end
end

RSpec.configure do |config|
  config.include JsonParser, type: :controller
end
