defmodule SpoorKapotWeb.StationSearchLive do
  use SpoorKapotWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    assigns = [
      conn: socket,
      search_results: [],
      search_phrase: "",
      selected_stations: []
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("search", %{"search_phrase" => search_phrase}, socket) do
    assigns = [
      search_results: SpoorKapot.StationSearch.find_stations(search_phrase),
      search_phrase: search_phrase
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "pick",
        %{"code" => code},
        %{assigns: %{selected_stations: selected}} = socket
      ) do
    station = SpoorKapot.NsApi.Station.station(code)

    assigns = [
      search_results: [],
      search_phrase: "",
      selected_stations: [station | selected]
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "remove",
        %{"code" => code},
        %{assigns: %{selected_stations: selected}} = socket
      ) do
    assigns = [
      selected_stations: Enum.reject(selected, &match?(%{code: ^code}, &1))
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("submit", _, socket), do: {:noreply, socket} # Prevent form submit
end
