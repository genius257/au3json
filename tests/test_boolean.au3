#include "../au3pm/au3unit/testCase.au3"
#include "../json.au3"

Global Const $sJson = 'true'

#Region Decode
    Global $vJson = _json_decode($sJson)

    assertSame(0, @error, $vJson)

    assertInternalType('Boolean', $vJson)
#EndRegion Decode

#Region Encode
    Global $sJson2 = _json_encode($vJson)

    assertSame(0, @error, $sJson2)

    assertSame('true', $sJson2)
#EndRegion Encode

#Region Encode pretty
    $sJson2 = _json_encode_pretty($vJson)

    assertSame(0, @error, $sJson2)

    assertSame(StringFormat('true'), $sJson2)
#EndRegion Encode pretty

Global Const $sJson3 = 'false'

#Region Decode
    Global $vJson = _json_decode($sJson3)

    assertSame(0, @error, $vJson)

    assertInternalType('Boolean', $vJson)
#EndRegion Decode

#Region Encode
    Global $sJson2 = _json_encode($vJson)

    assertSame(0, @error, $sJson2)

    assertSame('false', $sJson2)
#EndRegion Encode

#Region Encode pretty
    $sJson2 = _json_encode_pretty($vJson)

    assertSame(0, @error, $sJson2)

    assertSame(StringFormat('false'), $sJson2)
#EndRegion Encode pretty

