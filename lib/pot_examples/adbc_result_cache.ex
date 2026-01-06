defmodule ExamplesOfPoT.AdbcResultCache do
  @moduledoc """
  ETS-backed cache for ADBC query results with TTL-based expiry.
  """

  use GenServer

  @table __MODULE__

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get(key) do
    if enabled?() and table_ready?() do
      case :ets.lookup(@table, key) do
        [{^key, expires_at, value}] ->
          if expires_at > now_ms() do
            {:hit, value}
          else
            :ets.delete(@table, key)
            :miss
          end

        [] ->
          :miss
      end
    else
      :miss
    end
  end

  def put(key, value) do
    if enabled?() and table_ready?() do
      ttl_ms = ttl_ms()
      expires_at = now_ms() + ttl_ms
      :ets.insert(@table, {key, expires_at, value})
    end

    :ok
  end

  @impl true
  def init(opts) do
    enabled = Keyword.get(opts, :enabled, true)
    ttl_ms = Keyword.get(opts, :ttl_ms, 60_000)
    cleanup_interval_ms = Keyword.get(opts, :cleanup_interval_ms, 30_000)

    :persistent_term.put({__MODULE__, :enabled}, enabled)
    :persistent_term.put({__MODULE__, :ttl_ms}, ttl_ms)
    :persistent_term.put({__MODULE__, :cleanup_interval_ms}, cleanup_interval_ms)

    if enabled do
      :ets.new(@table, [
        :named_table,
        :set,
        :public,
        read_concurrency: true,
        write_concurrency: true
      ])
    end

    schedule_cleanup(cleanup_interval_ms)
    {:ok, %{enabled: enabled, cleanup_interval_ms: cleanup_interval_ms}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    if state.enabled and table_ready?() do
      now = now_ms()
      match_spec = [{{:"$1", :"$2", :_}, [{:<, :"$2", now}], [true]}]
      :ets.select_delete(@table, match_spec)
    end

    schedule_cleanup(state.cleanup_interval_ms)
    {:noreply, state}
  end

  defp enabled? do
    :persistent_term.get({__MODULE__, :enabled}, false)
  end

  defp ttl_ms do
    :persistent_term.get({__MODULE__, :ttl_ms}, 60_000)
  end

  defp schedule_cleanup(interval_ms) do
    Process.send_after(self(), :cleanup, interval_ms)
  end

  defp table_ready? do
    :ets.whereis(@table) != :undefined
  end

  defp now_ms do
    System.system_time(:millisecond)
  end
end
