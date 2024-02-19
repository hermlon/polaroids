defmodule Polaroids.Gallery do
  @moduledoc """
  The Gallery context.
  """

  alias Polaroids.Helpers.RFC2047
  alias Polaroids.Gallery.Image

  def static_url(key), do: "https://r2.yuustan.space/" <> key

  defp get_keys_in_bucket(prefix) do
    %{body: %{contents: images}} = ExAws.S3.list_objects("polaroids", prefix: prefix) |> ExAws.request!
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
    %{headers: headers_list} = ExAws.S3.head_object("polaroids", key) |> ExAws.request!
    headers = Map.new(headers_list)
    %Image{
      key: key,
      last_modified: Timex.parse!(last_modified, "{ISO:Extended:Z}"),
      nickname: Map.get(headers, "x-amz-meta-nickname") |> RFC2047.parse_encoded_word,
      description: Map.get(headers, "x-amz-meta-description") |> RFC2047.parse_encoded_word,
      venue: Map.get(headers, "x-amz-meta-venue") |> RFC2047.parse_encoded_word
    } end)
  end

  def list_images(gallery, limit \\ nil) do
    get_images_by_prefix(gallery <> "/", limit)
  end

  def get_image!(prefix) do
    get_images_by_prefix(prefix, 1) |> hd
  end

  def create_image(key, file_binary, nickname, description, venue) do
    %{headers: headers_list} = ExAws.S3.put_object("polaroids", key, file_binary, meta: [
      {:nickname, nickname},
      {:description, description},
      {:venue, venue}] |> Enum.filter(&elem(&1, 1))
    ) |> ExAws.request!
    %{"Date" => date_string} = Map.new(headers_list)
    date = Timex.parse!(date_string, "{RFC1123}")
    %Image{
      key: key,
      last_modified: date,
      nickname: nickname,
      description: description,
      venue: venue
    }
  end

  def delete_image(key) do
    ExAws.S3.delete_object("polaroids", key) |> ExAws.request!
  end
end
