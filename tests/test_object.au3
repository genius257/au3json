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

    assertSame(StringFormat('{\n    "array": [],\n    "object": {},\n    "string": "",\n    "number": 1,\n    "true": true,\n    "false": false,\n    "null": null\n}'), $sJson2)
#EndRegion Encode pretty
