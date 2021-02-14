RSpec.describe Aktion::Types::Any do
  MISSING = 'is missing'
  INVALID = 'invalid type'
  NIL = nil
  class Dog; end
  dog = Dog.new

  context '.call' do
    [
      [nil, nil, MISSING],
      ['', '', nil],
      ['a', 'a', nil],
      [1, 1, nil],
      [1.12, 1.12, nil],
      [BigDecimal('1.55'), BigDecimal('1.55'), nil],
      [Date.parse('2021-01-01'), Date.parse('2021-01-01'), nil],
      [DateTime.parse('2021-01-01'), Date.parse('2021-01-01'), nil],
      [Time.parse('2021-01-01'), Time.parse('2021-01-01'), nil],
      [true, true, nil],
      [false, false, nil],
      [dog, dog, nil],
      [{}, {}, nil],
      [{ a: 1 }, { a: 1 }, nil],
      [[], [], nil],
      [[1], [1], nil],
      ['true', 'true', nil],
      ['false', 'false', nil]
    ].each do |input, output, message|
      specify { expect(described_class.call(input)).to eq([output, message]) }
    end
  end
end
