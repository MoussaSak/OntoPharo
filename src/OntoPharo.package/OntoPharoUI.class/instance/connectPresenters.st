initialization
connectPresenters 
	super connectPresenters.

	checkbox whenActivatedDo: [ notebook addPage: (dynamicPage := self dynamicPage) ].

	checkbox
		whenDeactivatedDo: [ dynamicPage
				ifNotNil: [ :page | 
					notebook removePage: page.
					dynamicPage := nil ] ]
