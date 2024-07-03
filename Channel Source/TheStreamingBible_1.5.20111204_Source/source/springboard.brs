Function NewSpringboardScreen( contentList As Object, contentIndex = 0 As Integer, parentName = "" As String ) As Object
	springboard = {
		Screen: CreateObject( "roSpringboardScreen" )
		ParentName: parentName
		
		Configuration: Configuration()
		
		ContentList: contentList
		ContentIndex: contentIndex
		Content: contentList[ contentIndex ]
		ResumePoint: 0
		
		Playing: False
		
		ButtonText: "Play"
		SetButtons: SpringboardScreen_SetButtons
		SetContent: SpringboardScreen_SetContent
		
		Init: SpringboardScreen_Init
		Show: SpringboardScreen_Show
		PlayContent: SpringboardScreen_PlayContent
		ListenForEvents: SpringboardScreen_ListenForEvents
	}
	springboard.Init()
	Return springboard
End Function

Sub SpringboardScreen_Init()
	m.Screen.SetMessagePort( m.Configuration.EventPort )
	m.Screen.SetBreadcrumbText( m.ParentName, m.Content.ParentName )
	m.Screen.SetPosterStyle( "rounded-square-generic" )
	m.Screen.SetStaticRatingEnabled( False )
	m.SetContent( m.Content )

	m.SetButtons( "Play" )
End Sub

Sub SpringboardScreen_SetButtons( playText As String )
	m.Screen.SetDescriptionStyle( m.Content.Type )

	m.ButtonText = playText
	m.Screen.ClearButtons()
	m.Screen.AddButton( 0, playText )
	
	If playText = "Play" Then
		m.AudioContentList = []
		m.AudioContentIndex = 0
		For iContent = 0 To m.ContentList.Count() - 1
			contentItem = m.ContentList[ iContent ]
			' We're using "video" to fool the screen layout
			' even though the content is audio
			If contentItem.Type = "video" Then
				If contentItem.Url = m.Content.Url Then
					m.AudioContentIndex = m.AudioContentList.Count()
				End If
				m.AudioContentList.Push( contentItem )
			End If
		Next
		If m.AudioContentList.Count() > 1 Then
			m.Screen.AddButton( 1, "Play All" )
		End If
	End If
End Sub

Function SpringboardScreen_Show( autoPlay = -1 As Integer ) As Integer
	If autoPlay <> -1 Then
		m.PlayContent( autoPlay )
	End If
	m.Screen.Show()
	Return m.ListenForEvents()
End Function

Sub SpringboardScreen_PlayContent( buttonIndex = 0 As Integer )
	If m.AudioPlayer <> invalid Then
		m.AudioPlayer.Stop()
		m.AudioPlayer = invalid
	End If
	
	If buttonIndex = 0 Then
		m.AudioContentList = [ m.Content ]
		m.AudioContentIndex = 0
	End If
	m.AudioPlayer = CreateObject( "roAudioPlayer" )
	m.AudioPlayer.SetMessagePort( m.Configuration.EventPort )
	m.AudioPlayer.SetContentList( m.AudioContentList )
	m.AudioPlayer.SetNext( m.AudioContentIndex )
	m.AudioPlayer.Play()
End Sub

Sub SpringboardScreen_SetContent( content )
	' If Synopsis is used for the description, then
	' clear the description of the current item, so
	' it doesn't display on the poster screen
	If m.Content.Synopsis <> invalid Then
		m.Content.Description = ""
	End If
	If content.Synopsis <> invalid Then
		content.Description = content.Synopsis
	End If
	
	m.Screen.SetContent( content )
	m.Screen.SetDescriptionStyle( content.Type )
	If content.AdBanner <> invalid And content.AdBanner <> "" Then
		m.Screen.SetAdUrl( content.AdBanner, content.AdBanner )
	End If
	m.Content = content
End Sub

Function SpringboardScreen_ListenForEvents() As Integer
	While True
		msg = Wait( 1000, m.Configuration.EventPort )
		If msg <> invalid Then
			If Type( msg ) = "roSpringboardScreenEvent" Then
				If msg.IsButtonPressed() Then
					index = msg.GetIndex()
					If index = 0 Or index = 1 Or index = 2 Or index = 3 Then	'Play/Resume/Play From Point/Play From Cache
						If m.ButtonText = "Play" Then
							m.PlayContent( index )
						Else If m.ButtonText = "Pause" Then
							m.AudioPlayer.Pause()
							m.SetButtons( "Resume" )
						Else If m.ButtonText = "Resume" Then
							m.AudioPlayer.Resume()
							m.SetButtons( "Pause" )
						End If
					End If
				Else If msg.IsRemoteKeyPressed() Then
					index = msg.GetIndex()
					If index = 4 Or index = 5 Then	'Left/Right
						If index = 4 Then
							increment = -1
						Else If index = 5 Then
							increment = 1
						End If
						m.ContentIndex = m.ContentIndex + increment
						If m.ContentIndex < 0 Then
							m.ContentIndex = m.ContentList.Count() - 1
						End If
						If m.ContentIndex >= m.ContentList.Count() Then
							m.ContentIndex = 0
						End If
						If m.AudioPlayer <> invalid Then
							m.AudioPlayer.Stop()
							m.AudioPlayer = invalid
						End If
						m.SetContent( m.ContentList[ m.ContentIndex ] )
						m.SetButtons( "Play" )
					End If
				Else If msg.IsScreenClosed() Then
					' If Synopsis is used for the description, then
					' clear the description of the current item, so
					' it doesn't display on the poster screen
					If m.Content.Synopsis <> invalid Then
						m.Content.Description = ""
					End If
					Return m.ContentIndex
				End If
			Else If Type( msg ) = "roAudioPlayerEvent" Then
				If msg.IsRequestFailed() Then
					ShowMessageBox( "Error", msg.GetMessage() )
					m.SetButtons( "Play" )
				Else If msg.IsPartialResult() Or msg.IsFullResult() Then
					m.SetButtons( "Play" )
				Else If msg.IsListItemSelected() Then
					m.AudioContentIndex = msg.GetIndex()
					m.ContentIndex = msg.GetIndex()
					m.SetContent(m.AudioContentList[ m.AudioContentIndex ] )
				Else If msg.IsStatusMessage() Then
					message = msg.GetMessage()
					If message = "startup progress" Then
						m.SetButtons( "Buffering..." )
					Else If message = "start of play" Then
						m.Configuration.SetRegistryValue( m.Content.Url, "1" )
						m.Content.Watched = True
						m.SetButtons( "Pause" )
					Else If message = "end of playlist" Then
						m.Configuration.SetRegistryValue( m.Content.Url, "2" )
						m.Content.Watched = True
						m.SetButtons( "Play" )
					End If
				End If
			End If
		End If
	End While
End Function
