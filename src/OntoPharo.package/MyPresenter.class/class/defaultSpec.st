specs
defaultSpec
	^ SpPanedLayout newVertical
		  add: #table;
		  add: (SpBoxLayout newHorizontal
				   add: #label;
				   add: #button;
				   yourself)
		  "withConstraints: [ :cstr | cstr height: 30 ]";
		  yourself