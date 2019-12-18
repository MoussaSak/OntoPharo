as yet unclassified
loadPolyglot: spec
	spec for: #( #'pharo7.x' #'pharo8.x' ) do: [ 
		spec
			baseline: 'Polyglot'
			with: [ spec repository: 'github://PolyMathOrg/Polyglot/src' ] ]