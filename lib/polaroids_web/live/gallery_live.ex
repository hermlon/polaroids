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

  def image(assigns) do
    ~H"""
    <div class="grid">
      <img
        class="object-cover object-center rounded-lg transition hover:scale-105 col-[1] row-[1]"
        phx-click={JS.push("remove", value: %{id: @image.key})}
        src={Image.static_url(@image.key)}
      />
      <div class="flex flex-col justify-end pointer-events-none m-5 z-10 col-[1] row-[1]">
        <div class="flex flex-row justify-between">
          <div class="flex items-end">
            Me and the girls studying
          </div>
          <div class="flex flex-col items-end">
            <div class="flex gap-1 opacity-50">
              <.icon name="hero-map-pin" /> 37c3
            </div>
            <div>
              Leonie
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
