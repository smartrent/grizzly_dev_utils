defmodule Grizzly.DevUtils.Supervisor do
  use Supervisor

  @type arg :: {:zipgateway_db_path, String.t()}

  @spec start_link([arg()]) :: Supervisor.on_start()
  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl Supervisor
  def init(init_args) do
    children = [
      {Grizzly.DevUtils.ZgwDatabase, init_args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
