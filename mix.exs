defmodule Shortcode.MixProject do
  use Mix.Project

  def project do
    [
      app: :shortcode,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto, git: "https://github.com/elixir-ecto/ecto", branch: "master"}
    ]
  end

  defp description() do
    "An Ecto type for UUIDs and ID displayed as shortcode with support of prefix 'à la Stripe'."
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/elielhaouzi/shortcode"}
    ]
  end
end
