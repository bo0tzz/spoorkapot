defmodule SpoorKapot.NsApi do
  def stations() do
    SpoorKapot.NsApi.Station.stations()
  end

  defp key() do
    Application.fetch_env!(:spoor_kapot, __MODULE__)[:api_key]
  end

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://gateway.apiportal.ns.nl/reisinformatie-api/api"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Ocp-Apim-Subscription-Key", key()}]}
    ]

    Tesla.client(middleware)
  end
end
