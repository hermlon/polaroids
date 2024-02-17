defmodule PolaroidsWeb.S3Controller do
  use PolaroidsWeb, :controller

  def show(conn, %{"path" => path}) do
    {:ok, %{body: image_content}} = ExAws.S3.get_object("polaroids", path) |> ExAws.request
    conn
    |> put_resp_content_type("image/jpg")
    |> send_resp(200, image_content)
  end

end
