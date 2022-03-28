defmodule SpoorKapot.NsApi do
  def stations() do
      SpoorKapot.NsApi.Station.stations()
  end
end
