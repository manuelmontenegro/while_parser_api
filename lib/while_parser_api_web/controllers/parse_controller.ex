defmodule WhileParserApiWeb.ParseController do
  use WhileParserApiWeb, :controller

  def parse(conn, %{"cfg" => "true"} = args) do
    case WhileParserApi.parse_while_cfg(args) do
      {:ok, result, start} ->
        render(conn, "result.json", body: result, start_label: start)

      {:error, {:unsupported, {_, _, line_no, _}}} ->
        render(conn, "error_cfg.json", line_no: line_no)

      {:error, {line_no, msg}} ->
        render(conn, "error.json", msg: msg, line_no: line_no)
    end
  end

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
