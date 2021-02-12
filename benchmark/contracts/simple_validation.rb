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
      required(:age).filled(:integer)
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

Bench.perform do
  ips do |x|
    x.report('active-model') do
      user = User.new(params)
      user.validate
    end
    x.report('dry-validation') { dry.call(params) }
    x.report('aktion-request') { aktion.call(params) }
    x.compare!
  end

  profile(__FILE__) { aktion.call(params) }
end
