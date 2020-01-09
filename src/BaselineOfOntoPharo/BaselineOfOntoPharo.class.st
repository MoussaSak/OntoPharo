"
Baseline of Ontologue Project
"
Class {
	#name : #BaselineOfOntoPharo,
	#superclass : #BaselineOf,
	#category : #BaselineOfOntoPharo
}

{ #category : #baselines }
BaselineOfOntoPharo >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ "dependencies"
			self loadPolyglot: spec.
			self loadIdentifierNameSplitter: spec.
			"Packages"
			spec
				package: 'OntoPharo';
				package: 'OntoPharo-Tests' with: [ spec requires: #(OntoPharo) ] ]
]

{ #category : #'as yet unclassified' }
BaselineOfOntoPharo >> loadIdentifierNameSplitter: spec [
	spec for: #( #'pharo7.x' #'pharo8.x' ) do: [
		spec
			baseline: 'IdentifierNameSplitter'
			with: [ spec repository: 'github://olekscode/IdentifierNameSplitter/src' ] ]
]

{ #category : #'as yet unclassified' }
BaselineOfOntoPharo >> loadPolyglot: spec [
	spec for: #( #'pharo7.x' #'pharo8.x' ) do: [
		spec
			baseline: 'Polyglot'
			with: [ spec repository: 'github://PolyMathOrg/Polyglot/src' ] ]
]

{ #category : #baselines }
BaselineOfOntoPharo >> pharoVersionsFrom: aVersion [
    ^ (aVersion to: SystemVersion current major) collect: [ :v | ('pharo' , v asString , '.x') asSymbol ]
]
