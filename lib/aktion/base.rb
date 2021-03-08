require 'aktion/errors'
require 'aktion/request'
require 'aktion/validations'
require 'aktion/contract'

module Aktion
  class Base
    STATUSES = {
      continue: 100,
      switching_protocols: 101,
      processing: 102,
      early_hints: 103,
      ok: 200,
      created: 201,
      accepted: 202,
      non_authoritative_information: 203,
      no_content: 204,
      reset_content: 205,
      partial_content: 206,
      multi_status: 207,
      already_reported: 208,
      im_used: 226,
      multiple_choices: 300,
      moved_permanently: 301,
      found: 302,
      see_other: 303,
      not_modified: 304,
      use_proxy: 305,
      "(unused)": 306,
      temporary_redirect: 307,
      permanent_redirect: 308,
      bad_request: 400,
      unauthorized: 401,
      payment_required: 402,
      forbidden: 403,
      not_found: 404,
      method_not_allowed: 405,
      not_acceptable: 406,
      proxy_authentication_required: 407,
      request_timeout: 408,
      conflict: 409,
      gone: 410,
      length_required: 411,
      precondition_failed: 412,
      payload_too_large: 413,
      uri_too_long: 414,
      unsupported_media_type: 415,
      range_not_satisfiable: 416,
      expectation_failed: 417,
      misdirected_request: 421,
      unprocessable_entity: 422,
      locked: 423,
      failed_dependency: 424,
      too_early: 425,
      upgrade_required: 426,
      precondition_required: 428,
      too_many_requests: 429,
      request_header_fields_too_large: 431,
      unavailable_for_legal_reasons: 451,
      internal_server_error: 500,
      not_implemented: 501,
      bad_gateway: 502,
      service_unavailable: 503,
      gateway_timeout: 504,
      http_version_not_supported: 505,
      variant_also_negotiates: 506,
      insufficient_storage: 507,
      loop_detected: 508,
      bandwidth_limit_exceeded: 509,
      not_extended: 510,
      network_authentication_required: 511
    }.freeze

    def self.contract(&block)
      if block_given?
        @contract = Contract.build(&block)
      else
        @contract ||= Contract.new
      end
    end

    def self.request(&block)
      contract.request(&block)
    end

    def self.validations(&block)
      contract.validations(&block)
    end

    def self.perform(request = {}, options = {})
      instance = new(request, options)

      @contract&.call(instance.request, instance.errors)

      if instance.errors?
        instance.respond(:unprocessable_entity)
      else
        begin
          instance.perform
        rescue Aktion::PerformRespond => e
          instance = e.instance
        end
      end

      instance
    end

    def self.readers(*args)
      args.each do |arg|
        define_method arg do
          request[arg]
        end
      end
    end

    attr_accessor :request, :options, :errors, :status, :body

    def initialize(request, options)
      self.request = request
      self.options = options
    end

    def perform; end

    def errors
      @errors ||= Errors.new
    end

    def errors?
      @errors&.present?
    end

    def success?
      code = STATUSES[self.status]
      code.between?(100, 399) ? true : false
    end

    def failure?
      !success?
    end

    def errors?
      errors.present?
    end

    def respond(status = nil, object = nil)
      self.status = status if status
      self.body = object if object
    end

    def respond!(status = nil, object = nil)
      respond(status, object)
      raise Aktion::PerformRespond, self
    end

    def error(key, message)
      errors.add(key, message)
    end

    def error!(key, message)
      error(key, message)
      raise Aktion::PerformRespond, self
    end

    def response
      [status, body]
    end

    def status
      if @status
        @status
      elsif errors?
        @status = :unprocessable_entity
      end
    end

    def body
      if @body
        @body
      elsif errors?
        @body = errors.to_h
      end
    end

    def run(klass, payload = nil)
      instance = klass.perform(payload || request)
      instance.success? ? instance : raise(Aktion::PerformRespond, instance)
    end
  end
end
