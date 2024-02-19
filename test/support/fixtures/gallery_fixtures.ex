defmodule Polaroids.GalleryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Polaroids.Gallery` context.
  """

  @doc """
  Generate a image.
  """
  def image_fixture(attrs \\ %{}) do
    {:ok, image} =
      attrs
      |> Enum.into(%{
        description: "some description",
        key: "some key",
        last_modified: "some last_modified",
        nickname: "some nickname",
        venue: "some venue"
      })
      |> Polaroids.Gallery.create_image()

    image
  end
end
