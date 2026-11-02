defmodule Arbor.A2A.MixProject do
  use Mix.Project

  def project do
    [
      app: :arbor_a2a,
      version: "0.1.0-dev",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: if(Mix.env() == :test, do: ["lib", "test/support"], else: ["lib"]),
      description: "A2A protocol client and Plug server for the Arbor ecosystem",
      # grpc_server's optional Cowboy >= 2.16 rejects CR/LF response headers.
      # See docs/DEPENDENCY_SECURITY.md and scripts/check_dependency_policy.py.
      hex: [ignore_advisories: ["EEF-CVE-2026-43966"]],
      source_url: "https://github.com/trust-arbor/arbor_a2a",
      package: [
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/trust-arbor/arbor_a2a",
          "A2A specification" => "https://a2a-protocol.org/"
        },
        files:
          ~w(lib priv mix.exs mix.lock .formatter.exs README.md LICENSE CHANGELOG.md docs usage-rules.md)
      ],
      docs: [
        main: "readme",
        extras: [
          "README.md",
          "docs/ARCHITECTURE.md",
          "docs/AUTHENTICATION.md",
          "docs/COVERAGE.md",
          "docs/TESTING.md",
          "docs/REQUIREMENTS.md",
          "docs/DEPENDENCY_SECURITY.md",
          "usage-rules.md"
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto, :ssl],
      mod: {Arbor.A2A.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:arbor_rpc, "== 1.0.0-rc.4"},
      {:protobuf, "~> 0.17"},
      {:grpc, "~> 1.0"},
      {:grpc_server, "~> 1.0", optional: true},
      {:cowboy, ">= 2.16.0 and < 3.0.0", optional: true},
      {:jcs, "~> 0.2"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.18.5 or ~> 1.19.5 or >= 1.20.3 and < 2.0.0"},
      {:mint, ">= 1.10.2 and < 2.0.0"},
      {:castore, "~> 1.0"},
      {:oidcc, "~> 3.9", optional: true},
      {:jose, "~> 1.11 and >= 1.11.13", optional: true},
      {:bandit, "~> 1.14", only: [:dev, :test]},
      {:stream_data, "~> 1.3", only: :test},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
