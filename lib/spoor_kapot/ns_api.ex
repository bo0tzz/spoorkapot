defmodule SpoorKapot.NsApi do
  # TODO: Keep this in persistent term storage maybe?
  def load_stations() do
    File.read!("stations.json")
    |> Jason.decode!()
    |> Map.get("payload")
    |> Enum.map(&SpoorKapot.NsApi.Station.new/1)
    |> Enum.map(fn %{code: code} = station -> {code, station} end)
    |> Enum.into(%{})
  end
end
