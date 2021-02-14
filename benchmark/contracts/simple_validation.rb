class User
  include ActiveModel::Validations

  attr_reader :email, :age

  validates :email, :age, presence: true
  validates :age, numericality: { greater_than: 18 }

  def initialize(attrs)
    @email, @age = attrs.values_at('email', 'age')
  end
end

dry =
  Dry::Validation::Contract.build do
    params do
      required(:email).filled(:string)
      optional(:age).filled(:integer)
    end

    rule(:age) { key.failure('must be greater than 18') if values[:age] <= 18 }
  end

aktion =
  Aktion::Contract.build do
    request do
      required :email, :string
      required :age, :integer
    end

    validations { error(:age, 'must be greater than 18') { value <= 18 } }
  end

params = { email: 'rickard@aktion.gem', age: 18 }
invalid_params = { email: 'rickard@aktion.gem', age: nil }
too_young_params = { email: 'rickard@aktion.gem', age: 9 }

Bench.perform(__FILE__) do
  ips do |x|
    x.report('active-model') do
      user = User.new(params)
      user.validate
    end
    x.report('dry-validation') { dry.call(params) }
    x.report('aktion-request') { aktion.call(params) }

    x.report('active-model-invalid') do
      user = User.new(invalid_params)
      user.validate
    end
    x.report('dry-validation-invalid') { dry.call(invalid_params) }
    x.report('aktion-request-invalid') { aktion.call(invalid_params) }

    x.report('active-model-too-young') do
      user = User.new(too_young_params)
      user.validate
    end
    x.report('dry-validation-too-young') { dry.call(too_young_params) }
    x.report('aktion-request-too-young') { aktion.call(too_young_params) }

    x.report('active-model-too-young-errors') do
      user = User.new(too_young_params)
      user.validate
      user.errors
    end
    x.report('dry-validation-too-young-errors') do
      dry.call(too_young_params).errors
    end
    x.report('aktion-request-too-young-errors') do
      aktion.call(too_young_params)[:errors].to_h
    end

    x.compare!
  end

  profile { aktion.call(params) }
end
