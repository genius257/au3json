#include-once
#include <String.au3>
#include <Array.au3>

Func _json_decode($sJson)
    local $iIndex = 1

    Local $vValue = __json_decode($sJson, $iIndex)

    Local $error = @error, $extended = @extended

    If @error = 0 And Not (StringMid($sJson, $iIndex, 1) = '') Then Return SetError(1, @ScriptLineNumber, 'Expected end of string, found: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)

    Return SetError($error, $extended, $vValue)
EndFunc

Func __json_decode(ByRef $sJson, ByRef $iIndex)
    Local $vValue
    While 1
        Switch StringMid($sJson, $iIndex, 1)
            Case '{'
                $vValue = __json_decode_object($sJson, $iIndex)
            Case '['
                $vValue = __json_decode_array($sJson, $iIndex)
            Case '"'
                $vValue = __json_decode_string($sJson, $iIndex)
            Case '0' To '9', '-'
                $vValue = __json_decode_number($sJson, $iIndex)
            Case 't'
                $vValue = __json_decode_true($sJson, $iIndex)
            Case 'f'
                $vValue = __json_decode_false($sJson, $iIndex)
            Case 'n'
                $vValue = __json_decode_null($sJson, $iIndex)
            Case ' ', @LF, @CR, @TAB
                $iIndex += 1
                ContinueLoop
            Case ''
                ContinueCase
            Case Else
                Return SetError(1, @ScriptLineNumber, 'Unexpected character: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)
        EndSwitch

        Return SetError(@error, @extended, $vValue)
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
                Return SetError(1, @ScriptLineNumber, 'Unexpected character: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)
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
                    Return SetError(1, @ScriptLineNumber, 'Unexpected character: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)
            EndSwitch
        WEnd

        $object[$key] = __json_decode($sJson, $iIndex)
        If @error <> 0 Then
            Return SetError(@error, @extended, $object[$key])
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
                    Return SetError(1, @ScriptLineNumber, 'Unexpected character: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)
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
                        Return SetError(1, @ScriptLineNumber, 'Unexpected escape character: "' & $c & '" at offset: ' & $iIndex)
                EndSwitch
            Case ''
                Return SetError(1, @ScriptLineNumber, 'Unexpected end of string at offset: ' & $iIndex)
            Case Else
                $string &= $c
        EndSwitch
    WEnd
EndFunc

Func __json_decode_array(ByRef $sJson, ByRef $iIndex)
    $iIndex += 1
    Local $array[16]
    Local $i = 0
    While 1
        Switch StringMid($sJson, $iIndex, 1)
            Case ']'
                Redim $array[$i]
                $iIndex += 1
                Return $array
            Case ' ', @LF, @CR, @TAB
                $iIndex += 1
                ContinueLoop
            Case ''
                Return SetError(1, @ScriptLineNumber, 'Unexpected end of string at offset: ' & $iIndex)
            Case Else
                $array[$i] = __json_decode($sJson, $iIndex)
                If @error <> 0 Then
                    Return SetError(@error, @extended, $array[$i])
                EndIf
                $i+=1
                If $i >= UBound($array) Then Redim $array[UBound($array)*2]
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
                    Return SetError(1, @ScriptLineNumber, 'Expected "," or "]", found: "' & StringMid($sJson, $iIndex, 1) & '" at offset: ' & $iIndex)
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
        Return SetError(1, @ScriptLineNumber, 'Expected "true", found: "' & StringMid($sJson, $iIndex, 4) & '" at offset: ' & $iIndex)
    EndIf
    $iIndex += 4
    Return True
EndFunc

Func __json_decode_false(ByRef $sJson, ByRef $iIndex)
    If Not (StringMid($sJson, $iIndex, 5) == "false") Then
        Return SetError(1, @ScriptLineNumber, 'Expected "false", found: "' & StringMid($sJson, $iIndex, 5) & '" at offset: ' & $iIndex)
    EndIf
    $iIndex += 5
    Return False
EndFunc

Func __json_decode_null(ByRef $sJson, ByRef $iIndex)
    If Not (StringMid($sJson, $iIndex, 4) == "null") Then
        Return SetError(1, @ScriptLineNumber, 'Expected "null", found: "' & StringMid($sJson, $iIndex, 4) & '" at offset: ' & $iIndex)
    EndIf
    $iIndex += 4
    Return Null
EndFunc

Func _json_encode($vJson)
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
            Return SetError(1, @ScriptLineNumber, 'Unsupported type: ' & VarGetType($v))
    EndSwitch
EndFunc

Func __json_encode_map(ByRef $map)
    if UBound($map) = 0 Then Return "{}"

    Local $sJson = "{"
    For $key In MapKeys($map)
        $sJson &= __json_encode_string($key) & ":" & __json_encode($map[$key]) & ","
        IF @error <> 0 Then Return SetError(@error, @extended, Null)
    Next
    Return StringMid($sJson, 1, StringLen($sJson) - 1) & "}"
EndFunc

Func __json_encode_array(ByRef $array)
    Local $iDimensions = UBound($array, 0)
    Local $aIndices[$iDimensions]
    For $iIndex = 0 To $iDimensions - 1
        $aIndices[$iIndex] = 0; Fill array with 0
        If UBound($array, $iIndex + 1) = 0 Then; Special handling for array dimention with length 0
            Redim $aIndices[$iIndex+1]; Resize array dimentions to first occurence of length zero, as no child elements can exist
            $iDimensions = $iIndex + 1

            Local $sArray = "[]"

            ; The loop will wrap the child element(s) in an array x times for each dimension
            For $iDimension = $iDimensions - 2 To 0 Step -1
                Local $sArrayParent = "["
                $sArrayParent &= $sArray
                For $y = 0 To UBound($array, $iDimension + 1)-2
                    $sArrayParent &= "," & $sArray
                Next
                $sArray = $sArrayParent & "]"
            Next
            Return $sArray
        EndIf
    Next

    Local $sJson = ""
    While 1
        For $iDimension = $iDimensions - 1 To 0 Step -1
            If $aIndices[$iDimension] = 0 Then
                $sJson &= "["
                ContinueLoop
            EndIf
            ExitLoop
        Next

        $sPosition = StringFormat('[%s]', _ArrayToString($aIndices, '][', 0, $iDimensions-1))
        $sJson &= __json_encode(Execute('$array'&$sPosition))

        If $aIndices[$iDimensions -1 ] < UBound($array, $iDimensions) - 1 Then
            $sJson &= ","
        EndIf

        For $iDimension = $iDimensions - 1 To 0 Step -1
            $aIndices[$iDimension] += 1

            If $aIndices[$iDimension] <= UBound($array, $iDimension + 1)-1 Then
                ; Current dimension index is not the last element, so we stop regrouping and exit the loop
                ExitLoop
            EndIf

            $sJson &= "]"

            If $iDimension = 0 Then ExitLoop 2

            If $aIndices[$iDimension - 1] < UBound($array, $iDimension) - 1 Then
                ; Parent index position is not the last element, so we add a comma, to accommodate the next sibling element
                $sJson &= ","
            EndIf

            ; Reset the index positon of the current dimension
            $aIndices[$iDimension] = 0
        Next
    WEnd
    Return $sJson
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

Func _json_encode_pretty($vJson)
    Return __json_encode_pretty($vJson, 0)
EndFunc

Global $__g_json_sPrettyIndentation = "    "

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
            Return SetError(1, @ScriptLineNumber, 'Unsupported type: ' & VarGetType($v))
    EndSwitch
EndFunc

Func __json_encode_map_pretty(ByRef $map, $iLevel)
    if UBound($map) = 0 Then Return "{}"

    Local $sJson = "{" & @CRLF
    For $key In MapKeys($map)
        $sJson &= _StringRepeat($__g_json_sPrettyIndentation, $iLevel + 1) & __json_encode_string($key) & ": " & __json_encode_pretty($map[$key], $iLevel + 1) & "," & @CRLF
        IF @error <> 0 Then Return SetError(@error, @extended, Null)
    Next
    Return StringMid($sJson, 1, StringLen($sJson) - 3) & _StringRepeat($__g_json_sPrettyIndentation, $iLevel) & @CRLF & "}"
EndFunc

Func __json_encode_array_pretty(ByRef $array, $iLevel)
    Local $iDimensions = UBound($array, 0)
    Local $aIndices[$iDimensions]
    For $iIndex = 0 To $iDimensions - 1
        $aIndices[$iIndex] = 0; Fill array with 0
        If UBound($array, $iIndex + 1) = 0 Then; Special handling for array dimention with length 0
            Redim $aIndices[$iIndex+1]; Resize array dimentions to first occurence of length zero, as no child elements can exist
            $iDimensions = $iIndex + 1

            Local $sArray = "[]"

            ; The loop will wrap the child element(s) in an array x times for each dimension
            For $iDimension = $iDimensions - 2 To 0 Step -1
                Local $sArrayParent = _StringRepeat($__g_json_sPrettyIndentation, $iLevel + $iDimension - 1) & "[" & @CRLF & _StringRepeat($__g_json_sPrettyIndentation, $iLevel + $iDimension + 1)
                $sArrayParent &= $sArray
                For $y = 0 To UBound($array, $iDimension + 1)-2
                    $sArrayParent &= "," & @CRLF & _StringRepeat($__g_json_sPrettyIndentation, $iLevel + $iDimension + 1) & $sArray
                Next
                $sArray = $sArrayParent & @CRLF & _StringRepeat($__g_json_sPrettyIndentation, $iLevel + $iDimension) & "]"
            Next
            Return $sArray
        EndIf
    Next

    Local $sJson = "", $_iLevel = $iLevel
    While 1
        For $iDimension = $iDimensions - 1 To 0 Step -1
            If $aIndices[$iDimension] = 0 Then
                $sJson &= _StringRepeat($__g_json_sPrettyIndentation, $_iLevel) & "[" & @CRLF
                $_iLevel += 1
                ContinueLoop
            EndIf
            ExitLoop
        Next

        $sPosition = StringFormat('[%s]', _ArrayToString($aIndices, '][', 0, $iDimensions-1))
        $sJson &= _StringRepeat($__g_json_sPrettyIndentation, $_iLevel) & __json_encode(Execute('$array'&$sPosition))

        If $aIndices[$iDimensions -1 ] < UBound($array, $iDimensions) - 1 Then
            $sJson &= ","
        EndIf

        $sJson &= @CRLF

        For $iDimension = $iDimensions - 1 To 0 Step -1
            $aIndices[$iDimension] += 1

            If $aIndices[$iDimension] <= UBound($array, $iDimension + 1)-1 Then
                ; Current dimension index is not the last element, so we stop regrouping and exit the loop
                ExitLoop
            EndIf

            $_iLevel -= 1
            $sJson &= _StringRepeat($__g_json_sPrettyIndentation, $_iLevel) & "]"

            If $iDimension = 0 Then ExitLoop 2

            If $aIndices[$iDimension - 1] < UBound($array, $iDimension) - 1 Then
                ; Parent index position is not the last element, so we add a comma, to accommodate the next sibling element
                $sJson &= ","
            EndIf

            $sJson &= @CRLF

            ; Reset the index positon of the current dimension
            $aIndices[$iDimension] = 0
        Next
    WEnd
    Return $sJson
EndFunc
