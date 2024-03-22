#include "../au3pm/au3unit/testCase.au3"
#include "../json.au3"

Global $result

$result = _json_decode('{"key:""}')
assertSame(1, @error)
assertSame('Unexpected character: """ at offset: 8', $result)

$result = _json_decode('["Hello", 3.14, , true]')
assertSame(1, @error)
assertSame('Unexpected character: "," at offset: 17', $result)

$result = _json_decode('"John says "Hello!""')
assertSame(1, @error)
assertSame('Expected end of string, found: "H" at offset: 13', $result)

$result = _json_decode('1.0.0')
assertSame(1, @error)
assertSame('Expected end of string, found: "." at offset: 4', $result)

$result = _json_decode('truE')
assertSame(1, @error)
assertSame('Expected "true", found: "truE" at offset: 1', $result)

$result = _json_decode('falsE')
assertSame(1, @error)
assertSame('Expected "false", found: "falsE" at offset: 1', $result)

$result = _json_decode('nulL')
assertSame(1, @error)
assertSame('Expected "null", found: "nulL" at offset: 1', $result)
