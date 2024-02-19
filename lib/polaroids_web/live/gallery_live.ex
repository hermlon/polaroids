defmodule PolaroidsWeb.GalleryLive do
  alias Polaroids.Gallery
  alias Polaroids.Gallery.Image
  alias Phoenix.PubSub
  use PolaroidsWeb, :live_view

  def mount(%{"gallery" => gallery}, _session, socket) do
    PubSub.subscribe(Polaroids.PubSub, "gallery")
    socket = assign(socket, :gallery, gallery)
    socket = stream_configure(socket, :images, dom_id: &(&1.key))
    socket = stream(socket, :images, Gallery.list_images(gallery))
    {:ok, socket}
  end

  def handle_info(%{event: "upload", name: name, image: image}, socket) do
    if name == socket.assigns.gallery do
      socket = stream_insert(socket, :images, image, at: 0)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "delete", key: key}, socket) do
    socket = stream_delete_by_dom_id(socket, :images, key)
    {:noreply, socket}
  end
end
