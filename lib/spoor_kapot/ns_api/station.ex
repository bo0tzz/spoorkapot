defmodule SpoorKapot.NsApi.Station do
  alias SpoorKapot.NsApi.Station
  defstruct [:code, :name, :normalized_name]

  def new(%{"code" => code, "namen" => %{"lang" => name}}) do
    %Station{
      code: code,
      name: name,
      normalized_name: Unicode.Transform.LatinAscii.transform(name)
    }
  end
end
