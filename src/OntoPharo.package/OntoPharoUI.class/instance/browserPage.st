pages
browserPage
	^ SpNotebookPage
		  title: 'Browser'
		  icon: (self iconNamed: #nautilusIcon)
		  provider: [ 
			  SpClassMethodBrowser new
				  classes: self class environment allClasses;
				  yourself ] 