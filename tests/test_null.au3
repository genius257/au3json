#include "../au3pm/au3unit/testCase.au3"
#include "../json.au3"

Global Const $sJson = 'null'

#Region Decode
    Global $vJson = _json_decode($sJson)

    assertSame(0, @error, $vJson)

    assertInternalType('Keyword', $vJson)
#EndRegion Decode

#Region Encode
    Global $sJson2 = _json_encode($vJson)

    assertSame(0, @error, $sJson2)

    assertSame('null', $sJson2)
#EndRegion Encode

#Region Encode pretty
    $sJson2 = _json_encode_pretty($vJson)

    assertSame(0, @error, $sJson2)

    assertSame(StringFormat('null'), $sJson2)
#EndRegion Encode pretty
