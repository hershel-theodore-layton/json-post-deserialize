/** json-post-deserialize is MIT licensed, see /LICENSE. */
namespace HTL\JsonCheck\_Private;

enum State: int as int {
  NEUTRAL = 0;
  IN_STRING = 1;
  ESCAPE = 2;
  MINUS = 3;
  IN_NUMBER = 4;
  PERIOD = 5;
  INITIAL = 6;
  INVALID = 7;
}
