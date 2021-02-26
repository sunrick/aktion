Aktion::Messages::Hash.translations.merge(
  'momma' => { 'fat' => 'yo momma so fat, she on both sides of the family' }
)

Bench.perform(__FILE__) do
  ips do |x|
    x.report('hash.key') { Aktion::Messages::Hash.translate(:missing) }
    x.report('hash.@key') { Aktion::Messages::Hash.translate('@momma.fat') }
    x.report('hash.message') do
      Aktion::Messages::Hash.translate('random message')
    end

    x.report('i18n.key') { Aktion::Messages::I18n.translate(:missing) }
    x.report('i18n.@key') { Aktion::Messages::I18n.translate('@yomomma.fat') }
    x.report('i18n.message') do
      Aktion::Messages::I18n.translate('random message')
    end
  end
end
