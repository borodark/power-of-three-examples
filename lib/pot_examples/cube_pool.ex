defmodule ExamplesOfPoT.CubePool do
  @moduledoc """
  Connection pool for ADBC Cube connections.

  Manages a pool of connections to the Cube server via Arrow Native protocol.
  Uses the custom ADBC Cube driver for high-performance columnar data access.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    pool_size = Keyword.get(opts, :pool_size, System.schedulers_online() * 2)
    cube_config = Keyword.get(opts, :cube_config, [])

    # Extract Cube configuration
    driver_path = Keyword.fetch!(cube_config, :driver_path)
    host = Keyword.get(cube_config, :host, "localhost")
    port = Keyword.get(cube_config, :port, 4445)
    token = Keyword.get(cube_config, :token, "test")

    # Database supervisor - single shared database instance
    database_spec = {
      Adbc.Database,
      [
        driver: driver_path,
        "adbc.cube.host": host,
        "adbc.cube.port": Integer.to_string(port),
        "adbc.cube.connection_mode": "native",
        "adbc.cube.token": token,
        process_options: [name: ExamplesOfPoT.CubeDB]
      ]
    }

    # Connection pool - multiple connection processes
    connection_specs =
      for i <- 1..pool_size do
        connection_name = :"#{ExamplesOfPoT.CubeConn}#{i}"

        Supervisor.child_spec(
          {Adbc.Connection,
           [
             database: ExamplesOfPoT.CubeDB,
             process_options: [name: connection_name]
           ]},
          id: {Adbc.Connection, i}
        )
      end

    children = [database_spec | connection_specs]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Executes a query using a connection from the pool.

  Uses round-robin selection of connections.

  ## Examples

      iex> ExamplesOfPoT.CubePool.query("SELECT 1 as test")
      {:ok, %Adbc.Result{...}}

  """
  def query(sql, params \\ []) do
    conn = get_connection()
    Adbc.Connection.query(conn, sql, params)
  end

  @doc """
  Gets a connection from the pool using round-robin.
  """
  def get_connection do
    pool_size = get_pool_size()
    # Use a simple counter-based round-robin
    counter = :atomics.add_get(pool_counter(), 1, 1)
    index = rem(counter, pool_size) + 1
    connection_name = :"#{ExamplesOfPoT.CubeConn}#{index}"
    Process.whereis(connection_name)
  end

  @doc """
  Gets a specific connection by index (1-based).
  """
  def get_connection(index) when is_integer(index) and index > 0 do
    connection_name = :"#{ExamplesOfPoT.CubeConn}#{index}"
    Process.whereis(connection_name)
  end

  @doc """
  Returns the pool size.
  """
  def get_pool_size do
    # Count registered connections
    ExamplesOfPoT.CubeConn
    |> Atom.to_string()
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
