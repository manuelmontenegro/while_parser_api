defmodule WhileParserApi do
  @moduledoc """
  Context module that interfaces with the `while_parser` library.
  """

  def parse_while(%{"while_code" => code, "as_text" => "true"} = args) do
    options = [] |> add_pretty(args)
    WhileParser.parse_to_json(code, options)
  end

  def parse_while(%{"while_code" => code}) do
    WhileParser.parse_to_ast(code)
  end

  def parse_while(_) do
    {:error, :no_while_code}
  end

  defp add_pretty(opts, %{"pretty" => "true"}), do: [{:pretty, true} | opts]
  defp add_pretty(opts, _), do: opts
end
