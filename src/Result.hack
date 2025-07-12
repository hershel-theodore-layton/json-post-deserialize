/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\JsonCheck;

enum Result: int {
  OK = 0;
  NO_DOCUMENT = 1;
  SYNTAX_ERROR = 2;
}
