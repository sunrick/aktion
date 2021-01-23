require 'spec_helper'

RSpec.describe Aktion::V3::Params do
  let(:subject) { builder.call(params)[:errors].to_h }

  EMPTY = 'is missing'
  MISSING = 'is missing'
  INVALID_TYPE = 'invalid type'

  context 'array' do
    context 'without children' do
      context 'required' do
        let(:builder) { described_class.build { required :dogs, :array } }

        context 'empty array' do
          let(:params) { { dogs: [] } }
          it { is_expected.to eq(dogs: EMPTY) }
        end

        context 'present array' do
          context 'elements are all present' do
            let(:params) { { dogs: ['Bjorn'] } }
            it { is_expected.to eq({}) }
          end

          context 'some elements are present' do
            let(:params) { { dogs: ['Bjorn', '', nil, 'Sven', {}, []] } }
            it { is_expected.to eq({}) }
          end

          context 'no elements are present' do
            let(:params) { { dogs: ['', nil, {}, []] } }
            it { is_expected.to eq({}) }
          end
        end
      end

      context 'optional' do
        let(:builder) { described_class.build { optional :dogs, :array } }

        context 'empty array' do
          let(:params) { { dogs: [] } }
          it { is_expected.to eq({}) }
        end

        context 'present array' do
          context 'elements are all present' do
            let(:params) { { dogs: ['Bjorn'] } }
            it { is_expected.to eq({}) }
          end

          context 'some elements are present' do
            let(:params) { { dogs: ['Bjorn', '', nil, 'Sven', {}, []] } }
            it { is_expected.to eq({}) }
          end

          context 'no elements are present' do
            let(:params) { { dogs: ['', nil, {}, []] } }
            it { is_expected.to eq({}) }
          end
        end
      end
    end

    context 'with required children' do
      context 'no key' do
        context 'string' do
          let(:builder) do
            described_class.build do
              required :dogs, :array do
                required :string
              end
            end
          end

          context 'empty array' do
            let(:params) { { dogs: [] } }
            it { is_expected.to eq(dogs: EMPTY) }
          end

          context 'present array' do
            context 'elements are all valid' do
              let(:params) { { dogs: %w[Bjorn Sven] } }
              it { is_expected.to eq({}) }
            end

            context 'some elements are valid' do
              let(:params) { { dogs: ['Bjorn', '', nil, 'Sven', {}, []] } }
              it do
                is_expected.to eq(
                  dogs: {
                    "1": MISSING,
                    "2": MISSING,
                    "4": INVALID_TYPE,
                    "5": INVALID_TYPE
                  }
                )
              end
            end

            context 'no elements are present' do
              let(:params) { { dogs: ['', nil, {}, []] } }
              # it { is_expected.to eq({}) }
            end
          end
        end
      end

      context 'hash' do
      end

      context 'deeply nested' do
      end
    end

    context 'with optional children' do
    end

    context 'with the kitchen sink' do
    end
  end
end

#   let(:builder) do
#     described_class.build do
#       required :dogs, :array do
#         required :string
#       end
#     end
#   end
#   let(:params) { { dogs: [nil] } }

#   specify { expect(errors.to_h).to eq(dogs: { '0': 'is missing' }) }
# end

# context 'something' do
#   let(:builder) do
#     described_class.build do
#       required :dogs, :array do
#         required :name, :string
#       end
#     end
#   end
#   let(:params) { { dogs: [nil] } }

#   specify { expect(errors.to_h).to eq(dogs: { '0': 'is missing' }) }
# end

# context 'something' do
#   let(:builder) do
#     described_class.build do
#       required :dogs, :array do
#         required :name, :string
#         required :chicken, :hash do
#           required :name, :string
#           required :hobbies, :array
#         end
#       end
#     end
#   end

#   context 'array with nil' do
#     let(:params) { { dogs: [{ name: nil, chicken: {} }] } }

#     specify do
#       expect(errors.to_h).to eq(
#         dogs: { "0": { chicken: 'is missing', name: 'is missing' } },
#       )
#     end
#   end

#   context 'array with missing name' do
#     let(:params) do
#       {
#         dogs: [
#           { name: nil, chicken: { name: 'Chicken', hobbies: ['soccer'] } },
#         ],
#       }
#     end

#     specify do
#       expect(errors.to_h).to eq(dogs: { "0": { name: 'is missing' } })
#     end
#   end
# end
# end
