defmodule PolaroidsWeb.GalleryController do
  alias Phoenix.PubSub
  use PolaroidsWeb, :controller

  def create(conn, %{"gallery" => gallery, "file" => file}) do
    file_extension = Path.extname(file.filename)
    file_uuid = Ecto.UUID.generate()
    s3_filepath = "#{gallery}/#{file_uuid}#{file_extension}"
    {:ok, file_binary} = File.read(file.path)
    {:ok, _} = ExAws.S3.put_object("polaroids", s3_filepath, file_binary) |> ExAws.request()
    PubSub.broadcast!(Polaroids.PubSub, "gallery", %{event: "upload", name: gallery, image: s3_filepath})
    conn |> send_resp(200, "cool")
  end
end
