defmodule SpoorKapotWeb.LayoutView do
  use SpoorKapotWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def vapid_key_data() do
    key = Application.fetch_env!(:web_push_encryption, :vapid_details)[:public_key]
    data = Jason.encode!(%{applicationServerKey: key}) |> Phoenix.HTML.raw()
    content_tag(:script, data, type: "application/json", id: "vapid-key")
  end
end
