/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\JsonCheck;

use namespace HH\Lib\{C, Dict, File, Str, Vec};
use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
async function usage_async(
  TestChain\Chain $chain,
)[defaults]: Awaitable<TestChain\Chain> {
  $read_dir = async $dir ==> await Vec\map_async(
    \glob($dir.'/*'),
    async $path ==> {
      $file = File\open_read_only($path);
      using $file->closeWhenDisposed();
      using $file->tryLockx(File\LockType::SHARED);
      return tuple(
        Str\split($path, '/') |> C\lastx($$),
        await $file->readAllAsync(),
      );
    },
  )
    |> Dict\map($$, $tuple ==> tuple($tuple[0], $tuple))
    |> Dict\from_entries($$);

  $err_of = ($json, bool $assoc)[] ==> {
    $error = null;
    \json_decode_with_error($json, inout $error, $assoc);
    return $error is null ? null : $error[0];
  };

  concurrent {
    $indeterminate = await $read_dir(__DIR__.'/fixtures/indeterminate');
    $invalid = await $read_dir(__DIR__.'/fixtures/invalid');
    $valid = await $read_dir(__DIR__.'/fixtures/valid');
  }

  return $chain->group(__FUNCTION__)
    ->testWith2Params(
      'valid',
      ()[] ==> $valid,
      ($_path, $json)[] ==> {
        // If the document is valid, assoc and non-assoc will not error. 
        expect($err_of($json, true))->toBeNull();
        expect($err_of($json, false))->toBeNull();
        // quick_reject will not reject valid json.
        expect(quick_reject($json))->toEqual(Result::OK);
      },
    )
    ->testWith2Params(
      'invalid',
      ()[] ==> $invalid,
      ($path, $json)[] ==> {
        if ($err_of($json, true) is null || $err_of($json, false) is null) {
          // quick_reject() only needs to return an error if
          // decoding (either assoc or non-assoc) does not yield an error.
          expect(quick_reject($json))->toEqual(
            $path === 'n_structure_no_data.json'
              ? Result::NO_DOCUMENT
              : Result::SYNTAX_ERROR,
          );
        }
      },
    )
    ->testWith2Params(
      'form feed after a number',
      ()[] ==> dict[
        'formfeed_after_zero' => tuple(null, "[0\f]"),
        'formfeed_after_number' => tuple(null, "[1\f]"),
      ],
      ($_, $json)[defaults] ==> {
        // Form feeds shouldn't be allowed whitespace, but older
        // versions of hhvm allow then where decoding to arrays.
        // The test suite did not include an example
        // of `\f` after an number that wasn't invalid for some
        // other reason, such as leading form feeds.
        expect($err_of($json, true))->toEqual(
          \HHVM_VERSION_ID >= 414000 ? \JSON_ERROR_CTRL_CHAR : null,
        );
        expect($err_of($json, false))->toEqual(\JSON_ERROR_CTRL_CHAR);
        expect(quick_reject($json))->toEqual(Result::SYNTAX_ERROR);
      },
    )
    ->testWith2Params(
      'indeterminate',
      ()[] ==> $indeterminate,
      ($path, $json) ==> {
        $hhvm_emits_error = keyset[
          'i_string_UTF-16LE_with_BOM.json',
          'i_string_UTF-8_invalid_sequence.json',
          'i_string_UTF8_surrogate_U+D800.json',
          'i_string_invalid_utf-8.json',
          'i_string_iso_latin_1.json',
          'i_string_lone_utf8_continuation_byte.json',
          'i_string_not_in_unicode_range.json',
          'i_string_overlong_sequence_2_bytes.json',
          'i_string_overlong_sequence_6_bytes.json',
          'i_string_overlong_sequence_6_bytes_null.json',
          'i_string_truncated-utf-8.json',
          'i_string_utf16BE_no_BOM.json',
          'i_string_utf16LE_no_BOM.json',
          'i_structure_UTF-8_BOM_empty_object.json',
        ];

        if (C\contains_key($hhvm_emits_error, $path)) {
          expect($err_of($json, true))->toBeNonnull();
          expect($err_of($json, false))->toBeNonnull();
          return;
        }

        expect($err_of($json, true))->toBeNull();
        expect($err_of($json, false))->toBeNull();
        expect(quick_reject($json))->toEqual(Result::OK);
      },
    );
}
