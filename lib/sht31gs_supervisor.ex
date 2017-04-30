defmodule Sht31gs.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [addr: 0x44])
  end

  def init([addr: addr]) do
    children = [
      worker(Sht31gs, [addr])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
