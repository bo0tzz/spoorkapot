defmodule SpoorKapot.StationSearch do
  @seqfuzz_opts [
    sort: true,
    filter: true,
    metadata: false
  ]

  def find_stations(""), do: []

  def find_stations(query) do
    normalized_query = Unicode.Transform.LatinAscii.transform(query)

    SpoorKapot.NsApi.stations()
    |> Enum.map(&elem(&1, 1))
    |> Seqfuzz.matches(normalized_query, & &1.normalized_name, @seqfuzz_opts)
  end
end
