require_relative './aktion.rb'

class Downcase < Aktion
  param :name, :string, :required
  param :options, :hash, :optional do
    param :age, :integer, :required
  end

  error :name, :blank?
  error :name, 'is missing', :blank?
  error(:name, 'is missing') { v.blank? }
  error { message(:name, 'cannot be rickard') if context[:name] == 'Rickard' }
  error(:name) { add('cannot be rickard') if value.blank? }
  error :name do
    add('cannot be rickard') if context[:name] == 'Rickard'
  end
  error :options do
    add('options.age', 'is missing') if value.dig(:age).nil?
  end
  error 'options.age' do
  end
  error 'options.age.value' do
  end

  response :ok do
    field :name, :string
  end

  def perform
    success :ok, name: params[:name].downcase
  end
end

action = Downcase.perform(name: 'Rickard')

puts 'success' if action.success?
puts 'error' if action.errors?
