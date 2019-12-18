as yet unclassified
loadIdentifierNameSplitter: spec
	spec for: #( #'pharo7.x' #'pharo8.x' ) do: [ 
		spec
			baseline: 'IdentifierNameSplitter'
			with: [ spec repository: 'github://olekscode/IdentifierNameSplitter/src' ] ]