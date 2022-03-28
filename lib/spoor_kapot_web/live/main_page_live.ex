defmodule SpoorKapotWeb.MainPageLive do
  use SpoorKapotWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    assigns = [
      conn: socket,
      search_results: [],
      search_phrase: "",
      selected_stations: [],
      current_focus: -1
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
      current_focus: -1,
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

  def handle_event("set-focus", %{"key" => "ArrowUp"}, socket) do
    current_focus = Enum.max([socket.assigns.current_focus - 1, 0])
    {:noreply, assign(socket, current_focus: current_focus)}
  end

  def handle_event("set-focus", %{"key" => "ArrowDown"}, socket) do
    current_focus =
      Enum.min([socket.assigns.current_focus + 1, length(socket.assigns.search_results) - 1])

    {:noreply, assign(socket, current_focus: current_focus)}
  end

  def handle_event("set-focus", %{"key" => "Enter"}, socket) do
    case focused_station(socket.assigns.search_results, socket.assigns.current_focus) do
      nil -> {:noreply, socket}
      station -> handle_event("pick", %{"code" => station.code}, socket)
    end
  end

  def handle_event("set-focus", _, socket), do: {:noreply, socket}
  def handle_event("submit", _, socket), do: {:noreply, socket}

  def search_item(%{focused: focused} = assigns) do
    class_base = ["cursor-pointer", "p-2", "hover:bg-gray-200", "focus:bg-gray-200"]
    class = if focused, do: ["bg-gray-200" | class_base], else: class_base

    ~H"""
      <div class={class} phx-value-code={@station.code} phx-click="pick">
        <%= @station.name %>
      </div>
    """
  end

  # def focused_station(_, -1), do: nil
  def focused_station(stations, index), do: Enum.at(stations, index)
end
