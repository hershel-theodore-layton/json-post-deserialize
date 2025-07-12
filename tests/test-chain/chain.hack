/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\Project_oQ5p297cYuT0\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroupAsync(\HTL\JsonCheck\usage_async<>);
}
