require 'aktion/version'
require 'aktion/configuration'
require 'aktion/messages'
require 'aktion/types'
require 'aktion/base'
require 'aktion/rails'
require 'aktion/controller'

module Aktion
  def self.config(&block)
    if block_given?
      @config = yield(Configuration.new)
    else
      @config ||= Configuration.new
    end
  end

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
