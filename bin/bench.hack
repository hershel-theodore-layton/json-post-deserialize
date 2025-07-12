/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\JsonCheck;

use namespace HH;
use namespace HH\Asio;
use namespace HH\Lib\{Str, Vec};
use function HTL\Pragma\pragma;

<<__EntryPoint>>
async function download_async()[defaults]: Awaitable<void> {
  $autoloader = __DIR__.'/../vendor/autoload.hack';
  if (HH\could_include($autoloader)) {
    require_once $autoloader;
    HH\dynamic_fun('Facebook\AutoloadMap\initialize')();
  }

  $cache_file = __DIR__.'/benchmark.json';
  $file_url =
    'https://raw.githubusercontent.com/simdjson/simdjson/master/jsonexamples/twitter.json';

  if (!\file_exists($cache_file)) {
    pragma('PhaLinters', 'fixme:no_string_interpolation');
    echo <<<IMPORTANT



[[[[ IMPORTANT ]]]]
The default benchmark for this project is a twitter.json file, which we download from:
$file_url
You can check the license of the repository here:
https://github.com/simdjson/simdjson/blob/master/LICENSE
The authors of simdjson use this file as a benchmark.
The file is complex enough to be tough to parse and validate, but very realisitic.
I did not create a specially crafted json file for this benchmark. https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number.
I do not claim that the authors of simdjson have licensed this file correctly.
If downloading or benchmarking with this file makes you uncomfortable, please exit this application now.
You can benchmark using a file you provide by placing the file at:
$cache_file
[[[[ IMPORTANT ]]]]


IMPORTANT;

    \readline('Press [enter] to download twitter.json from github.');
    \file_put_contents($cache_file, await Asio\curl_exec($file_url));
  }

  $mode = \HH\global_get('_GET') ?? \HH\global_get('argv')
    |> $$ is vec<_> ? Vec\drop($$, 1) : vec($$ as dict<_, _>)
    |> $$[0] ?? 'both'
    |> $$ as string;

  $should_parse = $mode === 'both' || $mode === 'parse';
  $should_reject = $mode === 'both' || $mode === 'reject';

  $json = \file_get_contents($cache_file);

  $error = null;
  $parsed = dict[];
  $result = Result::OK;

  $start = \clock_gettime_ns(\CLOCK_MONOTONIC);
  if ($should_parse) {
    $parsed = \json_decode_with_error(
      $json,
      inout $error,
      true,
      512,
      \JSON_FB_HACK_ARRAYS,
    );
  }

  if ($should_reject) {
    $result = quick_reject($json);
  }
  $end = \clock_gettime_ns(\CLOCK_MONOTONIC);

  $size_in_bytes = Str\length($json);
  $size_in_kb = $size_in_bytes / 1024.;
  $size_in_mb = $size_in_kb / 1024.;

  $time_in_nano_seconds = $end - $start;
  $time_in_millis = $time_in_nano_seconds / 1000. / 1000.;
  $time_in_seconds = $time_in_millis / 1000.;

  echo Str\format(
    "%s(%s, %s, %s) %gkB of JSON at %04d MB/s\n",
    $mode,
    $error is null ? 'OK' : $error[1],
    \gettype($parsed),
    Result::getNames()[$result],
    $size_in_kb,
    (int)($size_in_mb / $time_in_seconds),
  );
}
