defmodule Polaroids.GalleryTest do
  use Polaroids.DataCase

  alias Polaroids.Gallery

  describe "images" do
    alias Polaroids.Gallery.Image

    import Polaroids.GalleryFixtures

    @invalid_attrs %{description: nil, key: nil, last_modified: nil, nickname: nil, venue: nil}

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Gallery.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Gallery.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      valid_attrs = %{description: "some description", key: "some key", last_modified: "some last_modified", nickname: "some nickname", venue: "some venue"}

      assert {:ok, %Image{} = image} = Gallery.create_image(valid_attrs)
      assert image.description == "some description"
      assert image.key == "some key"
      assert image.last_modified == "some last_modified"
      assert image.nickname == "some nickname"
      assert image.venue == "some venue"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gallery.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      update_attrs = %{description: "some updated description", key: "some updated key", last_modified: "some updated last_modified", nickname: "some updated nickname", venue: "some updated venue"}

      assert {:ok, %Image{} = image} = Gallery.update_image(image, update_attrs)
      assert image.description == "some updated description"
      assert image.key == "some updated key"
      assert image.last_modified == "some updated last_modified"
      assert image.nickname == "some updated nickname"
      assert image.venue == "some updated venue"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Gallery.update_image(image, @invalid_attrs)
      assert image == Gallery.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Gallery.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Gallery.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Gallery.change_image(image)
    end
  end
end
