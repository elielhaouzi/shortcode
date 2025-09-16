defmodule Shortcode.MixProject do
  use Mix.Project

  @source_url "https://github.com/elielhaouzi/shortcode"
  @version "0.7.1"

  def project do
    [
      app: :shortcode,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto, "~> 3.5"},
      {:custom_base, "~> 0.2"}
    ]
  end

  defp description() do
    """
    An Ecto type for UUIDs and ID displayed as shortcode with support of
    prefix 'à la Stripe'.
    """
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end
end
