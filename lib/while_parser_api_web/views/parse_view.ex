defmodule WhileParserApiWeb.ParseView do
  use WhileParserApiWeb, :view

  def render("result.json", %{body: body}) do
    %{ok: true, body: body}
  end

  def render("error.json", %{msg: msg, line_no: line_no}) do
    %{
      ok: false,
      msg: msg,
      line_no: line_no
    }
  end

  def render("error.json", %{value: :no_while_code}) do
    %{
      ok: false,
      msg: "no while_code parameter given"
    }
  end
end
