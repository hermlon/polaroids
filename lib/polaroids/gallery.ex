defmodule Polaroids.Gallery do
  @moduledoc """
  The Gallery context.
  """

  alias Polaroids.Helpers.RFC2047
  alias Polaroids.Gallery.Image

  def bucket, do: Application.fetch_env!(:polaroids, :s3_bucket)

  def static_url(key), do: Application.fetch_env!(:polaroids, :s3_static_url) <> "/" <> key

  defp get_keys_in_bucket(prefix) do
    %{body: %{contents: images}} = ExAws.S3.list_objects(bucket(), prefix: prefix) |> ExAws.request!
    Enum.map(images, fn %{
      key: key,
      last_modified: last_modified
    } -> %{
      key: key,
      last_modified: last_modified
    } end)
  end

  defp get_images_by_prefix(prefix, limit) do
    keys = get_keys_in_bucket(prefix)
    |> Enum.sort_by(&(&1.last_modified), :desc)
    keys = if limit do Enum.take(keys, limit) else keys end

    keys |> Enum.map(fn %{
      key: key,
      last_modified: last_modified,
    } ->
    Cachex.get!(:image_cache, key) ||
    (%{headers: headers_list} = ExAws.S3.head_object(bucket(), key) |> ExAws.request!
    headers = Map.new(headers_list)
    image = %Image{
      key: key,
      last_modified: Timex.parse!(last_modified, "{ISO:Extended:Z}"),
      nickname: Map.get(headers, "x-amz-meta-nickname") |> RFC2047.parse_encoded_word,
      description: Map.get(headers, "x-amz-meta-description") |> RFC2047.parse_encoded_word,
      venue: Map.get(headers, "x-amz-meta-venue") |> RFC2047.parse_encoded_word,
      meta: Map.get(headers, "x-amz-meta-meta") |> RFC2047.parse_encoded_word,
    }
    Cachex.put!(:image_cache, key, image)
    image) end)
  end

  def list_images(gallery, limit \\ nil) do
    get_images_by_prefix(gallery <> "/", limit)
  end

  def get_image!(prefix) do
    get_images_by_prefix(prefix, 1) |> hd
  end

  def create_image(key, file_binary, nickname, description, venue, meta) do
    {mimetype, _} = ExImageInfo.type(file_binary)
    %{headers: headers_list} = ExAws.S3.put_object(bucket(), key, file_binary,
      content_type: mimetype,
      content_disposition: "attachment",
      meta: [
        {:nickname, nickname},
        {:description, description},
        {:venue, venue},
        {:meta, meta},
      ] |> Enum.filter(&elem(&1, 1))
    ) |> ExAws.request!
    %{"Date" => date_string} = Map.new(headers_list)
    date = Timex.parse!(date_string, "{RFC1123}")
    image = %Image{
      key: key,
      last_modified: date,
      nickname: nickname,
      description: description,
      venue: venue,
      meta: meta
    }
    Cachex.put!(:image_cache, key, image)
    image
  end

  def delete_image(key) do
    ExAws.S3.delete_object(bucket(), key) |> ExAws.request!
    Cachex.del!(:image_cache, key)
  end
end
