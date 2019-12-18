initialization
initializeWidgets
	label := SpLabelPresenter new.
	button := SpButtonPresenter new action: [ table items: { 5 } ]; label: 'Set'.
	table := SpTablePresenter new
		         items: { 1. 2. 4 };
		         addColumn:
			         (SpStringTableColumn new evaluated: [ :int | int asString ]);
		         whenSelectionChangedDo: [ :selection | selection inspect ];
		         yourself