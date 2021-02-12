class DowncaseAction < Aktion::Base
  def perform
    success :ok, name: request[:name].downcase
  end
end
