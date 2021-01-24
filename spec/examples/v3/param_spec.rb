require 'spec_helper'

RSpec.describe Aktion::V3::Params do
  let(:result) { builder.call(params) }
  let(:subject) { result[:errors].to_h }

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

            context 'no elements are valid' do
              let(:params) { { dogs: ['', nil, 2, {}, []] } }
              it do
                is_expected.to eq(
                  dogs: {
                    "0": MISSING,
                    "1": MISSING,
                    "2": INVALID_TYPE,
                    "3": INVALID_TYPE,
                    "4": INVALID_TYPE
                  }
                )
              end
            end
          end
        end
      end

      context 'hash' do
        let(:builder) do
          described_class.build do
            required :email, :string
            optional :license_number, :integer
            optional :library_number, :integer
            required :apple_id, :integer

            required :profile, :hash do
              optional :images, :array do
                optional :file_name, :string
                required :file_type, :string
              end
            end

            required :dogs, :array do
              required :name, :string
              required :age, :integer
              required :favorite_foods, :array do
                required :string
              end
              required :favorite_toys, :array
              required :favorite_places, :array do
                optional :name, :string
                optional :location, :string
              end
            end
          end
        end

        let(:params) do
          {
            email: 'rickard@aktion.io',
            license_number: 1,
            library_number: 1,
            apple_id: 1,
            profile: { images: [{ file_name: 'dog', file_type: '.jpg' }] },
            dogs: [
              {
                name: 'Bjorn',
                age: 8,
                favorite_foods: ['chicken'],
                favorite_toys: ['none'],
                favorite_places: [{ name: 'dog bed', location: 'apartment' }]
              }
            ]
          }
        end

        specify do
          expect(result[:test]).to eq(params)
          expect(subject).to eq({})
        end
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
