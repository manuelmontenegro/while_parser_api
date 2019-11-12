defmodule WhileParserApiWeb.PageController do
  use WhileParserApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
