defmodule PolaroidsWeb.S3Controller do
  use PolaroidsWeb, :controller

  def show(conn, %{"gallery" => gallery, "image" => image}) do
    {:ok, %{body: image_content}} = ExAws.S3.get_object("polaroids", "#{gallery}/#{image}") |> ExAws.request
    conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, image_content)
  end

end
