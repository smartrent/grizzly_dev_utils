defmodule Grizzly.DevUtils.ZgwDatabase do
  @moduledoc false

  use GenServer

  alias Exqlite

  @type opt :: {:zipgateway_db_path, String.t()}

  @type mf_data :: %{
          manufacturer_id: 0..0xFFFF,
          product_type_id: 0..0xFFFF,
          product_id: 0..0xFFFF
        }

  @mf_data_query "SELECT manufacturerID, productType, productID FROM nodes WHERE nodeid = ? LIMIT 1"

  @reset_span_query "DELETE FROM s2_span"

  @spec manufacturer_data(pos_integer()) ::
          {:ok, mf_data()} | {:error, :not_found | Exception.t()}
  def manufacturer_data(node_id) do
    GenServer.call(__MODULE__, {:manufacturer_data, node_id})
  end

  @spec reset_span_table() :: :ok | {:error, Exception.t()}
  def reset_span_table() do
    GenServer.call(__MODULE__, :reset_span_table)
  end

  @spec start_link([opt()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    db_path = Keyword.fetch!(opts, :zipgateway_db_path)

    case Exqlite.start_link(database: db_path) do
      {:ok, conn} -> {:ok, %{conn: conn}}
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl GenServer
  def handle_call({:manufacturer_data, node_id}, _from, state) do
    case Exqlite.query(state.conn, @mf_data_query, [node_id]) do
      {:ok, %{rows: [[manufacturer_id, product_type_id, product_id]]}} ->
        mf_data = %{
          manufacturer_id: manufacturer_id,
          product_type_id: product_type_id,
          product_id: product_id
        }

        {:reply, {:ok, mf_data}, state}

      {:ok, %{rows: []}} ->
        {:reply, {:error, :not_found}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:reset_span_table, _from, state) do
    case Exqlite.query(state.conn, @reset_span_query, []) do
      {:ok, _} -> {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end
end
