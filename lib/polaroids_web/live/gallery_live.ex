defmodule PolaroidsWeb.GalleryLive do
  alias Phoenix.PubSub
  use PolaroidsWeb, :live_view

  def mount(%{"gallery" => gallery}, _session, socket) do
    PubSub.subscribe(Polaroids.PubSub, "gallery")
    socket = assign(socket, :gallery, gallery)
    socket = stream_configure(socket, :images, dom_id: &(&1.key))
    socket = stream(socket, :images, Image.index(gallery))
    {:ok, socket}
  end

  def handle_event("remove", %{"id" => dom_id}, socket) do
    PubSub.broadcast!(Polaroids.PubSub, "gallery", %{event: "delete", name: socket.assigns.gallery, id: dom_id})
    ExAws.S3.delete_object("polaroids", dom_id) |> ExAws.request!
    {:noreply, socket}
  end

  def handle_info(%{event: "upload", name: name, image: image}, socket) do
    if name == socket.assigns.gallery do
      socket = stream_insert(socket, :images, image, at: 0)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "delete", name: name, id: dom_id}, socket) do
    if name == socket.assigns.gallery do
      socket = stream_delete_by_dom_id(socket, :images, dom_id)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

end
