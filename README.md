# JSON Post Deserialize

_A fast to run verification to run after json_decode()_

## Why?

`\json_decode()` can parse invalid JSON. If you want to
store the JSON and expect to be able to parse it in the
future, you should check it is not invalid JSON first.
Future versions of hhvm might not parse invalid JSON
the same way. Other programming environments, like Python,
Go, or JavaScript certainly don't.

## How?

After calling `\json_decode_with_error()`, you should check the
`$error` variable. If this is `null`, you might still have
parsed invalid JSON. `\HTL\JsonCheck\quick_reject(string $json)`
will let you know that this happened. `quick_reject()` does
not return an error for many invalid JSON documents, but
it does return an error for every invalid JSON document that
gets past `\json_decode_with_error()`.

## Why do this in Hack?

There is no function accessible to Hack that can validate
a JSON document. If you want to call a real JSON parser,
you'd need to call an external process. The overhead of
copying the json string to the external process outweighs
the cost of the hot loop in `quick_reject()`.
