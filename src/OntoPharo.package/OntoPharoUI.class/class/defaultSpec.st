specs
defaultSpec
	^ SpBoxLayout newVertical
		  add: #notebook;
		  add: (SpBoxLayout newHorizontal
				   add: #checkbox
				   withConstraints: [ :constraints | constraints width: 20 ];
				   add: 'Show dynamic presenter')
		  withConstraints: [ :constraints | 
		  constraints height: self labelHeight ];
		  yourself