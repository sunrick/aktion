require 'spec_helper'

param = Aktion::V3::Param::Array.build(:dogs, :array) { required :string }
errors = Aktion::V3::Errors.new
result = param.call({ dogs: ['bjorn'] }, errors)

binding.pry
