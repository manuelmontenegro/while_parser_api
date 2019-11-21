defmodule WhileParserApi do
  @moduledoc """
  WhileParserApi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def parse_while(%{"while_code" => code} = args) do
    options = [] |> add_pretty(args)
    WhileParser.parse_to_json(code, options)
  end

  def parse_while(_) do
    {:error, :no_while_code}
  end

  defp add_pretty(opts, %{"pretty" => "true"}), do: [{:pretty, true} | opts]
  defp add_pretty(opts, _), do: opts
end
