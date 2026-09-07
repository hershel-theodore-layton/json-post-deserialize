/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\Project_oQ5p297cYuT0\GeneratedTestChain;

use namespace HTL\TestChain;
use type HTL\Pragma\Pragmas;

<<file: Pragmas(vec['PhaLinters', 'digest:ac28feadf59afc834be6'])>>

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroupAsync(\HTL\JsonCheck\usage_async<>);
}
