defmodule Sht31gs.Application do
  use Application

  def start(_type, _args) do
    Sht31gs.Supervisor.start_link()
  end
end
