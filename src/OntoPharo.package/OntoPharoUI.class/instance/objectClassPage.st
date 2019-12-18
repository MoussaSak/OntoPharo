pages
objectClassPage 
	^ SpNotebookPage title: 'Object class' icon: (self iconNamed: #nautilusIcon) provider: [ MessageBrowser new messages: Object methods ]


