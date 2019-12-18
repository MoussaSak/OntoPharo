initialization
initializePresenters
	notebook := self newNotebook.
	checkbox := self newCheckBox.
	notebook
		addPage: self objectClassPage;
		addPage: self objectInspectorPage;
		addPage: self browserPage