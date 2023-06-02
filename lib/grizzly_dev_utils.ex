defmodule Grizzly.DevUtils do
  @moduledoc """
  Experimental dev utils for Grizzly. Use at your own risk.
  """

  alias Exqlite.Sqlite3

  @doc """
  Resets the S2 SPAN table in Z/IP Gateway's database. This is useful for decrypting
  traffic captured by Zniffer.exe as it will force all S2 nodes to do a nonce exchange
  the next time they communicate with the controller.

  If you are not using Grizzly to manage Z/IP Gateway, you will need to pass the option
  `restart_zipgateway: false`. In this case, the caller is responsible for ensuring
  Z/IP Gateway is not running prior to calling this function.

  Be sure to have the network keys loaded into Zniffer.exe before running this.
  See `Grizzly.zniffer_network_keys/0` for more information on how to do this.
  """
  @spec reset_span_table(String.t(), [{:restart_zipgateway, boolean()}]) :: :ok
  def reset_span_table(db_path, opts \\ []) do
    restart_zipgateway? = Keyword.get(opts, :restart_zipgateway, true)

    # maybe stop z/ip gateway
    if restart_zipgateway? do
      _ = Supervisor.terminate_child(__MODULE__, MuonTrap.Daemon)
    end

    # delete all rows from the s2 span table
    {:ok, conn} = Sqlite3.open(db_path)
    :ok = Sqlite3.execute(conn, "DELETE FROM s2_span")
    :ok = Sqlite3.close(conn)

    # maybe restart z/ip gateway
    if restart_zipgateway? do
      {:ok, _} = Supervisor.start_child(__MODULE__, MuonTrap.Daemon)
    end

    :ok
  end
end
