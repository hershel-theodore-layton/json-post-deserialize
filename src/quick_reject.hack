/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\JsonCheck;

use namespace HH\Lib\Str;

/**
 * Returns `NO_DOCUMENT` if `$json` does not contain a JSON document.
 * Returns `SYNTAX_ERROR` for a subset of syntax errors which overlaps
 *   with the set of syntax errors that get past `\json_decode_with_error()`.
 * Returns `OK` for all other inputs.
 * 
 * If `quick_reject()` returns `OK`, that does not mean that
 * your JSON document is guaranteed to be valid. It just means
 * that the document is not invalid in a way that can be decoded
 * by `\json_decode_with_error()`. This relaxed requirement makes the
 * `quick_reject()` function implementation a lot simpler and
 * means it does not need to do work that `\json_decode_with_error()`
 * just did.
 */
function quick_reject(string $json)[]: Result {
  $length = Str\length($json);
  $state = _Private\State::INITIAL;

  for ($i = 0; $i < $length; ++$i) {
    $state = _Private\STATE_MACHINE[$state * 256 + \ord($json[$i])];
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
