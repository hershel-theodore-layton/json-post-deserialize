/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\JsonCheck;

use namespace HH\Lib\{C, Dict, IO, Math, Str, Vec};
use type HTL\JsonCheck\_Private\State;

<<__EntryPoint>>
async function write_state_machine_async()[defaults]: Awaitable<void> {
  $code = <<<'HACK'
/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\JsonCheck\_Private;

const vec<State> STATE_MACHINE = vec[
@here
];

HACK;

  $whitespace = " \n\r\t";
  $digit = '0123456789';
  $non_zero_digit = '123456789';
  // All the letters from true, false, null
  $constants = 'truefalsnu';
  // '{}[]' Start and end of object/array.
  // ','    Element separator for object and array.
  // ':'    Key value separator for object.
  $structures = '{}[],:';

  $table = (new StateMachineBuilder())
    ->inState(
      State::NEUTRAL,
      dict[
        $whitespace => State::NEUTRAL,
        '"' => State::IN_STRING,
        '-' => State::MINUS,
        '0' => State::ZERO,
        $non_zero_digit => State::IN_NUMBER,
        $structures => State::NEUTRAL,
        $constants => State::NEUTRAL,
      ],
      State::INVALID,
    )
    ->inState(
      State::INITIAL,
      dict[
        $whitespace => State::INITIAL,
        '"' => State::IN_STRING,
        '-' => State::MINUS,
        '0' => State::ZERO,
        $non_zero_digit => State::IN_NUMBER,
        $structures => State::NEUTRAL,
        $constants => State::NEUTRAL,
      ],
      State::INVALID,
    )
    ->inState(
      State::IN_STRING,
      dict[
        '\\' => State::ESCAPE,
        '"' => State::NEUTRAL,
      ],
      State::IN_STRING,
    )
    ->inState(State::ESCAPE, dict[], State::IN_STRING)
    ->inState(
      State::IN_NUMBER,
      dict[
        $digit => State::IN_NUMBER,
        '.' => State::PERIOD,
        'eE+-' => State::IN_NUMBER,
      ],
      State::NEUTRAL,
    )
    ->inState(
      State::MINUS,
      dict[
        $non_zero_digit => State::IN_NUMBER,
        '0' => State::ZERO,
      ],
      State::INVALID,
    )
    ->inState(State::PERIOD, dict[$digit => State::IN_NUMBER], State::INVALID)
    ->inState(
      State::ZERO,
      dict[
        '.' => State::PERIOD,
        'eE' => State::IN_NUMBER,
        $non_zero_digit => State::INVALID,
      ],
      State::NEUTRAL,
    )
    ->inState(State::INVALID, dict[], State::INVALID)
    ->generate();

  await IO\request_output()->writeAllAsync(Str\replace($code, '@here', $table));
}

final class StateMachineBuilder {
  private dict<State, vec<State>> $transitions = dict[];

  public function inState(
    State $state,
    dict<string, State> $transitions,
    State $else,
  )[write_props]: this {
    $actions = Vec\fill(256, $else);

    foreach ($transitions as $chars => $to) {
      for ($i = 0; $i < Str\length($chars); ++$i) {
        $actions[\ord($chars[$i])] = $to;
      }
    }

    $this->transitions[$state] = $actions;

    return $this;
  }

  public function generate()[defaults]: string {
    $transitions = Dict\sort_by_key($this->transitions);
    invariant(
      C\count($transitions) - 1 === C\last_keyx($transitions),
      'Transitions incomplete: %s',
      Str\join(Vec\keys($transitions), ', '),
    );

    $_error = null;
    return Vec\flatten($transitions)
      |> Vec\map_with_key(
        $$,
        ($i, $state) ==> {
          $constant = State::getNames()[$state];
          $pad = 10 - Str\length($constant);
          $char = $i % 256;
          return Str\format(
            '  State::%s, //%s%s %s',
            $constant,
            Str\repeat(' ', $pad),
            State::getNames()[Math\int_div($i, 256) as State],
            static::prettyChar($char),
          );
        },
      )
      |> Str\join($$, "\n");
  }

  private static function prettyChar(int $char)[defaults]: string {
    if ($char < 0x20 || $char > 0x7e) {
      return '\\x'.Str\pad_left(\dechex($char), 2, '0');
    }

    if ($char === 0x20) {
      return 'SPACE';
    }

    if ($char === 0x27) {
      return '"';
    }

    if ($char === 0x2f) {
      return '/';
    }

    if ($char === 0x5c) {
      return '\\';
    }

    $_error = null;
    return \json_encode_with_error(\chr($char), inout $_error)
      |> Str\trim($$, '"');
  }
}
