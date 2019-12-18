baselines
baseline: spec
	<baseline>
	spec for: #common do: [ "dependencies"
		self loadPolyglot: spec.
		self loadIdentifierNameSplitter: spec.
		"Packages"
		spec
			package: 'OntoPharo';
			package: 'OntoPharo-Tests'
			with: [ spec requires: #( 'OntoPharo' ) ] ]