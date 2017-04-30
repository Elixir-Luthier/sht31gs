defmodule Sht31gs.Mixfile do
  use Mix.Project

  def project do
    [
     app: :sht31gs,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     name: "Sht31gs",
     description: description(),
     source_url: "https://github.com/elixir-luthier/sht31gs"
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {Sht31gs.Application, []}]
  end

  defp description do
    """
      An application to demonstrate how one might write an OTP-compliant GenServer Application for an IoT device accessed with
      ElixirALE
    """
  end

  defp package do
   [
     name: :sht31gs,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Rob Baruch"],
     licenses: ["Apache 2.0"],
     links: %{"Github" => "https://github.com/elixir-luthier/sht31gs"}
   ]
  end
  defp deps do
    [{:elixir_ale, "~> 0.6.2"}, {:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
