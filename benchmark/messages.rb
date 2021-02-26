Aktion::Messages::Backend.translations.merge(
  'yomomma' => { 'fat' => 'yo momma so fat, she on both sides of the family' }
)

Bench.perform(__FILE__) do
  ips do |x|
    x.report('key') { Aktion::Messages::Backend.translate(:missing) }
    x.report('@key') { Aktion::Messages::Backend.translate('@yomomma.fat') }
    x.report('message') do
      Aktion::Messages::Backend.translate('random message')
    end
  end
end
