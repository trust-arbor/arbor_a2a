defmodule Arbor.A2A.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :duplicate, name: Arbor.A2A.Stores},
      {Arbor.A2A.Events, []},
      {Arbor.A2A.Push, []},
      {Task.Supervisor, name: Arbor.A2A.Executor, max_children: 64}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Arbor.A2A.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
