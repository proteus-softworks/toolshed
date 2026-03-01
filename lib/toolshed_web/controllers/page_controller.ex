defmodule ToolshedWeb.PageController do
  use ToolshedWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
