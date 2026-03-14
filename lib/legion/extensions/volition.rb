# frozen_string_literal: true

require 'legion/extensions/volition/version'
require 'legion/extensions/volition/helpers/constants'
require 'legion/extensions/volition/helpers/intention'
require 'legion/extensions/volition/helpers/intention_stack'
require 'legion/extensions/volition/helpers/drive_synthesizer'
require 'legion/extensions/volition/runners/volition'
require 'legion/extensions/volition/client'

module Legion
  module Extensions
    module Volition
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
