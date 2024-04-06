# Polaroids

A live updating image gallery which can be posted to using HTTP POST requests and stores images in S3 compatible storage.

Demo instance: https://polaroids.yuustan.space/g/cute

Uploading a picture:

```
curl -F file=@img000017.jpg -F description="plushies" -F nickname=hermlon -F venue="at the aquarium" "https://polaroids.yuustan.space/g/cute"
```

## Development

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
