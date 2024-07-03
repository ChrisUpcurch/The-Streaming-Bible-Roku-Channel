Sub RunUserInterface( ecp As Dynamic )
	InitTheme()
		
	screenFacade = CreateObject( "roPosterScreen" )
	screenFacade.Show()
	
	m.Configuration = NewConfiguration()
	server = NewStreamingBible()

	server.Show()
End Sub

Function Configuration() As Object
	Return m.Configuration
End Function

Sub ApplicationClose()
End Sub

Sub InitTheme()
	app = CreateObject("roAppManager")
	theme = {
		BackgroundColor: "#325278"
		
		OverhangOffsetSD_X: "39"
		OverhangOffsetSD_Y: "36"
		OverhangSliceSD: "pkg:/images/header_slice_sd.jpg"
		OverhangLogoSD: "pkg:/images/logo_sd.png"

		OverhangOffsetHD_X: "70"
		OverhangOffsetHD_Y: "55"
		OverhangSliceHD: "pkg:/images/header_slice_hd.jpg"
		OverhangLogoHD: "pkg:/images/logo_hd.png"
		
		FilterBannerSliceSD: "pkg:/images/filter_slice_sd.png"
		FilterBannerActiveSD: "pkg:/images/filter_active_sd.png"
		FilterBannerInactiveSD: "pkg:/images/filter_inactive_sd.png"

		FilterBannerSliceHD: "pkg:/images/filter_slice_hd.png"
		FilterBannerActiveHD: "pkg:/images/filter_active_hd.png"
		FilterBannerInactiveHD: "pkg:/images/filter_inactive_hd.png"

		FilterBannerActiveColor: "#ffe700"
		FilterBannerInactiveColor: "#FFFFFF"
		FilterBannerSideColor: "#c0c0c0"
		
		BreadcrumbTextLeft: "#2c4762"
		BreadcrumbTextRight: "#2c4762"
		
		ButtonMenuNormalText: "#C0C0C0"
		ButtonMenuHighlightText: "#ffe700"
		
		SpringboardTitleText: "#FFFFFF"
		SpringboardArtistColor: "#CCCCCC"
		SpringboardActorColor: "#FFFFFF"
		SpringboardAlbumColor: "#CCCCCC"
		SpringboardSynopsisColor: "#C0C0C0"
		
		PosterScreenLine1Text: "#CCCCCC"
		PosterScreenLine1Text: "#C0C0C0"
	}
	app.SetTheme( theme )
End Sub
