require 'examples/user'

class Authenticate < Aktion::Base
  schema { required(:headers).hash { required(:email).filled(:string) } }

  def perform
    unless request[:current_user] = User.find_by(email: headers[:email])
      failure(:unauthorized)
    end
  end
end
