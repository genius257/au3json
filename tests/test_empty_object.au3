#include "../au3pm/au3unit/testCase.au3"
#include "../json.au3"

Global Const $sJson = '{}'

#Region Decode
    Global $vJson = _json_decode($sJson)

    assertSame(0, @error)

    assertInternalType('Map', $vJson)

    assertSame(0, UBound($vJson))
#EndRegion Decode

#Region Encode
    Global $sJson2 = _json_encode($vJson)

    assertSame(0, @error, $sJson2)

    assertSame("{}", $sJson2)
#EndRegion Encode

#Region Encode pretty
    $sJson2 = _json_encode_pretty($vJson)

    assertSame(0, @error, $sJson2)

    assertSame("{}", $sJson2)
#EndRegion Encode pretty
