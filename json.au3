#include-once
#include <String.au3>

Func json_decode($sJson)
    local $iIndex = 1
    Return __json_decode($sJson, $iIndex)
EndFunc

Func __json_decode(ByRef $sJson, ByRef $iIndex)
    While 1
        Switch StringMid($sJson, $iIndex, 1)
            Case '{'
                Return __json_decode_object($sJson, $iIndex)
            Case '['
                Return __json_decode_array($sJson, $iIndex)
            Case '"'
                Return __json_decode_string($sJson, $iIndex)
            Case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-'
                Return __json_decode_number($sJson, $iIndex)
            Case 't'
                Return __json_decode_true($sJson, $iIndex)
            Case 'f'
                Return __json_decode_false($sJson, $iIndex)
            Case 'n'
                Return __json_decode_null($sJson, $iIndex)
            Case ' ', @LF, @CR, @TAB
                $iIndex += 1
            Case ''
                ContinueCase
            Case Else
                ConsoleWriteError(StringMid($sJson, $iIndex, 5)&@CRLF)
                ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                Return SetError(1, 1, Null)
        EndSwitch
    WEnd
EndFunc

Func __json_decode_object(ByRef $sJson, ByRef $iIndex)
    $iIndex += 1
    Local $object[]
    Local $key
    While 1
        Switch StringMid($sJson, $iIndex, 1)
            Case '}'
                $iIndex += 1
                Return $object
            Case '"'
                $key = __json_decode_string($sJson, $iIndex)
            Case ' ', @LF, @CR, @TAB
                $iIndex += 1
                ContinueLoop
            Case ''
                ContinueCase
            Case Else
                ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                Return SetError(1, 1, Null)
        EndSwitch

        While 1
            Switch StringMid($sJson, $iIndex, 1)
                Case ':'
                    $iIndex += 1
                    ExitLoop
                Case ' ', @LF, @CR, @TAB
                    $iIndex += 1
                Case ''
                    ContinueCase
                Case Else
                    ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                    Return SetError(1, 1, Null)
            EndSwitch
        WEnd

        $object[$key] = __json_decode($sJson, $iIndex)
        If @error <> 0 Then
            ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
            Return SetError(1, 1, Null)
        EndIf

        While 1
            Switch StringMid($sJson, $iIndex, 1)
                Case ','
                    $iIndex += 1
                    ExitLoop
                Case ' ', @LF, @CR, @TAB
                    $iIndex += 1
                Case '}'
                    $iIndex += 1
                    Return $object
                Case ''
                    ContinueCase
                Case Else
                    ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                    Return SetError(1, 1, Null)
            EndSwitch
        WEnd
    WEnd
EndFunc

Func __json_decode_string(ByRef $sJson, ByRef $iIndex)
    $iIndex += 1
    Local $string = ""
    Local $c

    While 1
        $c = StringMid($sJson, $iIndex, 1)
        $iIndex += 1
        Switch $c
            Case '"'
                Return $string
            Case '\'
                $c = StringMid($sJson, $iIndex, 1)
                $iIndex += 1
                Switch $c
                    Case '"', '\', '/'
                        $string &= $c
                    Case 'b'
                        $string &= Chr(8)
                    Case 'f'
                        $string &= Chr(12)
                    Case 'n'
                        $string &= Chr(10)
                    Case 'r'
                        $string &= Chr(13)
                    Case 't'
                        $string &= Chr(9)
                    Case ''
                        ContinueCase
                    Case Else
                        ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                        Return SetError(1, 1, Null)
                EndSwitch
            Case ''
                ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                Return SetError(1, 1, Null)
            Case Else
                $string &= $c
        EndSwitch
    WEnd
EndFunc

Func __json_decode_array(ByRef $sJson, ByRef $iIndex)
    $iIndex += 1
    Local $array[100000] ;FIXME: change inital array size and support dynamic size
    Local $i = 0
    While 1
        Switch StringMid($sJson, $iIndex, 1)
            Case ']'
                Redim $array[$i+1]
                $iIndex += 1
                Return $array
            Case ' ', @LF, @CR, @TAB
                $iIndex += 1
                ContinueLoop
            Case ''
                ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                Return SetError(1, 1, Null)
            Case Else
                $array[$i] = __json_decode($sJson, $iIndex)
                If @error <> 0 Then
                    ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                    Return SetError(1, 1, Null)
                EndIf
                $i+=1
        EndSwitch

        While 1
            Switch StringMid($sJson, $iIndex, 1)
                Case ','
                    $iIndex += 1
                    ExitLoop
                Case ' ', @LF, @CR, @TAB
                    $iIndex += 1
                Case ']'
                    Redim $array[$i]
                    $iIndex += 1
                    Return $array
                Case ''
                    ContinueCase
                Case Else
                    ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&StringMid($sJson, $iIndex, 1)&@CRLF)
                    Return SetError(1, 1, Null)
            EndSwitch
        WEnd
    WEnd
EndFunc

Func __json_decode_number(ByRef $sJson, ByRef $iIndex)
    Local $number = ""
    If StringMid($sJson, $iIndex, 1) = '-' Then
        $number &= StringMid($sJson, $iIndex, 1)
        $iIndex += 1
    EndIf

    If Not StringIsDigit(StringMid($sJson, $iIndex, 1)) Then Return SetError(1, @ScriptLineNumber, 'Expected digit, found: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)

    While 1
        Switch StringMid($sJson, $iIndex, 1)
            Case '0' To '9'
                $number &= StringMid($sJson, $iIndex, 1)
                $iIndex += 1
                ContinueLoop
            Case Else
                ExitLoop
        EndSwitch
    WEnd

    ;Fraction
    If StringMid($sJson, $iIndex, 1) = '.' Then
        $number &= StringMid($sJson, $iIndex, 1)
        $iIndex += 1

        If Not StringIsDigit(StringMid($sJson, $iIndex, 1)) Then Return SetError(1, @ScriptLineNumber, 'Expected digit, found: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)

        While 1
            Switch StringMid($sJson, $iIndex, 1)
                Case '0' To '9'
                    $number &= StringMid($sJson, $iIndex, 1)
                    $iIndex += 1
                    ContinueLoop
                Case Else
                    ExitLoop
            EndSwitch
        WEnd
    EndIf

    ;Exponent
    If StringLower(StringMid($sJson, $iIndex, 1)) = 'e' Then
        $number &= StringMid($sJson, $iIndex, 1)
        $iIndex += 1

        Switch StringMid($sJson, $iIndex, 1)
            Case '+', '-'
                $number &= StringMid($sJson, $iIndex, 1)
                $iIndex += 1
        EndSwitch

        If Not StringIsDigit(StringMid($sJson, $iIndex, 1)) Then Return SetError(1, @ScriptLineNumber, 'Expected digit, found: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)

        While 1
            Switch StringMid($sJson, $iIndex, 1)
                Case '0' To '9'
                    $number &= StringMid($sJson, $iIndex, 1)
                    $iIndex += 1
                    ContinueLoop
                Case Else
                    ExitLoop
            EndSwitch
        WEnd
    EndIf

    Local $value = Execute($number)
    If @error <> 0 Then
        Return SetError(1, @ScriptLineNumber, 'Failed to parse number: "' & $value & '" at offset: ' & $iIndex)
    EndIf
    Return $value
EndFunc

Func __json_decode_true(ByRef $sJson, ByRef $iIndex)
    If Not (StringMid($sJson, $iIndex, 4) == "true") Then
        ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
        Return SetError(1, 1, Null)
    EndIf
    $iIndex += 4
    Return True
EndFunc

Func __json_decode_false(ByRef $sJson, ByRef $iIndex)
    If Not (StringMid($sJson, $iIndex, 5) == "false") Then
        ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
        Return SetError(1, 1, Null)
    EndIf
    $iIndex += 5
    Return False
EndFunc

Func __json_decode_null(ByRef $sJson, ByRef $iIndex)
    If Not (StringMid($sJson, $iIndex, 4) == "null") Then
        ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
        Return SetError(1, 1, Null)
    EndIf
    $iIndex += 4
    Return Null
EndFunc

Func json_encode($vJson)
    Return __json_encode($vJson)
EndFunc

Func __json_encode(ByRef $v)
    Switch VarGetType($v)
        Case "Map"
            Return __json_encode_map($v)
        Case "Array"
            Return __json_encode_array($v)
        Case "String"
            Return __json_encode_string($v)
        Case "Int32"
            ContinueCase
        Case "Int64"
            ContinueCase
        Case "Double"
            Return __json_encode_number($v)
        Case "Bool"
            Return __json_encode_bool($v)
        Case "Keyword"
            If Not ($v = Null) Then ContinueCase
            Return __json_encode_null($v)
        Case Else
            ConsoleWriteError("Unsupported type: "&VarGetType($v)&@CRLF)
            Return SetError(1, 1, Null)
    EndSwitch
EndFunc

Func __json_encode_map(ByRef $map)
    Local $sJson = "{"
    For $key In MapKeys($map)
        $sJson &= __json_encode_string($key) & ":" & __json_encode($map[$key]) & ","
        IF @error <> 0 Then Return SetError(@error, @extended, Null)
    Next
    Return StringMid($sJson, 1, StringLen($sJson) - 1) & "}"
EndFunc

Func __json_encode_array(ByRef $array)
    Local $sJson = "["
    For $key In $array
        ;FIXME support multi-dimensional arrays
        $sJson &= __json_encode($key) & ","
        IF @error <> 0 Then Return SetError(@error, @extended, Null)
    Next
    Return StringMid($sJson, 1, StringLen($sJson) - 1) & "]"
EndFunc

Func __json_encode_string(ByRef $s)
    Return '"' & StringRegExpReplace($s, '["\\]', '\\$0') & '"'
EndFunc

Func __json_encode_number(ByRef $n)
    Return String($n)
EndFunc

Func __json_encode_bool(ByRef $b)
    Return $b ? "true" : "false"
EndFunc

Func __json_encode_null(ByRef $n)
    Return "null"
EndFunc

Func json_encode_pretty($vJson)
    Return __json_encode_pretty($vJson, 0)
EndFunc

Global $json_pretty_sIndentation = "    "

Func __json_encode_pretty(ByRef $v, $iLevel)
    Switch VarGetType($v)
        Case "Map"
            Return __json_encode_map_pretty($v, $iLevel)
        Case "Array"
            Return __json_encode_array_pretty($v, $iLevel)
        Case "String"
            Return __json_encode_string($v)
        Case "Int32"
            ContinueCase
        Case "Int64"
            ContinueCase
        Case "Double"
            Return __json_encode_number($v)
        Case "Bool"
            Return __json_encode_bool($v)
        Case "Keyword"
            If Not ($v = Null) Then ContinueCase
            Return __json_encode_null($v)
        Case Else
            ConsoleWriteError("Unsupported type: "&VarGetType($v)&@CRLF)
            Return SetError(1, 1, Null)
    EndSwitch
EndFunc

Func __json_encode_map_pretty(ByRef $map, $iLevel)
    Local $sJson = "{" & @CRLF
    For $key In MapKeys($map)
        $sJson &= _StringRepeat($json_pretty_sIndentation, $iLevel + 1) & __json_encode_string($key) & ":" & __json_encode_pretty($map[$key], $iLevel + 1) & "," & @CRLF
        IF @error <> 0 Then Return SetError(@error, @extended, Null)
    Next
    Return StringMid($sJson, 1, StringLen($sJson) - 3) & _StringRepeat($json_pretty_sIndentation, $iLevel) & @CRLF & "}"
EndFunc

Func __json_encode_array_pretty(ByRef $array, $iLevel)
    Local $sJson = "[" & @CRLF
    For $key In $array
        ;FIXME support multi-dimensional arrays
        $sJson &= _StringRepeat($json_pretty_sIndentation, $iLevel + 1) & __json_encode_pretty($key, $iLevel + 1) & "," & @CRLF
        IF @error <> 0 Then Return SetError(@error, @extended, Null)
    Next
    Return StringMid($sJson, 1, StringLen($sJson) - 3) & @CRLF & _StringRepeat($json_pretty_sIndentation, $iLevel) & "]"
EndFunc
