# Aktion

This was a library I was working on for a while.

I wanted to see what it was like to try to shove single class based actions into Rails. I think the API I ended up with is pretty elegant.

I haven't had time to work on it more but I'd like to clean this up and actually release it as a gem in the future.

For now I'm leaving it up here to showcase some WIP code that I have.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aktion'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aktion

## Usage

### Main objectives

- Simple and intuitive API
- Self Documenting
- Easy to test
- Use anywhere (Good enough)
- Opt in performance enhancements

#### Simple and Intuitive API

```ruby
# app/actions/users/create.rb
class Users::Create < Aktion::Base
  attr_accessor :user

  schema do
    required(:params).hash do
      required(:email).filled
    end
  end

  def perform
    self.user = User.new(email: params[:email])
    if user.save
      success(:created, user)
    else
      failure(:unprocessable_entity, user.errors.messages)
    end
  end
end
```

```ruby
RSpec.describe Users::Create do
  let(:args) do
    {
      params: { email: 'sunrick@aktion.gem' }
    }
  end

  context 'good request' do
    it 'should save the user' do
      action = described_class.perform(args)
      expect(action.success?).to eq(true)
      expect(action.response).to eq(
        json: { email: 'sunrick@aktion.gem' },
        status: :created
      )
      expect(User.count).to eq(1)
    end
  end

  context 'bad request' do
    before { args[:params][:email] = '' }

    it 'should fail' do
      action = described_class.perform(args)
      expect(action.failure?).to eq(true)
      expect(action.response).to eq(
        json: errors: { email: ['missing'] },
        status: :unprocessable_entity
      )
      expect(User.count).to eq(0)
    end
  end
end
```

```ruby
class ApplicationController
  include Aktion::Controller
end

class UsersController < ApplicationController
  aktions [:create]
end

Rails.application.routes.draw do
  resources :users, only: [:create]
end
```

```ruby
Users::Create.perform(
  params:  { email: 'sunrick@aktion.gem' },
  options: { async: true }
)
```

```
bundle exec aktion g users:create
bundle exec aktion g users:index,create,show,update,destroy
bundle exec aktion g users
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aktion. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Aktion project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/aktion/blob/master/CODE_OF_CONDUCT.md).
