module SingleParam
  class User
    include ActiveModel::Validations

    attr_accessor :name

    validates :name, presence: true

    def initialize(name:)
      self.name = name
    end
  end

  dry =
    Dry::Validation::Contract.build do
      params { required(:name).filled(:string) }
    end

  aktion = Aktion::Contract.build { request { required :name, :string } }

  params = { name: 'Rickard' }

  Benchmark.ips do |x|
    x.report('active-model') do
      user = User.new(params)
      user.validate
    end
    x.report('dry-validation') { dry.call(params) }
    x.report('aktion-request') { aktion.call(params) }
    x.compare!
  end
end
