defmodule Grizzly.DevUtils do
  @moduledoc """
  Experimental dev utils for Grizzly. Use at your own risk.
  """

  alias Grizzly.DevUtils.ZgwDatabase

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
  @spec reset_span_table([{:restart_zipgateway, boolean()}]) :: :ok | {:error, Exception.t()}
  def reset_span_table(opts \\ []) do
    restart_zipgateway? = Keyword.get(opts, :restart_zipgateway, true)

    # maybe stop z/ip gateway
    if restart_zipgateway? do
      _ = Supervisor.terminate_child(Grizzly.ZIPGateway.Supervisor, MuonTrap.Daemon)
    end

    result = ZgwDatabase.reset_span_table()

    # maybe restart z/ip gateway
    if restart_zipgateway? do
      {:ok, _} = Supervisor.restart_child(Grizzly.ZIPGateway.Supervisor, MuonTrap.Daemon)
    end

    result
  end

  @doc """
  Fetches the manufacturer data for the given node ID from Z/IP Gateway's database.
  """
  @spec manufacturer_data(pos_integer()) ::
          {:ok, ZgwDatabase.mf_data()} | {:error, :not_found | Exception.t()}
  defdelegate manufacturer_data(node_id), to: ZgwDatabase
end
