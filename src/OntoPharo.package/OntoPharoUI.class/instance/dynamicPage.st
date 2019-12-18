pages
dynamicPage 
	^ SpNotebookPage title: 'Dynamic' icon: (self iconNamed: #nautilusIcon) provider: [ SpDynamicWidgetChange new ]
