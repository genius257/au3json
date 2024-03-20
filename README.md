# au3json
A small JSON library for AutoIt3

## usage

```au3
#include "json.au3"

$sJson = '{"name":"John","age":31,"city":"New York"}'

$oJson = _json_decode($sJson)

MsgBox(0, "", $oJson['name'])

; change value of $__g_json_sPrettyIndentation, to adjust identation in pretty print
ConsoleWrite(_json_encode_pretty($oJson)&@CRLF)
```

### Error handling

When an error occurs in a JSON function, @error is set to non zero and a string describing the error with offset position is returned.

```au3
#include "json.au3"

$sJson = '{"name":"John","age"}'

$oJson = _json_decode($sJson)

If @error <> 0 Then
    ConsoleWriteError($oJson&@CRLF) ; Unexpected character: "}" at offset: 21
    Exit
EndIf

ConsoleWrite($oJson['name']&@CRLF)
```

## Requirements

AutoIt version 3.3.14.0 or greater
