defmodule PolaroidsWeb.GalleryController do
  alias Polaroids.Gallery
  alias Phoenix.PubSub
  use PolaroidsWeb, :controller

  def create(conn, %{"gallery" => gallery, "file" => file} = params) do
    file_extension = Path.extname(file.filename)
    file_uuid = Ecto.UUID.generate()
    key = "#{gallery}/#{file_uuid}#{file_extension}"
    {:ok, file_binary} = File.read(file.path)
    image = Gallery.create_image(key, file_binary, Map.get(params, "nickname"), Map.get(params, "description"), Map.get(params, "venue"))
    PubSub.broadcast!(Polaroids.PubSub, "gallery", %{event: "upload", name: gallery, image: image})
    render(conn, :show, image: image)
  end
end
