# frozen_string_literal: true

require 'dry/matcher/result_matcher'

class ApplicationService
  extend Dry::Initializer
  include Dry::Monads[:result, :do]

  private_class_method :new

  def self.call(**options, &block)
    service_outcome = new(**options).call

    if block
      Dry::Matcher::ResultMatcher.call(service_outcome, &block)
    else
      service_outcome
    end
  end

  def call
    Failure(:not_implemented)
  end
end
