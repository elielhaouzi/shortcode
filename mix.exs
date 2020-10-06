defmodule Shortcode.MixProject do
  use Mix.Project

  def project do
    [
      app: :shortcode,
      version: "0.2.0",
      elixir: "~> 1.8",
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
      {:ecto, "~> 3.5"}
    ]
  end

  defp description() do
    "An Ecto type for UUIDs and ID displayed as shortcode with support of prefix 'à la Stripe'."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/elielhaouzi/shortcode"}
    ]
  end
end
