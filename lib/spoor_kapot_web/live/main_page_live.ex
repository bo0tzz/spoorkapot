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

  def handle_event("register", _, socket) do
    # TODO: Display error if selected_stations is empty
    codes = Enum.map(socket.assigns.selected_stations, & &1.code)
    {:noreply, push_event(socket, "register", %{stations: codes})}
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
      selected_stations: selected ++ [station]
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
    current_focus =
      case socket.assigns.current_focus - 1 do
        index when index < 0 -> length(socket.assigns.search_results) - 1
        index -> index
      end

    socket =
      socket
      |> assign(current_focus: current_focus)
      |> push_event("scroll_into_view", %{id: "search-result-#{current_focus}"})

    {:noreply, socket}
  end

  def handle_event("set-focus", %{"key" => "ArrowDown"}, socket) do
    current_focus =
      case socket.assigns.current_focus + 1 do
        index when index > length(socket.assigns.search_results) - 1 -> 0
        index -> index
      end

    socket =
      socket
      |> assign(current_focus: current_focus)
      |> push_event("scroll_into_view", %{id: "search-result-#{current_focus}"})

    {:noreply, socket}
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
    <div class={class} id={"search-result-#{@idx}"} phx-value-code={@station.code} phx-click="pick">
      <%= @station.name %>
    </div>
    """
  end

  def focused_station(_, -1), do: nil
  def focused_station(stations, index), do: Enum.at(stations, index)
end
