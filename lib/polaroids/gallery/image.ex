defmodule Polaroids.Gallery.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :description, :string
    field :key, :string
    field :last_modified, :string
    field :nickname, :string
    field :venue, :string

    timestamps(type: :utc_datetime)
  end

  def gallery(%{key: key}), do: gallery(key)

  def gallery(key) do
    Path.split(key) |> hd
  end

  def name(%{key: key}), do: name(key)

  def name(key) do
    Path.basename(key, Path.extname(key))
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:key, :last_modified, :description, :nickname, :venue])
    |> validate_required([:key, :last_modified, :description, :nickname, :venue])
  end
end
