# au3json
A small JSON library for AutoIt3

Based on the code from [here](http://notes.eatonphil.com/writing-a-simple-json-parser.html)

## usage

```AutoIt3
#include "json.au3"

$sJson = '{"name":"John","age":31,"city":"New York"}'

$oJson = json_parse(json_lex($sJson))[0]

MsgBox(0, "", $oJson.Item('name'))
```
