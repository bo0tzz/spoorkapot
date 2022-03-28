defmodule SpoorKapot.StationSearch do
  @stations SpoorKapot.NsApi.load_stations()
  @seqfuzz_opts [
    sort: true,
    filter: true,
    metadata: false
  ]

  def find_stations(query) do
    normalized_query = Unicode.Transform.LatinAscii.transform(query)
    Seqfuzz.matches(@stations, normalized_query, &elem(&1, 0), @seqfuzz_opts)
  end
end
