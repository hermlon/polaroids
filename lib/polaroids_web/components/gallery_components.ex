defmodule PolaroidsWeb.GalleryComponents do
  use PolaroidsWeb, :html

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
        <div class="flex flex-row hidden sm:flex justify-between">
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
