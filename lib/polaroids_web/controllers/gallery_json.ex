defmodule PolaroidsWeb.GalleryJSON do
use PolaroidsWeb, :verified_routes

alias Polaroids.Gallery

  def show(%{image: image}) do
    %{
      key: image.key,
      last_modified: image.last_modified,
      nickname: image.nickname,
      description: image.description,
      venue: image.venue,
      url: Gallery.static_url(image.key),
      page: url(~p"/g/#{Gallery.Image.gallery(image)}/#{Gallery.Image.name(image)}")
    }
  end
end
