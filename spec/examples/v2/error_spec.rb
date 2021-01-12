require 'spec_helper'

# TODO: Arrays
RSpec.describe Aktion::V2::Error do
  context '.call' do
    let(:subject) { error.call(params) }

    shared_examples :string_presence_tests do
      context 'name is present' do
        let(:params) { Hash[name: 'Rickard'] }

        specify { expect(subject).to eq(false) }
      end

      context 'name is missing' do
        let(:params) { Hash[name: nil] }

        specify { expect(subject).to eq(name: ['is missing']) }
      end
    end

    context 'with method passing' do
      let(:error) { described_class.build(:name, 'is missing', :nil?) }

      include_examples :string_presence_tests
    end

    context 'with simple blocks' do
      context '{}' do
        let(:error) do
          described_class.build(:name, 'is missing') { value.nil? }
        end

        include_examples :string_presence_tests
      end

      context 'do end' do
        let(:error) do
          described_class.build :name, 'is missing' do
            value.nil?
          end
        end

        include_examples :string_presence_tests
      end
    end

    context 'with message method' do
      context 'with value' do
        let(:error) do
          described_class.build :name do
            message('is missing') if value.nil?
          end
        end

        include_examples :string_presence_tests
      end

      context 'with context' do
        let(:error) do
          described_class.build :name do
            message('is missing') if params[:name].nil?
          end
        end

        include_examples :string_presence_tests
      end

      context 'with default key' do
        let(:error) do
          described_class.build do
            message(:name, 'is missing') if params[:name].nil?
          end
        end

        include_examples :string_presence_tests
      end

      context 'with missing key for message' do
        let(:error) do
          described_class.build { message('is missing') if value.nil? }
        end

        let(:params) { Hash[name: nil] }

        specify do
          expect { subject }.to raise_error(Aktion::V2::Errors::MissingKey)
        end
      end

      context 'with missing message' do
        let(:error) { described_class.build(:name) { message if value.nil? } }

        let(:params) { Hash[name: nil] }

        specify do
          expect { subject }.to raise_error(Aktion::V2::Errors::MissingMessage)
        end
      end
    end

    context 'with multiple messages' do
      let(:error) do
        described_class.build :name do
          message('is missing') if value.nil?
          message('must be Rickard') if value != 'Rickard'
        end
      end

      context 'name is valid' do
        let(:params) { Hash[name: 'Rickard'] }

        specify { expect(subject).to eq(false) }
      end

      context 'name is invalid' do
        let(:params) { Hash[name: 'John'] }

        specify { expect(subject).to eq(name: ['must be Rickard']) }
      end

      context 'name is missing' do
        let(:params) { Hash[name: nil] }

        specify do
          expect(subject).to eq(name: ['is missing', 'must be Rickard'])
        end
      end
    end

    context 'with multiple keys' do
      let(:error) do
        described_class.build do
          message(:name, 'is missing') if params[:name].nil?
          message(:age, 'must be greater than 0') if params[:age] <= 0
        end
      end

      context 'both are valid' do
        let(:params) { Hash[name: 'Rickard', age: 30] }

        specify { expect(subject).to eq(false) }
      end

      context 'both are invalid' do
        let(:params) { Hash[name: nil, age: 0] }

        specify do
          expect(subject).to eq(
            name: ['is missing'],
            age: ['must be greater than 0']
          )
        end
      end

      context 'only age is valid' do
        let(:params) { Hash[name: nil, age: 30] }

        specify { expect(subject).to eq(name: ['is missing']) }
      end

      context 'only name is valid' do
        let(:params) { Hash[name: 'Rickard', age: 0] }

        specify { expect(subject).to eq(age: ['must be greater than 0']) }
      end
    end

    context 'with nested keys' do
      context 'same key multiple messages' do
        let(:error) do
          described_class.build do
            if params.dig(:options, :name).nil?
              message('options.name', 'is missing')
            end
            if params.dig(:options, :name) != 'Rickard'
              message('options.name', 'must be Rickard')
            end
          end
        end

        context 'name is valid' do
          let(:params) { Hash[options: { name: 'Rickard' }] }

          specify { expect(subject).to eq(false) }
        end

        context 'name is invalid' do
          let(:params) { Hash[options: { name: 'John' }] }

          specify do
            expect(subject).to eq(options: { name: ['must be Rickard'] })
          end
        end

        context 'name is missing' do
          let(:params) { Hash[options: { name: nil }] }

          specify do
            expect(subject).to eq(
              options: { name: ['is missing', 'must be Rickard'] }
            )
          end
        end
      end

      context 'different keys' do
        let(:error) do
          described_class.build do
            name = params.dig(:options, :name)
            message('options.name', 'is missing') if name.nil?
            message('options.name', 'must be Rickard') if name != 'Rickard'
            if params.dig(:options, :age) <= 0
              message('options.age', 'must be greater than 0')
            end
          end
        end

        context 'both are valid' do
          let(:params) { Hash[options: { name: 'Rickard', age: 30 }] }

          specify { expect(subject).to eq(false) }
        end

        context 'both are invalid' do
          let(:params) { Hash[options: { name: nil, age: 0 }] }

          specify do
            expect(subject).to eq(
              options: {
                name: ['is missing', 'must be Rickard'],
                age: ['must be greater than 0']
              }
            )
          end
        end

        context 'only age is valid' do
          let(:params) { Hash[options: { name: nil, age: 30 }] }

          specify do
            expect(subject).to eq(
              options: { name: ['is missing', 'must be Rickard'] }
            )
          end
        end

        context 'only name is valid' do
          let(:params) { Hash[options: { name: 'Rickard', age: 0 }] }

          specify do
            expect(subject).to eq(options: { age: ['must be greater than 0'] })
          end
        end
      end
    end
  end
end
