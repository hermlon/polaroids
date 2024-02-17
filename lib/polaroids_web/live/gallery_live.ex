defmodule PolaroidsWeb.GalleryLive do
  alias PolaroidsWeb.NotFoundError
  alias Phoenix.PubSub
  use PolaroidsWeb, :live_view

  def mount(%{"gallery" => gallery}, _session, socket) do
    PubSub.subscribe(Polaroids.PubSub, "gallery")
    socket = assign(socket, :gallery, gallery)
    socket = stream(socket, :images, get_images_by_gallery(gallery))
    {:ok, socket}
  end

  def get_images_by_gallery(gallery) do
    {:ok, %{body: %{contents: images}}} = ExAws.S3.list_objects("polaroids", prefix: gallery <> "/") |> ExAws.request
    to_image = fn %{
      key: key,
      last_modified: last_modified
    } -> %{
      id: Path.basename(key, Path.extname(key)) |> String.replace(".", "") |> String.split("-") |> hd,
      last_modified: last_modified,
      src: ~p"/s3/#{key}"
    } end
    IO.inspect(images)

    if length(images) == 0 do
      raise NotFoundError, "gallery with this name doesn't exist"
    end

    Enum.map(images, to_image)
    |> Enum.sort_by(&(&1.last_modified), :desc)
    |> Enum.shuffle
  end

  def handle_event("remove", %{"id" => dom_id}, socket) do
    {:noreply, stream_delete_by_dom_id(socket, :images, dom_id)}
  end

  def handle_info(%{event: "upload", name: name, image: image}, socket) do
    if name == socket.assigns.gallery do
      key = image
      socket = stream_insert(socket, :images, %{
        id: Path.basename(key, Path.extname(key)) |> String.replace(".", "") |> String.split("-") |> hd,
        #last_modified: last_modified,
        src: ~p"/s3/#{key}"
      }, at: 0)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

end
