module Aktion
  module Messages
    class Backend
      DEFAULT_TRANSLATIONS = { missing: 'is missing', invalid: 'invalid type' }

      def self.translations
        @translations || DEFAULT_TRANSLATIONS
      end

      def self.translate(value)
        if value.is_a?(Symbol)
          translations[value]
        elsif value.starts_with?('@')
          translations.dig(*value.split('.'))
        else
          value
        end
      end
    end
  end
end
