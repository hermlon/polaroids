defmodule PolaroidsWeb.ImageLive do
  alias Polaroids.Gallery
  alias Phoenix.PubSub
  use PolaroidsWeb, :live_view

  def mount(%{"gallery" => gallery, "image" => image}, _session, socket) do
    gallery_image = Gallery.get_image!("#{gallery}/#{image}")
    socket = assign(socket, :image, gallery_image)
    edit_url = gallery_image.meta && Application.fetch_env!(:polaroids, :edit_url)
    socket = assign(socket, :edit_url, edit_url && (edit_url <> gallery_image.meta))
    socket = assign(socket, :is_admin, false)
    {:ok, socket}
  end

  #def handle_event("remove", %{"id" => key}, socket) do
  #  PubSub.broadcast!(Polaroids.PubSub, "gallery", %{event: "delete", key: key})
  #  Gallery.delete_image(key)
  #  {:noreply, push_navigate(socket, to: ~p"/g/#{Gallery.Image.gallery(key)}", replace: true)}
  #end

  def handle_event("share", %{"id" => key}, socket) do
    {:noreply, push_event(socket, "share", %{image: Gallery.static_url(key)})}
  end
end
