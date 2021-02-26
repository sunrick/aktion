module Aktion
  module Messages
    def self.backend=(value)
      @backend = BACKENDS[value]
    end

    def self.backend
      @backend ||= BACKENDS[:hash]
    end

    class Hash
      DEFAULT_TRANSLATIONS = { missing: 'is missing', invalid: 'invalid type' }

      def self.translations
        @translations || DEFAULT_TRANSLATIONS
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
          ::I18n.t(value)
        elsif value.sub!(/^@/, '')
          ::I18n.t(value)
        else
          value
        end
      end
    end
  end

  BACKENDS = { hash: Aktion::Messages::Hash, i18n: Aktion::Messages::I18n }
end
