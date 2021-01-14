class Downcase < Aktion::V3::Base
  params { required :name, :string }

  def perform
    success :ok, name: params[:name].downcase
  end
end
