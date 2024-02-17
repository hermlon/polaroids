defmodule PolaroidsWeb.GalleryJSON do

  def show(%{image: image}) do
    %{
      key: image.key,
      last_modified: image.last_modified,
      nickname: image.nickname,
      description: image.description,
      venue: image.venue
    }
  end
end
