Function NewStreamingBible() As Object
	streamingBible = {
		Filters: invalid

		OnListItemSelected: StreamingBible_OnListItemSelected
		
		Init: StreamingBible_Init
		Show: StreamingBible_Show
		
		OnListFocused: StreamingBible_OnListFocused
	}
	streamingBible.Init()
	Return streamingBible
End Function

Sub StreamingBible_Init()
	
End Sub

Sub StreamingBible_Show() As Object
	filters = []
	webClient = NewWebClient()
	xml = CreateObject( "roXMLElement" )
	xmlString = webClient.Get( "http://www.therokubible.com/xml/index.xml" )
	If xml.Parse( xmlString ) Then
		For Each bible in xml.bibles
			listItem = {
				Name: bible@name
				Url: bible@bibles
				Type: "version"
			}
			filters.Push( listItem )
		Next
		' This is here, just in case the XML is changed to <bible> instead of <bibles>
		For Each bible in xml.bible
			listItem = {
				Name: bible@name
				Url: bible@bibles
				Type: "version"
			}
			filters.Push( listItem )
		Next
	End If
	poster = NewPosterWindow( "", m )
	poster.SetListStyle( "arced-landscape" )
	poster.SetListItems( filters )
	poster.Show()
End Sub

Sub StreamingBible_OnListFocused( listItem As Object, parentWin As Object )
	If listItem.ContentItems = invalid Then
		listItem.ContentItems = []
	End If
	If listItem.ContentItems.Count() = 0 Then
		If listItem.Type = "version" Then
			webClient = NewWebClient()
			xml = CreateObject( "roXMLElement" )
			xmlString = webClient.Get( listItem.Url )
			If xml.Parse( xmlString ) Then
				contentItems = []
				For Each version in xml.version
					versionItem = {
						Title: version@name
						ShortDescriptionLine1: version@name
						Url: version@books
						HDPosterUrl: version@icon
						SDPosterUrl: version@icon
						Type: "bible"
					}
					listItem.ContentItems.Push( versionItem )
				Next
			End If
		Else If listItem.Type = "book" Then
			webClient = NewWebClient()
			xml = CreateObject( "roXMLElement" )
			xmlString = webClient.Get( listItem.Url + "/index.xml" )
			If xml.Parse( xmlString ) Then
				episode = 1
				For Each track in xml.tracklist.track
					item = {
						Title: track.titulo.GetText()
						ShortDescriptionLine1: track.titulo.GetText()
						Synopsis: listItem.Description
						HDPosterUrl: listItem.HDPosterUrl
						SDPosterUrl: listItem.SDPosterUrl
						EpisodeNumber: episode.ToStr()
						' Set to video to full springboard screen
						Type: "video"
						StreamFormat: "mp3"
						Url: Replace( track.direccion.GetText(), " ", "%20" )
						Actors: [ listItem.ParentName ]
						Parent: listItem
						ParentName: listItem.Name
						AdBanner: listItem.AdBanner
					}
					item.Watched = ( Configuration().GetRegistryValue( item.Url, "0" ) <> "0" )
					listItem.ContentItems.Push( item )
					episode = episode + 1
				Next
			End If
		End If
	End If
	parentWin.SetContentList( listItem.ContentItems )
	parentWin.SetFocusedListItem( 0 )
End Sub

Sub StreamingBible_OnListItemSelected( listItem As Object, parentWin As Object )
	If listItem.Type = "bible" Then
		If listItem.ListItems = invalid Then
			listItem.ListItems = []
		End If
		poster = NewPosterWindow( listItem.Title, m )
		poster.SetListStyle( "flat-episodic" )
		poster.Show( False )
		If listItem.ListItems.Count() = 0 Then
			webClient = NewWebClient()
			xml = CreateObject( "roXMLElement" )
			xmlString = webClient.Get( listItem.Url )
			If xml.Parse( xmlString ) Then
				description = xml.description.GetText().Trim()
				adbanner = ""
				If xml.adbanner.Count() > 0 Then
					adbanner = xml.adbanner@url
					If xml.adbanner.adbanner.Count() > 0 Then
						adbanner = xml.adbanner.adbanner@url
					End If
				End If
				For Each book in xml.book
					item = {
						Name: book.GetText()
						ParentName: listItem.Title
						Description: description
						HDPosterUrl: listItem.HDPosterUrl
						SDPosterUrl: listItem.SDPosterUrl
						AdBanner: adbanner
						Url: book@url
						Type: "book"
					}
					listItem.ListItems.Push( item )
				Next
			End If
		End If
		poster.SetListItems( listItem.ListItems )
		poster.Show( True )
	Else If listItem.Type = "video" Then
		contentIndex = 0
		For iItem = 0 To parentWin.ContentList.Count() - 1
			?listItem.Url
			If parentWin.ContentList[ iItem ].Url = listItem.Url Then
				contentIndex = iItem
				Exit For
			End If
		Next
		springboard = NewSpringboardScreen( parentWin.ContentList, contentIndex, parentWin.Title )
		newIndex = springboard.Show()
		parentWin.SetContentList( parentWin.ContentList )
		parentWin.SetFocusedListItem( newIndex )
	End If
End Sub
