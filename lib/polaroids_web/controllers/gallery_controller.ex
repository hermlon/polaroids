defmodule Image do
  defstruct [:key, :last_modified, :description, :nickname, :venue]

  def store(key, file_binary, nickname, description, venue) do
    %{headers: headers_list} = ExAws.S3.put_object("polaroids", key, file_binary, meta: [
      {:nickname, nickname},
      {:description, description},
      {:venue, venue}] |> Enum.filter(&elem(&1, 1))
    ) |> ExAws.request!
    %{"Date" => date} = Map.new(headers_list)
    %Image{
      key: key,
      last_modified: date,
      nickname: nickname,
      description: description,
      venue: venue
    }
  end

  def get_keys_in_gallery(gallery) do
    %{body: %{contents: images}} = ExAws.S3.list_objects("polaroids", prefix: gallery <> "/") |> ExAws.request!
    Enum.map(images, fn %{
      key: key,
      last_modified: last_modified
    } -> %{
      key: key,
      last_modified: last_modified
    } end)
  end

  def index(gallery, limit \\ nil) do
    keys = get_keys_in_gallery(gallery)
    |> Enum.sort_by(&(&1.last_modified), :desc)
    keys = if limit do Enum.take(keys, limit) else keys end

    keys |> Enum.map(fn %{
      key: key,
      last_modified: last_modified,
    } ->
    %{headers: headers_list} = Image.head(key)
    headers = Map.new(headers_list)
    %Image{
      key: key,
      last_modified: last_modified,
      nickname: Map.get(headers, "x-amz-meta-nickname"),
      description: Map.get(headers, "x-amz-meta-description"),
      venue: Map.get(headers, "x-amz-meta-venue")
    } end)
  end

  def head(key) do
    ExAws.S3.head_object("polaroids", key) |> ExAws.request!
  end

  def static_url(key) do
    "https://r2.yuustan.space/" <> key
  end
end

defmodule PolaroidsWeb.GalleryController do
  alias Phoenix.PubSub
  use PolaroidsWeb, :controller

  def create(conn, %{"gallery" => gallery, "file" => file} = params) do
    file_extension = Path.extname(file.filename)
    file_uuid = Ecto.UUID.generate()
    key = "#{gallery}/#{file_uuid}#{file_extension}"
    {:ok, file_binary} = File.read(file.path)
    image = Image.store(key, file_binary, Map.get(params, "nickname"), Map.get(params, "description"), Map.get(params, "venue"))
    PubSub.broadcast!(Polaroids.PubSub, "gallery", %{event: "upload", name: gallery, image: image})
    render(conn, :show, image: image)
  end
end
