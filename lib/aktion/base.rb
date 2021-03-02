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
        instance.failure(:unprocessable_entity)
      else
        begin
          instance.perform
        rescue Aktion::PerformRespond => e
          instance = e.instance
        end
      end

      instance
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

    def success(status, object)
      @success = true
      self.status = status
      self.body = object
    end

    def success!(status, object)
      success(status, object)
      raise Aktion::PerformSuccess.new(self)
    end

    def success?
      code = STATUSES[self.status]
      code.between?(100, 399) ? true : false
    end

    def failure?
      !success?
    end

    def failure(status, object = nil)
      self.status = status
      self.body = object if object
    end

    def failure!(status, object)
      failure(status, object)
      raise Aktion::PerformRespond, self
    end

    def errors?
      errors.present?
    end

    def error(key, message)
      @failure = true
      self.status = :unprocessable_entity
      errors.add(key, message)
    end

    def error!(key, message)
      error(key, message)
      raise Aktion::PerformRespond, self
    end

    def respond(status = nil, object = nil, success = nil)
      self.status = status if status
      self.body = object if object

      @success = sucesss if success
      @failure = !success unless success.nil?
    end

    def respond!(status = nil, object = nil, success = nil)
      respond(status, object, success)
      raise Aktion::PerformRespond, self
    end

    def response
      [status, body]
    end

    def body
      errors? ? errors.to_h : @body
    end

    def run(klass, payload = nil)
      instance = klass.perform(payload || request)
      instance.success? ? instance : raise(Aktion::PerformRespond, instance)
    end
  end
end
