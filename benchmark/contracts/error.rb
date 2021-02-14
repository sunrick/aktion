errors = Aktion::Errors.new
error = Aktion::Error.build('profile.image.name', 'missing name') { value.nil? }

params = { profile: { image: { name: nil } } }
Bench.perform do
  ips { |x| x.report('error') { error } }

  profile(__FILE__) { error.call(params, errors) }
end
