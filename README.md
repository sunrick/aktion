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

#### Simple and Intuitive API

```ruby
# app/actions/users/create.rb
class Users::Create < Aktion::Base
  request { required :name, :string }

  def perform
    @user = User.new(name: request[:name])
    if @user.save
      respond :created, user: @user
    else
      respond :unprocessable_entity, @user.errors.messages
    end
  end
end
```

```ruby
action = Users::Create.perform(name: 'Rickard')
action.success? # => true
action.response # => [:created, user: <User name: 'Rickard'>]
action.status # => :created
action.body # => { user: <User name: 'Rickard'> }
```

```ruby
RSpec.describe Users::Create do
  let(:action) { described_class.perform(request) }

  context 'good request' do
    let(:request) { { name: 'Rickard' } }

    it 'should save the user' do
      expect { action }.to change { User.count }.by(1)
      expect(action.response).to eq([:created, user: User.first])
    end
  end

  context 'bad request' do
    let(:request) { { name: '' } }

    it 'should fail' do
      expect(action.response).to eq(
        [:unprocessable_entity, name: ['is missing']],
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

Rails.application.routes.draw { resources :users, only: [:create] }
```

```
bundle exec aktion g users create
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
