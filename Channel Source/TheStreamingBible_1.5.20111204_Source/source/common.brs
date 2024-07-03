Function IsNullOrEmpty( value ) As Boolean
	If Type( value ) = "String" Or Type( value ) = "roString" Then
		Return ( value = invalid Or Len( value ) = 0 )
	Else If Type( value ) = "roInvalid" Then
		Return True
	Else
		Return value = invalid
	End If
End Function

Function Replace( text As String, toReplace As String, replaceWith As String ) As String
	regex = CreateObject( "roRegex", toReplace, "" )
	result = regex.ReplaceAll( text, replaceWith )
	Return result
End Function

Function Common_Callback( functionName As String, value As Dynamic ) As Dynamic
	print functionName
	If m.CallbackObject <> invalid Then
		If m.CallbackObject[ m.CallbackPrefix + functionName ] <> invalid Then
			Return m.CallbackObject[ m.CallbackPrefix + functionName ]( value, m )
		End If
	End If
	Return invalid
End Function

Function Common_CallbackNoParams( functionName As String ) As Dynamic
	print functionName
	If m.CallbackObject <> invalid Then
		If m.CallbackObject[ m.CallbackPrefix + functionName ] <> invalid Then
			Return m.CallbackObject[ m.CallbackPrefix + functionName ]( m )
		End If
	End If
	Return invalid
End Function