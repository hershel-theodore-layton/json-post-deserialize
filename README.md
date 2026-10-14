# JSON Post Deserialize

_A fast to run verification to run after json_decode()_

## Why?

`\json_decode()` can parse invalid JSON. If you want to
store the JSON and expect to be able to parse it in the
future, you should check it is not invalid JSON first.
Future versions of HHVM might not parse invalid JSON
the same way. Other programming environments, like Python,
Go, or JavaScript certainly don't.

## How?

Use `\json_decode_with_error()`, then check both its error and
`\HTL\JsonCheck\quick_reject()`:

```hack
use namespace HTL\JsonCheck;
use function json_decode_with_error;
use type InvalidArgumentException;

$error = null;
$decoded = json_decode_with_error($json, inout $error, true);
if (
  $error is nonnull ||
  JsonCheck\quick_reject($json) !== JsonCheck\Result::OK
) {
  throw new InvalidArgumentException('Invalid JSON document.');
}
// Use $decoded or store $json only after both checks succeed.
```

## Why do this in Hack?

There is no function accessible to Hack that can validate
a JSON document. If you want to call a real JSON parser,
you'd need to call an external process. The overhead of
copying the JSON string to the external process outweighs
the cost of the hot loop in `quick_reject()`.
