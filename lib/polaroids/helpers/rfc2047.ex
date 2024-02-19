defmodule Polaroids.Helpers.RFC2047 do
  # copied from https://github.com/DockYard/elixir-mail/blob/master/lib/mail/parsers/rfc_2822.ex since it's private

  def parse_encoded_word(nil), do: nil

  # See https://tools.ietf.org/html/rfc2047
  def parse_encoded_word(""), do: ""

  def parse_encoded_word(<<"=?", value::binary>>) do
    case String.split(value, "?", parts: 4) do
      [_charset, encoding, encoded_string, <<"=", remainder::binary>>] ->
        decoded_string =
          case String.upcase(encoding) do
            "Q" ->
              Mail.Encoders.QuotedPrintable.decode(encoded_string)

            "B" ->
              Mail.Encoders.Base64.decode(encoded_string)
          end

        decoded_string <> parse_encoded_word(remainder)

      _ ->
        # Not an encoded word, moving on
        "=?" <> parse_encoded_word(value)
    end
  end

  def parse_encoded_word(<<char::utf8, rest::binary>>),
    do: <<char::utf8, parse_encoded_word(rest)::binary>>
end
