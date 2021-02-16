module TypesSpec
  MISSING = 'is missing'
  INVALID = 'invalid type'
  OK = nil

  class StringChild < String; end
  class Object < Object; end
end

RSpec.describe Aktion::Types::Any do
  context '.call' do
    [
      [nil, nil, TypesSpec::MISSING],
      ['', '', TypesSpec::OK],
      ['a', 'a', TypesSpec::OK],
      [1, 1, TypesSpec::OK],
      ['1', '1', TypesSpec::OK],
      [1.12, 1.12, TypesSpec::OK],
      ['1.12', '1.12', TypesSpec::OK],
      [BigDecimal('1.55'), BigDecimal('1.55'), TypesSpec::OK],
      [Date.parse('2021-01-01'), Date.parse('2021-01-01'), TypesSpec::OK],
      [DateTime.parse('2021-01-01'), Date.parse('2021-01-01'), TypesSpec::OK],
      [Time.parse('2021-01-01'), Time.parse('2021-01-01'), TypesSpec::OK],
      [true, true, TypesSpec::OK],
      [false, false, TypesSpec::OK],
      [{}, {}, TypesSpec::OK],
      [{ a: 1 }, { a: 1 }, TypesSpec::OK],
      [[], [], TypesSpec::OK],
      [[1], [1], TypesSpec::OK],
      ['true', 'true', TypesSpec::OK],
      ['false', 'false', TypesSpec::OK]
    ].each do |input, output, message|
      specify { expect(described_class.call(input)).to eq([output, message]) }
    end
  end
end

RSpec.describe Aktion::Types::String do
  context '.call' do
    [
      [nil, nil, TypesSpec::MISSING],
      ['', '', TypesSpec::MISSING],
      ['a', 'a', TypesSpec::OK],
      [
        TypesSpec::StringChild.new('dog'),
        TypesSpec::StringChild.new('dog'),
        TypesSpec::OK
      ],
      ['1', '1', TypesSpec::OK],
      [1, 1, TypesSpec::INVALID],
      [1.12, 1.12, TypesSpec::INVALID],
      ['1.12', '1.12', TypesSpec::OK],
      [BigDecimal('1.55'), BigDecimal('1.55'), TypesSpec::INVALID],
      [Date.parse('2021-01-01'), Date.parse('2021-01-01'), TypesSpec::INVALID],
      [
        DateTime.parse('2021-01-01'),
        Date.parse('2021-01-01'),
        TypesSpec::INVALID
      ],
      [Time.parse('2021-01-01'), Time.parse('2021-01-01'), TypesSpec::INVALID],
      [true, true, TypesSpec::INVALID],
      [false, false, TypesSpec::INVALID],
      [{}, {}, TypesSpec::INVALID],
      [{ a: 1 }, { a: 1 }, TypesSpec::INVALID],
      [[], [], TypesSpec::INVALID],
      [[1], [1], TypesSpec::INVALID],
      ['true', 'true', nil],
      ['false', 'false', nil]
    ].each do |input, output, message|
      specify { expect(described_class.call(input)).to eq([output, message]) }
    end
  end
end

RSpec.describe Aktion::Types::Integer do
  context '.call' do
    [
      [nil, nil, TypesSpec::MISSING],
      ['', '', TypesSpec::INVALID],
      ['a', 'a', TypesSpec::INVALID],
      ['1', 1, TypesSpec::OK],
      [1, 1, TypesSpec::OK],
      [1.12, 1, TypesSpec::OK],
      ['1.12', '1.12', TypesSpec::INVALID],
      [BigDecimal('1.55'), 1, TypesSpec::OK],
      [Date.parse('2021-01-01'), Date.parse('2021-01-01'), TypesSpec::INVALID],
      [
        DateTime.parse('2021-01-01'),
        Date.parse('2021-01-01'),
        TypesSpec::INVALID
      ],
      [Time.parse('2021-01-01'), Time.parse('2021-01-01'), TypesSpec::INVALID],
      [true, true, TypesSpec::INVALID],
      [false, false, TypesSpec::INVALID],
      [{}, {}, TypesSpec::INVALID],
      [{ a: 1 }, { a: 1 }, TypesSpec::INVALID],
      [[], [], TypesSpec::INVALID],
      [[1], [1], TypesSpec::INVALID],
      ['true', 'true', TypesSpec::INVALID],
      ['false', 'false', TypesSpec::INVALID]
    ].each do |input, output, message|
      specify { expect(described_class.call(input)).to eq([output, message]) }
    end
  end
end
