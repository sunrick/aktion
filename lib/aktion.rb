require 'aktion/version'
require 'aktion/messages'
require 'aktion/types'
require 'aktion/base'
require 'aktion/rails'
require 'aktion/controller'

module Aktion
  class PerformSuccess < StandardError
    attr_accessor :instance

    def initialize(instance)
      self.instance = instance
    end
  end

  class PerformFailure < StandardError
    attr_accessor :instance

    def initialize(instance)
      self.instance = instance
    end
  end
end
