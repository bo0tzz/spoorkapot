defmodule SpoorKapot.NsApi.Disruption do
  alias SpoorKapot.NsApi.Disruption

  defstruct [:id, :affected_stations]

  def new(json) do
    id = json["id"]

    affected_stations =
      get_in(json, ["publicationSections", Access.at(0), "section", "stations"])
      |> case do
        nil -> []
        stations -> Enum.map(stations, &SpoorKapot.NsApi.Station.new/1)
      end

    %Disruption{
      id: id,
      affected_stations: affected_stations
    }
  end

  def disruptions() do
    {:ok, %{body: body}} =
      SpoorKapot.NsApi.client() |> Tesla.get("/v3/disruptions", query: [isActive: true])

    Enum.map(body, &new/1)
  end
end
