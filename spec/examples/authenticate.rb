require 'examples/user'

class Authenticate < Aktion::HTTP
  schema do
    required(:headers).hash do
      required(:email).filled(:string)
    end
  end

  def perform
    failure(:unauthorized) unless request[:current_user] = User.find_by(email: headers[:email])
  end
end