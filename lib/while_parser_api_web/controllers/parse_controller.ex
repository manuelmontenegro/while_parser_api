defmodule WhileParserApiWeb.ParseController do
  use WhileParserApiWeb, :controller

  def parse(conn, args) do
    case WhileParserApi.parse_while(args) do
      {:ok, result} ->
        render(conn, "result.json", body: result)

      {:error, {line_no, msg}} ->
        render(conn, "error.json", msg: msg, line_no: line_no)

      {:error, other} ->
        render(conn, "error.json", value: other)
    end
  end
end
