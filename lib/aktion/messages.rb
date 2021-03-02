module Aktion
  module Messages
    def self.backend=(value)
      @backend = BACKENDS[value]
    end

    def self.backend
      @backend ||= BACKENDS[Aktion.config.backend || :hash]
    end

    class Hash
      def self.translations
        @translations ||= { missing: 'is missing', invalid: 'invalid type' }
      end

      def self.translate(value)
        if value.is_a?(Symbol)
          translations[value]
        elsif value.sub!(/^@/, '')
          translations.dig(*value.split('.'))
        else
          value
        end
      end
    end

    class I18n
      def self.translate(value)
        if value.is_a?(Symbol)
          ::I18n.t("aktion.#{value}")
        elsif value.sub!(/^@/, '')
          ::I18n.t("aktion.#{value}")
        else
          value
        end
      end
    end
  end

  BACKENDS = { hash: Aktion::Messages::Hash, i18n: Aktion::Messages::I18n }
end
