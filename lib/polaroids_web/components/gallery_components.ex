defmodule PolaroidsWeb.GalleryComponents do
  alias Polaroids.Gallery
  use PolaroidsWeb, :html

  attr :image, :any, required: true
  attr :info, :boolean, default: false
  def image(assigns) do
    ~H"""
    <div class="grid">
      <div class="w-full rounded-lg col-[1] row-[1] overflow-hidden">
        <img
          class={"w-full object-cover object-center transition hover:scale-105 duration-500 #{if @info, do: "hover:brightness-50"}"}
          src={Gallery.static_url(@image.key)}
        />
      </div>
      <div :if={@info} class="flex flex-col hidden sm:flex justify-end pointer-events-none p-5 z-10 col-[1] row-[1] w-full">
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
        <div class="self-end text-xs opacity-50">
          <%= Timex.from_now(@image.last_modified) %>
        </div>
      </div>
    </div>
    """
  end
end
