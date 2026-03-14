# frozen_string_literal: true

require 'legion/extensions/volition/helpers/constants'
require 'legion/extensions/volition/helpers/intention'
require 'legion/extensions/volition/helpers/intention_stack'
require 'legion/extensions/volition/helpers/drive_synthesizer'
require 'legion/extensions/volition/runners/volition'

module Legion
  module Extensions
    module Volition
      class Client
        include Runners::Volition

        attr_reader :intention_stack

        def initialize(stack: nil, **)
          @intention_stack = stack || Helpers::IntentionStack.new
        end
      end
    end
  end
end
