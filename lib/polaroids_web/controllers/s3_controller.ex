defmodule PolaroidsWeb.S3Controller do
  use PolaroidsWeb, :controller

  def show(conn, %{"gallery" => gallery, "image" => image}) do
    {:ok, %{body: image_content, headers: headers_list}} = ExAws.S3.get_object("polaroids", "#{gallery}/#{image}") |> ExAws.request
    %{"Content-Type" => content_type} = Map.new(headers_list)
    conn
    |> put_resp_content_type(content_type)
    |> send_resp(200, image_content)
  end

end
