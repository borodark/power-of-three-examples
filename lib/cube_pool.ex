defmodule Adbc.CubePool do
  @moduledoc """
  Simple connection pool for Cube ADBC tests.

  Creates a pool of connections that can be used across tests.
  Each connection is supervised and cleaned up automatically.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    pool_size = Keyword.get(opts, :pool_size, 4)
    host = Keyword.fetch!(opts, :host)
    port = Keyword.fetch!(opts, :port)
    token = Keyword.fetch!(opts, :token)

    # Database supervisor - single shared database instance
    database_spec = {
      Adbc.Database,
      [
        driver: Path.join(:code.priv_dir(:adbc), "lib/libadbc_driver_cube.so"),
        "adbc.cube.host": host,
        "adbc.cube.port": Integer.to_string(port),
        "adbc.cube.connection_mode": "native",
        "adbc.cube.token": token,
        process_options: [name: Adbc.Cube]
      ]
    }

    # Connection pool - multiple connection processes
    connection_specs =
      for i <- 1..pool_size do
        connection_name = :"Adbc.CubeConn#{i}"

        Supervisor.child_spec(
          {Adbc.Connection,
           [
             database: Adbc.Cube,
             process_options: [name: connection_name]
           ]},
          id: {Adbc.Connection, i}
        )
      end

    children = [database_spec | connection_specs]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Gets a connection from the pool using round-robin.
  """
  def get_connection do
    pool_size = get_pool_size()
    # Use a simple counter-based round-robin
    counter = :atomics.add_get(pool_counter(), 1, 1)
    index = rem(counter, pool_size) + 1
    connection_name = :"Adbc.CubeConn#{index}"
    Process.whereis(connection_name)
  end

  @doc """
  Gets a specific connection by index (1-based).
  """
  def get_connection(index) when is_integer(index) and index > 0 do
    connection_name = :"Adbc.CubeConn#{index}"
    Process.whereis(connection_name)
  end

  @doc """
  Returns the pool size.
  """
  def get_pool_size do
    # Count registered connections
    "Adbc.CubeConn"
    |> then(fn prefix ->
      Process.registered()
      |> Enum.filter(&String.starts_with?(Atom.to_string(&1), prefix))
      |> length()
    end)
  end

  # Persistent term for round-robin counter
  defp pool_counter do
    key = {__MODULE__, :counter}

    case :persistent_term.get(key, nil) do
      nil ->
        ref = :atomics.new(1, [])
        :persistent_term.put(key, ref)
        ref

      ref ->
        ref
    end
  end
end
