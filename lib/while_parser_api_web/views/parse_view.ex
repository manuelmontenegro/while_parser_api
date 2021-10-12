defmodule WhileParserApiWeb.ParseView do
  use WhileParserApiWeb, :view

  def render("result.json", %{body: body}) do
    %{ok: true, body: body}
  end

  def render("cfg.json", %{body: body, start_label: start}) do
    %{ok: true, body: body, start_label: start}
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

  def render("error_cfg.json", %{line_no: line}) do
    %{
      ok: false,
      msg: "cannot generate cfg: unsupported statement. Only assignments, skip, conditionals and while loops are allowed",
      line_no: line
    }
  end
end
