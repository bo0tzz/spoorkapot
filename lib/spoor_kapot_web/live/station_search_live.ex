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
      search_results: search(search_phrase),
      search_phrase: search_phrase
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "pick",
        %{"name" => name, "code" => code},
        %{assigns: %{selected_stations: selected}} = socket
      ) do
    assigns = [
      search_results: [],
      search_phrase: "",
      selected_stations: [{name, code} | selected]
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "remove",
        %{"code" => code},
        %{assigns: %{selected_stations: selected}} = socket
      ) do
    Logger.info("Removing #{code} from #{inspect(selected)}")

    assigns = [
      selected_stations: Enum.reject(selected, &match?({_, ^code}, &1))
    ]

    {:noreply, assign(socket, assigns)}
  end

  def search(""), do: []
  def search(q), do: SpoorKapot.StationSearch.find_stations(q)
end
