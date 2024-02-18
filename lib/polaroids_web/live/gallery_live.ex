defmodule PolaroidsWeb.GalleryLive do
  alias Phoenix.PubSub
  use PolaroidsWeb, :live_view

  def top_5_images(gallery) do
    Image.index(gallery) |> Enum.take(5) |> Enum.with_index |> Map.new(fn {val, key} -> {key, val} end)
  end

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

  def image(assigns) do
    ~H"""
    <div class="grid w-full">
      <div class="w-full rounded-lg col-[1] row-[1] overflow-hidden">
        <img
          class="w-full object-cover object-center transition hover:scale-105 duration-500"
          phx-click={JS.push("remove", value: %{id: @image.key})}
          src={Image.static_url(@image.key)}
        />
      </div>
      <div class="flex flex-col justify-end pointer-events-none p-5 z-10 col-[1] row-[1] w-full">
        <div class="flex flex-row justify-between">
          <div class="flex items-end">
            <%= @image.description %>
          </div>
          <div class="flex flex-col items-end">
            <div :if={@image.venue} class="flex flex-row gap-1 opacity-50 items-center">
              <.icon name="hero-map-pin" />
              <div>
                <%= @image.venue %>
              </div>
            </div>
            <div :if={@image.nickname}>
              <%= @image.nickname %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
