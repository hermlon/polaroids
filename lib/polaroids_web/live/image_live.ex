defmodule PolaroidsWeb.ImageLive do
  alias Phoenix.PubSub
  use PolaroidsWeb, :live_view

  def mount(%{"gallery" => gallery, "image" => image}, _session, socket) do
    socket = assign(socket, :image_key, "#{gallery}/#{image}")
    {:ok, socket}
  end

  def handle_event("remove", %{"id" => dom_id}, socket) do
    PubSub.broadcast!(Polaroids.PubSub, "gallery", %{event: "delete", name: socket.assigns.gallery, id: dom_id})
    ExAws.S3.delete_object("polaroids", dom_id) |> ExAws.request!
    {:noreply, socket}
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
