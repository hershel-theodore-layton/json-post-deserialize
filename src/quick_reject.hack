/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\JsonCheck;

use namespace HH\Lib\Str;
use function ord;

/**
 * Returns `NO_DOCUMENT` if `$json` does not contain a JSON document.
 * Returns `SYNTAX_ERROR` for a subset of syntax errors which overlaps
 *   with the set of syntax errors that get past `\json_decode_with_error()`.
 * Returns `OK` for all other inputs.
 *
 * This is not a standalone JSON validator: `OK` does not guarantee validity.
 * Check both the decoder error and this result.
 * This limited scope avoids repeating work already done by the decoder.
 */
function quick_reject(string $json)[]: Result {
  $length = Str\length($json);
  $state = _Private\State::INITIAL;

  for ($i = 0; $i < $length; ++$i) {
    $state = _Private\STATE_MACHINE[$state * 256 + ord($json[$i])];
  }

  switch ($state) {
    case _Private\State::INITIAL:
      return Result::NO_DOCUMENT;
    case _Private\State::IN_NUMBER:
    case _Private\State::NEUTRAL:
    case _Private\State::ZERO:
      return Result::OK;
    case _Private\State::ESCAPE:
    case _Private\State::IN_STRING:
    case _Private\State::INVALID:
    case _Private\State::MINUS:
    case _Private\State::PERIOD:
      return Result::SYNTAX_ERROR;
  }
}
