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
                    Redim $array[$i+1]
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
    ;FIXME: implement in a better way
    Local $number = ""
    While 1
        Switch StringMid($sJson, $iIndex, 1)
            Case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', 'e', 'E', '-', '+'
                $number &= StringMid($sJson, $iIndex, 1)
                $iIndex += 1
            Case ''
                ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                Return SetError(1, 1, Null)
            Case Else
                $number = Execute($number)
                If @error <> 0 Then
                    ConsoleWriteError(@ScriptLineNumber&@TAB&$iIndex&@CRLF)
                    Return SetError(1, 1, Null)
                EndIf
                Return $number
        EndSwitch
    WEnd
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

Func json_encode()
    ;
EndFunc

Func json_encode_pretty()
    ;
EndFunc
