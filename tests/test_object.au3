#include "../au3pm/au3unit/testCase.au3"
#include "../json.au3"

Global Const $sJson = '{"array": [], "object": {}, "string": "", "number": 1, "true": true, "false": false, "null": null}'

#Region Decode
    Global $vJson = _json_decode($sJson)

    assertSame(0, @error, $vJson)

    assertInternalType('Map', $vJson)

    assertSame(7, UBound($vJson))
#EndRegion Decode

#Region Encode
    Global $sJson2 = _json_encode($vJson)

    assertSame(0, @error, $sJson2)

    assertSame('{"array":[],"object":{},"string":"","number":1,"true":true,"false":false,"null":null}', $sJson2)
#EndRegion Encode

#Region Encode pretty
    $sJson2 = _json_encode_pretty($vJson)

    assertSame(0, @error, $sJson2)

    assertSame(StringFormat('{\r\n    "array": [],\r\n    "object": {},\r\n    "string": "",\r\n    "number": 1,\r\n    "true": true,\r\n    "false": false,\r\n    "null": null\r\n}'), $sJson2)
#EndRegion Encode pretty
