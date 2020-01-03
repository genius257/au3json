#include-once

Global Const $JSON_COMMA = ','
Global Const $JSON_COLON = ':'
Global Const $JSON_LEFTBRACKET = '['
Global Const $JSON_RIGHTBRACKET = ']'
Global Const $JSON_LEFTBRACE = '{'
Global Const $JSON_RIGHTBRACE = '}'
Global Const $JSON_QUOTE = '"'
Global Const $JSON_WHITESPACE = '\s'
Global Const $JSON_SYNTAX = '[\,\:\[\]\{\}]'
Global Const $TRUE_LEN = 4
Global Const $FALSE_LEN = 5
Global Const $NULL_LEN = 4

Func json_lex($string)
    Local $tokens = ObjCreate("System.Collections.ArrayList")
    Local $tmp
    Local $json_string
    Local $json_number
    Local $json_bool
    Local $json_null

    While StringLen($string) > 0
        $tmp = json_lex_string($string)
        $json_string = $tmp[0]
        $string = $tmp[1]
        If Not ($json_string == Default) Then
            ArrayPush($tokens, $json_string)
            ContinueLoop
        EndIf

        $tmp = json_lex_number($string)
        $json_number = $tmp[0]
        $string = $tmp[1]
        If Not ($json_number == Default) Then
            ArrayPush($tokens, $json_number)
            ContinueLoop
        EndIf

        $tmp = json_lex_bool($string)
        $json_bool = $tmp[0]
        $string = $tmp[1]
        If Not ($json_bool == Default) Then
            ArrayPush($tokens, $json_bool)
            ContinueLoop
        EndIf

        $tmp = json_lex_null($string)
        $json_null = $tmp[0]
        $string = $tmp[1]
        If Not ($json_null == Default) Then
            ArrayPush($tokens, Null)
            ContinueLoop
        EndIf

        If StringRegExp(StringMid($string, 1, 1), $JSON_WHITESPACE) Then
            $string = StringMid($string, 2)
        ElseIf StringRegExp(StringMid($string, 1, 1), $JSON_SYNTAX) Then
            ArrayPush($tokens, StringMid($string, 1, 1))
            $string = StringMid($string, 2)
        Else
            Exit ConsoleWriteError(StringFormat('Unexpected character: %s', StringMid($string, 1, 1)) & @CRLF)
        EndIf
    WEnd

    Return $tokens
EndFunc

Func json_lex_string($string)
    Local $json_string = ''
    Local $tmp[2]

    If StringMid($string, 1, 1) == $JSON_QUOTE Then
        $string = StringMid($string, 2)
    Else
        $tmp[0] = Default
        $tmp[1] = $string
        Return $tmp
    EndIf

    Local $i, $c
    For $i=1 To StringLen($string)
        $c = StringMid($string, $i, 1)
        If $c == $JSON_QUOTE Then
            $tmp[0] = $json_string
            $tmp[1] = StringMid($string, StringLen($json_string) +2)
            Return $tmp
        Else
            $json_string &= $c
            If $c == '\' Then
                $json_string &= StringMid($string, $i+1, 1)
                $i += 1
            EndIf
        EndIf
    Next

    Exit ConsoleWriteError('Expected end-of-string quote')
EndFunc

Func json_lex_number($string)
    Local $json_number = ''
    Local $tmp[2]

    Local $i, $c
    For $i=1 To StringLen($string)
        $c = StringMid($string, $i, 1)
        If StringRegExp($c, '[0-9\-e\.]') Then
            $json_number &= $c
        Else
            ExitLoop
        EndIf
    Next

    Local $rest = StringMid($string, StringLen($json_number)+1)

    If Not StringLen($json_number) Then
        $tmp[0] = Default
        $tmp[1] = $string
        Return $tmp
    EndIf

    If StringRegExp($json_number, '\.') Then
        $tmp[0] = Number($json_number)
        $tmp[1] = $rest
        Return $tmp
    EndIf

    $tmp[0] = Int($json_number)
    $tmp[1] = $rest
    Return $tmp
EndFunc

Func json_lex_bool($string)
    Local $string_len = StringLen($string)
    Local $tmp[2]

    If $string_len >= $TRUE_LEN And StringMid($string, 1, $TRUE_LEN) == 'true' Then
        $tmp[0] = True
        $tmp[1] = StringMid($string, $TRUE_LEN+1)
        Return $tmp
    ElseIf $string_len >= $FALSE_LEN And StringMid($string, 1, $FALSE_LEN) == 'false' Then
        $tmp[0] = False
        $tmp[1] = StringMid($string, $FALSE_LEN+1)
        Return $tmp
    EndIf

    $tmp[0] = Default
    $tmp[1] = $string
    Return $tmp
EndFunc

Func json_lex_null($string)
    Local $string_len = StringLen($string)
    Local $tmp[2]

    If $string_len >= $NULL_LEN And StringMid($string, 1, $NULL_LEN) == 'null' Then
        $tmp[0] = True
        $tmp[1] = StringMid($string, $NULL_LEN + 1)
        Return $tmp
    EndIf

    $tmp[0] = Default
    $tmp[1] = $string
    Return $tmp
EndFunc

Func json_parse($tokens, $is_root = False)
    Local $t = $tokens.Item(0)

    If $is_root And Not ($t == $JSON_LEFTBRACE) Then Exit ConsoleWriteError('Root must be an object')

    If $t == $JSON_LEFTBRACKET Then
        $tokens = $tokens.Clone()
        $tokens.RemoveAt(0)
        Return json_parse_array($tokens)
    ElseIf $t == $JSON_LEFTBRACE Then
        $tokens = $tokens.Clone()
        $tokens.RemoveAt(0)
        Return json_parse_object($tokens)
    Else
        Local $tmp[2]
        $tmp[0] = $t
        $tokens = $tokens.Clone()
        $tokens.RemoveAt(0)
        $tmp[1] = $tokens
        Return $tmp
    EndIf
EndFunc

Func json_parse_array($tokens)
    Local $json_array = ObjCreate("System.Collections.ArrayList")
    Local $tmp[2]

    Local $t = $tokens.Item(0)
    If $t == $JSON_RIGHTBRACKET Then
        $tmp[0] = $json_array.toArray()
        $tokens = $tokens.Clone()
        $tokens.RemoveAt(0)
        $tmp[1] = $tokens
        Return $tmp
    EndIf

    While True
        $json_tokens = json_parse($tokens)
        $json = $json_tokens[0]
        $tokens = $json_tokens[1]
        ArrayPush($json_array, $json)

        $t = $tokens.Item(0)
        If $t == $JSON_RIGHTBRACKET Then
            $tmp[0] = $json_array.toArray()
            $tokens = $tokens.Clone()
            $tokens.RemoveAt(0)
            $tmp[1] = $tokens
            Return $tmp
        ElseIf Not ($t == $JSON_COMMA) Then
            Exit ConsoleWriteError('Expected comma after object in array'&@CRLF)
        Else
            $tokens = $tokens.Clone()
            $tokens.RemoveAt(0)
            $tokens = $tokens
        EndIf
    WEnd

    Exit ConsoleWriteError('Expected end-of-array bracket'&@CRLF)
EndFunc

Func json_parse_object($tokens)
    Local $json_object = ObjCreate("Scripting.Dictionary")
    Local $tmp[2]

    Local $t = $tokens.Item(0)
    If $t == $JSON_RIGHTBRACE Then
        $tmp[0] = $json_object
        $tokens = $tokens.Clone()
        $tokens.RemoveAt(0)
        $tmp[1] = $tokens
        Return $tmp
    EndIf

    While True
        $json_key = $tokens.Item(0)
        If IsString($json_key) Then
            $tokens = $tokens.Clone()
            $tokens.RemoveAt(0)
        Else
            Exit ConsoleWriteError(StringFormat('Expected string key, got: %s', $json_key)&@CRLF)
        EndIf

        If Not ($tokens.Item(0) == $JSON_COLON) Then Exit ConsoleWriteError(StringFormat('Expected colon after key in object, got: %s', $t))

        $tmp2 = $tokens.Clone()
        $tmp2.RemoveAt(0)
        $json_parse = json_parse($tmp2)
        $json_value = $json_parse[0]
        $tokens = $json_parse[1]

        $json_object.Add($json_key, $json_value)

        $t = $tokens.Item(0)
        If $t == $JSON_RIGHTBRACE Then
            $tmp[0] = $json_object
            $tokens = $tokens.Clone()
            $tokens.RemoveAt(0)
            $tmp[1] = $tokens
            Return $tmp
        ElseIf Not ($t == $JSON_COMMA) Then
            Exit ConsoleWriteError(StringFormat('Expected comma after pair in object, got: %s', $t))
        EndIf

        $tokens = $tokens.Clone()
        $tokens.RemoveAt(0)
    WEnd

    Exit ConsoleWriteError(StringFormat('Expected end-of-object bracket'))
EndFunc

Func ArrayPush(ByRef $array, $vData)
    $array.Add($vData)
EndFunc