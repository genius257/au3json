# au3json
A small JSON library for AutoIt3

## usage

```AutoIt3
#include "json.au3"

$sJson = '{"name":"John","age":31,"city":"New York"}'

$oJson = _json_decode($sJson)

MsgBox(0, "", $oJson['name'])

; change value of $__g_json_sPrettyIndentation, to adjust identation in pretty print
ConsoleWrite(_json_encode_pretty($oJson)&@CRLF)
```
