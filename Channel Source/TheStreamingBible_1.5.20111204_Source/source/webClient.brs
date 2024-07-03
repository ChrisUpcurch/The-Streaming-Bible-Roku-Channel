Function NewWebClient() as Object
	webClient = {
		Http: CreateURLTransferObject()
		Get: WebClient_Get
		LastResponseCode: 0
		ResponseHeaders: invalid
	}
	Return webClient
End Function

Function WebClient_Get( url As String, seconds = 30 As Integer, freshConnection = True As Boolean ) As String
	timeout% = 1000 * seconds
	response = ""

	m.Http.SetUrl( url )
	m.Http.EnableFreshConnection( freshConnection ) 'Don't reuse existing connections
	If ( m.Http.AsyncGetToString() )
		event = wait( timeout%, m.Http.GetPort() )
		If Type(event) = "roUrlEvent" And event.GetInt() = 1 Then
			response = event.GetString()
			m.ResponseHeaders = event.GetResponseHeaders()
			m.LastResponseCode = event.GetResponseCode()
		Else If event = invalid
			print "AsyncGetToString timeout"
			m.Http.AsyncCancel()
			m.LastResponseCode = -1
		Else
			print "AsyncGetToString unknown event", event
		End If
	End If
	Return response
End Function

Function CreateURLTransferObject() As Object
	obj = CreateObject( "roUrlTransfer" )
	messagePort = CreateObject( "roMessagePort" )
	obj.SetPort( messagePort )
	obj.EnableEncodings( true )
	obj.InitClientCertificates()
	obj.SetCertificatesFile( "common:/certs/ca-bundle.crt" )
	return obj
End Function