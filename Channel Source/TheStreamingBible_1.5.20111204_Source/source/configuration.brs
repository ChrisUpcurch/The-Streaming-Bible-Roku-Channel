Function NewConfiguration() As Object
	config = {
		Registry: CreateObject( "roRegistrySection", "StreamingBible" )
		EventPort: CreateObject( "roMessagePort" )

		GetRegistryValue: Configuration_GetRegistryValue
		SetRegistryValue: Configuration_SetRegistryValue

		FactoryReset: Configuration_FactoryReset
	}
	Return config
End Function

Function Configuration_GetRegistryValue( key As String, defaultValue = "" As String, forceRefresh = False As Boolean ) As String
	If forceRefresh Then
		m[ key ] = invalid
	End If
	If m[ key ] = invalid Then
		m.AddReplace( key, m.Registry.Read( key ) )
	End If
	If IsNullOrEmpty( m[ key ] ) Then
		Return defaultValue
	End If
	Return m[ key ]
End Function

Sub Configuration_SetRegistryValue( key As String, value As String, commit = True As Boolean )
	m.AddReplace( key, value )
	If IsNullOrEmpty( value ) Then
		m.Registry.Delete( key )
	Else
		m.Registry.Write( key, value )
	End If
	If commit Then
		m.Registry.Flush()
	End If
End Sub

Sub Configuration_FactoryReset()
	For Each key in m
		m.Registry.SetRegistryValue( key, "" )
	Next
	m.Registry.Flush()
End Sub
