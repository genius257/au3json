#include "../au3pm/au3unit/testCase.au3"
#include "../json.au3"

;General formatting:
assertEquals(StringFormat('[]'), _json_encode_pretty(_json_decode('[]')))
assertEquals(StringFormat('{}'), _json_encode_pretty(_json_decode('{}')))
assertEquals(stringformat('{\n    "key": "value",\n    "key2": "value2"\n}'), _json_encode_pretty(_json_decode('{"key": "value", "key2": "value2"}')))
assertEquals(stringformat('[\n    1,\n    "2",\n    false,\n    null\n]'), _json_encode_pretty(_json_decode('[1, "2", false, null]')))
assertEquals(StringFormat('{\n    "key": [\n        {\n            "key": "value"\n        }\n    ]\n}'), _json_encode_pretty(_json_decode('{"key": [{"key": "value"}]}')))
assertEquals(StringFormat('[\n    {\n        "key": [\n            "value"\n        ]\n    }\n]'), _json_encode_pretty(_json_decode('[{"key": ["value"]}]')))

;Indentation:
assertEquals(StringFormat('{\n"key": "value",\n"key2": "value2"\n}'), _json_encode_pretty(_json_decode('{"key": "value", "key2": "value2"}'), 0))
assertEquals(StringFormat('{\n "key": "value",\n "key2": "value2"\n}'), _json_encode_pretty(_json_decode('{"key": "value", "key2": "value2"}'), 1))
assertEquals(StringFormat('{\n  "key": "value",\n  "key2": "value2"\n}'), _json_encode_pretty(_json_decode('{"key": "value", "key2": "value2"}'), 2))
assertEquals(StringFormat('{\n\t"key": "value",\n\t"key2": "value2"\n}'), _json_encode_pretty(_json_decode('{"key": "value", "key2": "value2"}'), @TAB))

;Replacer for unsupported types:
assertEquals('null', _json_encode_pretty(Default))
Func __replacer($v)
    Return '__REPLACED__'
EndFunc
assertEquals('"__REPLACED__"', _json_encode_pretty(Default, 4, __replacer))

;AutoIt multidimensional arrays:
Global $aArray = [[[1,11,111],[2,22,222],[3,33,333]],[[4,44,444],[5,55,555],[6,66,666]],[[7,77,777],[8,88,888],[9,99,999]]]
$expected = _
'[\n'& _
'  [\n'& _
'    [\n'& _
'      1,\n'& _
'      11,\n'& _
'      111\n'& _
'    ],\n'& _
'    [\n'& _
'      2,\n'& _
'      22,\n'& _
'      222\n'& _
'    ],\n'& _
'    [\n'& _
'      3,\n'& _
'      33,\n'& _
'      333\n'& _
'    ]\n'& _
'  ],\n'& _
'  [\n'& _
'    [\n'& _
'      4,\n'& _
'      44,\n'& _
'      444\n'& _
'    ],\n'& _
'    [\n'& _
'      5,\n'& _
'      55,\n'& _
'      555\n'& _
'    ],\n'& _
'    [\n'& _
'      6,\n'& _
'      66,\n'& _
'      666\n'& _
'    ]\n'& _
'  ],\n'& _
'  [\n'& _
'    [\n'& _
'      7,\n'& _
'      77,\n'& _
'      777\n'& _
'    ],\n'& _
'    [\n'& _
'      8,\n'& _
'      88,\n'& _
'      888\n'& _
'    ],\n'& _
'    [\n'& _
'      9,\n'& _
'      99,\n'& _
'      999\n'& _
'    ]\n'& _
'  ]\n'& _
']'
assertEquals(StringFormat($expected), _json_encode_pretty($aArray, 2))
Global $aArray[2][2][0]
$expected = _
'[\n'& _
'  [\n'& _
'    [],\n'& _
'    []\n'& _
'  ],\n'& _
'  [\n'& _
'    [],\n'& _
'    []\n'& _
'  ]\n'& _
']'
assertEquals(StringFormat($expected), _json_encode_pretty($aArray, 2))