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

  def stations() do
    ensure_loaded()

    Pockets.to_stream(:stations)
  end

  def station(code) do
    ensure_loaded()

    Pockets.get(:stations, code)
  end

  def ensure_loaded() do
    case Pockets.size(:stations) do
      :undefined ->
        Pockets.Registry.unregister(:stations)
        true

      0 ->
        true

      _ ->
        false
    end
    |> if(do: load_stations())
  end

  defp load_stations() do
    Pockets.new(:stations)

    {:ok, %{body: stations}} = SpoorKapot.NsApi.client() |> Tesla.get("/v2/stations")

    map =
      stations["payload"]
      |> Enum.map(&SpoorKapot.NsApi.Station.new/1)
      |> Enum.map(fn %{code: code} = station -> {code, station} end)
      |> Enum.into(%{})

    Pockets.merge(:stations, map)
  end
end
