defmodule SpoorKapot.NsApi.Disruption do
  alias SpoorKapot.NsApi.Disruption

  defstruct [:id, :title, :affected_stations]

  def new(json) do
    id = json["id"]

    title = get_in(json, ["timespans", Access.at(0), "situation", "label"])

    affected_stations =
      get_in(json, ["publicationSections", Access.at(0), "section", "stations"])
      |> case do
        nil -> []
        stations -> Enum.map(stations, &SpoorKapot.NsApi.Station.new/1)
      end

    %Disruption{
      id: id,
      title: title,
      affected_stations: affected_stations
    }
  end

  def disruptions() do
    {:ok, %{body: body}} =
      SpoorKapot.NsApi.client() |> Tesla.get("/v3/disruptions", query: [isActive: true])

    Enum.map(body, &new/1)
  end
end
