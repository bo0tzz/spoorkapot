defmodule SpoorKapot.NsApi do
  def load_stations() do
    File.read!("stations.json")
    |> Jason.decode!()
    |> Map.get("payload")
    |> Enum.map(fn %{"code" => code, "namen" => %{"lang" => name}} ->
      {Unicode.Transform.LatinAscii.transform(name), name, code}
    end)
  end
end
