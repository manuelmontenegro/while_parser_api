defmodule WhileParserApiWeb.Router do
  use WhileParserApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/while_parser", WhileParserApiWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/while_parser/api", WhileParserApiWeb do
    pipe_through :api

    post "/parse", ParseController, :parse
  end
end
