defmodule PolaroidsWeb.ImageLive do
  alias Polaroids.Gallery
  alias Phoenix.PubSub
  use PolaroidsWeb, :live_view

  def mount(%{"gallery" => gallery, "image" => image}, _session, socket) do
    socket = assign(socket, :image, Gallery.get_image!("#{gallery}/#{image}"))
    {:ok, socket}
  end

  def handle_event("remove", %{"id" => key}, socket) do
    PubSub.broadcast!(Polaroids.PubSub, "gallery", %{event: "delete", key: key})
    ExAws.S3.delete_object("polaroids", key) |> ExAws.request!
    {:noreply, push_navigate(socket, to: ~p"/g/#{Gallery.Image.gallery(key)}", replace: true)}
  end
end
