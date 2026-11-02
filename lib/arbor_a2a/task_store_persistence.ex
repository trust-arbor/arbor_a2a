defmodule Arbor.A2A.TaskStore.Persistence do
  @moduledoc """
  Task-store persistence boundary. `save/2` must commit atomically before
  returning `:ok`; errors leave in-memory state unchanged. The snapshot contains
  tenant/principal identifiers and potentially sensitive task/config data. Hosts
  may supply encryption or database adapters. The default store is ephemeral.
  """
  @callback load(term()) :: {:ok, map() | nil} | {:error, term()}
  @callback save(term(), map()) :: :ok | {:error, term()}
end

defmodule Arbor.A2A.TaskStore.File do
  @moduledoc """
  Atomic local snapshot persistence with private files and synchronous writes.
  Configure `persistence: {Arbor.A2A.TaskStore.File, absolute_path}`. One live
  store may own a path. Restart recovers records and cursor authentication keys;
  active host computations are never replayed automatically. This is a local
  disk adapter, without distributed consensus or multi-writer guarantees.
  """
  @behaviour Arbor.A2A.TaskStore.Persistence
  @impl true
  def load(path) when is_binary(path) do
    case :global.register_name({__MODULE__, Path.expand(path)}, self()) do
      :yes -> read(path)
      :no -> {:error, :store_already_open}
    end
  end

  defp read(path) do
    case File.read(path) do
      {:error, :enoent} ->
        {:ok, nil}

      {:ok, bytes} ->
        {:ok, :erlang.binary_to_term(bytes, [:safe])}

      _ ->
        {:error, :invalid_store_file}
    end
  rescue
    _ -> {:error, :invalid_store_file}
  end

  @impl true
  def save(path, snapshot) do
    temp = path <> "." <> Arbor.A2A.id() <> ".tmp"

    try do
      with :ok <- File.mkdir_p(Path.dirname(path)),
           {:ok, file} <- File.open(temp, [:write, :binary, :exclusive]) do
        result =
          try do
            with :ok <- File.chmod(temp, 0o600),
                 :ok <- IO.binwrite(file, :erlang.term_to_binary(snapshot)),
                 do: :file.sync(file)
          after
            File.close(file)
          end

        with :ok <- result, do: File.rename(temp, path)
      end
    after
      File.rm(temp)
    end
  end
end
