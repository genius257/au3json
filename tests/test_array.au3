#include "../au3pm/au3unit/testCase.au3"
#include "../json.au3"

Global Const $sJson = '[{},[],"",1,true,false,null]'

#Region Decode
    Global $vJson = _json_decode($sJson)

    assertSame(0, @error, $vJson)

    assertInternalType('Array', $vJson)

    assertSame(7, UBound($vJson))
#EndRegion Decode

#Region Encode
    Global $sJson2 = _json_encode($vJson)

    assertSame(0, @error, $sJson2)

    assertSame('[{},[],"",1,true,false,null]', $sJson2)
#EndRegion Encode

#Region Encode pretty
    $sJson2 = _json_encode_pretty($vJson)

    assertSame(0, @error, $sJson2)

    assertSame(StringFormat('[\r\n    {},\r\n    [],\r\n    "",\r\n    1,\r\n    true,\r\n    false,\r\n    null\r\n]'), $sJson2)
#EndRegion Encode pretty
