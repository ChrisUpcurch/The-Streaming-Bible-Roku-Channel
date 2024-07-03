Function NewPosterWindow( title = "" As String, callbackObject = invalid, callbackPrefix = "" As String, breadcrumb = "" As String ) As Object
	poster = {
		Screen: CreateObject( "roPosterScreen" )
		EventPort: CreateObject( "roMessagePort" )
			
		ListItems: invalid
		ContentList: invalid
		SetListItems: Poster_SetListItems
		SetContentList: Poster_SetContentList
		
		ListIndex: -1
		ListItemIndex: -1
		
		Title: title
		Breadcrumb: breadcrumb
		
		SelectListItem: Poster_SelectListItem
		
		SetListStyle: Poster_SetListStyle
		SetListDisplayMode: Poster_SetListDisplayMode
		SetFocusedList: Poster_SetFocusedList
		GetFocusedList: Poster_GetFocusedList
		SetFocusedListItem: Poster_SetFocusedListItem
		GetFocusedListItem: Poster_GetFocusedListItem
		SetBreadcrumbText: Poster_SetBreadcrumbText
		SetBreadcrumbEnabled: Poster_SetBreadcrumbEnabled
		ShowMessage: Poster_ShowMessage
		ClearMessage: Poster_ClearMessage
		SetAdURL: Poster_SetAdURL
		SetAdSelectable: Poster_SetAdSelectable
		SetAdDisplayMode: Poster_SetAdDisplayMode
		SetTitle: Poster_SetTitle
		UseStableFocus: Poster_UseStableFocus
		
		CallbackObject: callbackObject
		CallbackPrefix: callbackPrefix
		Callback: Common_Callback
		CallbackNoParams: Common_CallbackNoParams

		Show: Poster_Show
		Close: Poster_Close
		Init: Poster_Init
		ListenForEvents: Poster_ListenForEvents
	}
	
	poster.Init()
	Return poster
End Function

Sub Poster_Init()
	m.Screen.SetMessagePort( m.EventPort )
	m.SetTitle( m.Title )
	m.SetBreadcrumbText( m.Breadcrumb, m.Title )
	m.SetListDisplayMode( "zoom-to-fill" )
End Sub

Sub Poster_Show( listen = True As Boolean )
	m.Screen.Show()
	If listen Then
		m.ListenForEvents()
	End If
End Sub

Sub Poster_SetListItems( list As Object, displayProp = "Name" As String )
	listNames = []
	For index = 0 To list.Count() - 1
		If Type( list[ index ] ) = "String" Or Type( list[ index ] ) = "roString" Then
			listNames.Push( list[ index ] )
		Else
			listNames.Push( list[ index ][ displayProp ] )
		End If
	Next
	m.ListItems = list
	m.Screen.SetListNames( listNames )
	If listNames.Count() > 0 Then
		m.SetFocusedList( 0 )
	End If
End Sub

Sub Poster_SetContentList( list As Object )
	m.ContentList = list
	m.Screen.SetContentList( m.ContentList )
	If m.ContentList.Count() = 0 Then
		m.ShowMessage( "There are currently no items in this category." )
	End If
End Sub

Sub Poster_SelectListItem( index As Integer )
	m.SetFocusedListItem( index )
	m.Callback( "OnListItemSelected", m.ContentList[ m.ListItemIndex ] )
End Sub

Sub Poster_ListenForEvents()
	While True
		msg = Wait( 1000, m.EventPort )
		If msg = invalid Then
			If m.CallListFocused <> invalid And m.CallListFocused Then
				m.Callback( "OnListFocused", m.ListItems[ m.ListIndex ] )
				m.CallListFocused = False
			End If
		Else
			If Type( msg ) = "roPosterScreenEvent" Then
				If msg.IsScreenClosed() Then
					Exit While
				Else If msg.IsListFocused() Then
					' Clear content list and delay for one second
					' before calling list focused event
					m.SetContentList( [] )
					m.ShowMessage( "retrieving..." )
					m.ListIndex = msg.GetIndex()
					m.CallListFocused = True
				Else If msg.IsListSelected() Then
					m.ListIndex = msg.GetIndex()
					m.Callback( "OnListSelected", m.ListItems[ m.ListIndex ] )
				Else If msg.IsListItemFocused() Then
					m.ListItemIndex = msg.GetIndex()
					m.Callback( "OnListItemFocused", m.ContentList[ m.ListItemIndex ] )
				Else If msg.IsListItemSelected() Then
					m.ListItemIndex = msg.GetIndex()
					m.Callback( "OnListItemSelected", m.ContentList[ m.ListItemIndex ] )
					m.Callback( "OnListItemSelectedEx", { Index: m.ListItemIndex, List: m.ContentList } )
				Else If msg.IsAdSelected() Then
					m.CallbackNoParams( "OnAdSelected" )
				End If
			End If
		End If
	End While
End Sub

Sub Poster_SetListStyle( style As String )
	m.Screen.SetListStyle( style )
End Sub

Sub Poster_SetListDisplayMode( displayMode As String )
	m.Screen.SetListDisplayMode( displayMode )
End Sub

Sub Poster_SetFocusedList( index As Integer )
	m.ListIndex = index
	m.Screen.SetFocusedList( index )
	m.Callback( "OnListFocused", m.ListItems[ index ] )
End Sub

Function Poster_GetFocusedList() As Object
	If m.ListIndex > -1 Then
		Return m.ListItems[ m.ListIndex ]
	Else
		Return invalid
	End If
End Function

Sub Poster_SetFocusedListItem( index As Integer )
	m.ListItemIndex = index
	m.Screen.SetFocusedListItem( index )
	m.Callback( "OnListItemFocused", m.ContentList[ index ] )
End Sub

Function Poster_GetFocusedListItem() As Object
	If m.ListItemIndex > -1 Then
		Return m.ContentList[ m.ListItemIndex ]
	Else
		Return invalid
	End If
End Function

Sub Poster_SetBreadcrumbText( breadcrumb1 As String, breadcrumb2 As String )
	m.Breadcrumb = breadcrumb1
	m.Title = breadcrumb2
	m.Screen.SetBreadcrumbText( m.Breadcrumb, m.Title )
End Sub

Sub Poster_SetBreadcrumbEnabled( enabled As Boolean )
	m.Screen.SetBreadcrumbEnabled( enabled )
End Sub

Sub Poster_ShowMessage( message As String )
	m.Screen.ShowMessage( message )
End Sub

Sub Poster_ClearMessage()
	m.Screen.ClearMessage()
End Sub

Sub Poster_SetAdURL( sdUrl As String, hdUrl As String )
	m.Screen.SetAdURL( sdUrl, hdUrl )
End Sub

Sub Poster_SetAdSelectable( selectable As Boolean )
	m.Screen.SetAdSelectable( selectable )
End Sub

Sub Poster_SetAdDisplayMode( displayMode As String )
	m.Screen.SetAdDisplayMode( displayMode )
End Sub

Sub Poster_SetTitle( title As String )
	m.Title = title
	m.Screen.SetTitle( m.Title )
End Sub

Sub Poster_UseStableFocus( enable As Boolean )
	m.Screen.UseStableFocus( enable )
End Sub

Sub Poster_Close()
	m.Screen.Close()
End Sub

