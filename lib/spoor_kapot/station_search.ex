defmodule SpoorKapot.StationSearch do
  @stations SpoorKapot.NsApi.load_stations()
  @seqfuzz_opts [
    sort: true,
    filter: true,
    metadata: false
  ]

  def find_stations(""), do: []

  def find_stations(query) do
    normalized_query = Unicode.Transform.LatinAscii.transform(query)

    Map.values(@stations)
    |> Seqfuzz.matches(normalized_query, & &1.normalized_name, @seqfuzz_opts)
  end

  def stations(), do: @stations
end
