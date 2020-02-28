"
am a terms Measurements, am using a set of metrics as: Hamming and Levenshtein distance, and the TF-IDF metric.
"
Class {
	#name : #TermsMeasurements,
	#superclass : #Object,
	#instVars : [
		'tfidf',
		'tfsc'
	],
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #api }
TermsMeasurements >> conceptByContextTFIDF: aConcept in: aPackageName [
	"Concept Term Frequency-inverseDocumentFrequencyOf (TF-IDF) in a context:
		- The training corpus will be all the concepts in the given package context.
		- The package concepts will be the source of the TF"

	| document |
	self trainOn: aPackageName.
	document := (tfsc splitAllPackageClassesNames: aPackageName)
		flatCollect: [ :concept | concept ].
	^ aConcept -> (tfidf scoreOf: aConcept in: document)
]

{ #category : #api }
TermsMeasurements >> conceptsByContextTFIDF: aPackageName [
	"Concepts Term Frequency-inverseDocumentFrequencyOf (TF-IDFs) in a context:
		- The training corpus will be all the concepts in the given package context (packages with the same prefix).
		- The package concepts will be the source of the TF"
		
	|document conceptsWithTFIDF |
	conceptsWithTFIDF := Dictionary new.
	self trainOn: aPackageName.
	document := ((tfsc splitAllPackageClassesNames: aPackageName) flatCollect: [:concept| concept]) asSet.
	document do: [ :aConcept|
		conceptsWithTFIDF at: aConcept 
								put: (tfidf scoreOf: aConcept in: document)
		 ].
	^ conceptsWithTFIDF
	
]

{ #category : #api }
TermsMeasurements >> conceptsTFIDF: aContext [
	"Concepts Term Frequency-inverseDocumentFrequencyOf (TF-IDFs) in all the system context:
		- The training corpus will be all the system .
		- package context (packages with the same prefix) will be the source of the TF"
		
	|document conceptsWithTFIDF|
	conceptsWithTFIDF := Dictionary new.
	self trainOnAllSystem.
	tfsc context: aContext.
	document := ((tfsc packagesConceptsByContext) flatCollect: [:concept| concept]) asSet.
	document do: [ :aConcept|
		conceptsWithTFIDF at: aConcept 
								put: (tfidf scoreOf: aConcept in: document)
		 ].
	^ conceptsWithTFIDF
	
]

{ #category : #distance }
TermsMeasurements >> hammingDistanceOf: aWord with: anotherWord [
	| distance |
	distance := 0.
	1 to: (aWord contents size max: anotherWord contents size) do: [ :pos | 
		(aWord contents at: pos) ~= (anotherWord contents at: pos)
			ifTrue: [ distance := distance + 1 ] ].
	^ distance
]

{ #category : #initialization }
TermsMeasurements >> initialize [ 

	tfidf := PGTermFrequencyInverseDocumentFrequency new.
	
]

{ #category : #distance }
TermsMeasurements >> levenshteinDistanceOf: aWord with: anotherWord [

	"return the Levenshtein distance between two words"

	| stab cost |
	"if a string is empty, answer the length of the another string"
	aWord isEmpty
		ifTrue: [ ^ anotherWord size ].
	anotherWord isEmpty
		ifTrue: [ ^ aWord size ].
	stab := Array2D rows: anotherWord size + 1 columns: aWord size + 1.
	1 to: stab columnCount do: [ :i | stab at: 1 at: i put: i - 1 ].
	1 to: stab rowCount do: [ :i | stab at: i at: 1 put: i - 1 ].
	2 to: stab columnCount do: [ :i | 
		2 to: stab rowCount do: [ :j | 
			(aWord at: i - 1) = (anotherWord at: j - 1)
				ifTrue: [ cost := 0 ]
				ifFalse: [ cost := 1 ].
			stab
				at: j
				at: i
				put:
					({((stab at: j at: i - 1) + 1).
					((stab at: j - 1 at: i) + 1).
					((stab at: j - 1 at: i - 1) + cost)}
						asSortedCollection: [ :a :b | a < b ]) first ] ].
	^ stab at: stab rowCount at: stab columnCount
]

{ #category : #api }
TermsMeasurements >> sort2DCollection: a2DCollection [
	"Descending Sorting  for Key/Value Collection"
	|sorted|
	sorted := SortedCollection sortBlock: [ :a :b | a value > b value ].
	sorted addAll: a2DCollection.
	^ sorted 
	
]

{ #category : #api }
TermsMeasurements >> sortedConceptsTFIDFs: aPackageName [
	"Concepts Term Frequency-inverseDocumentFrequencyOf (TF-IDFs) in a context:
		- The training corpus will be all the concepts in the given package context (packages with the same prefix).
		- The package concepts will be the source of the TF"
		
	|document conceptsWithTFIDF |
	self trainOn: aPackageName.
	document := ((tfsc splitAllPackageClassesNames: aPackageName) flatCollect: [:concept| concept]) asSet.
	conceptsWithTFIDF := document collect: [ :aConcept|
		aConcept 
			-> 
				(tfidf scoreOf: aConcept in: document)
		 ].
	^  self sort2DCollection: conceptsWithTFIDF
	
]

{ #category : #api }
TermsMeasurements >> trainOn: aPackageName [
	|prefix |
	tfsc := TermsFeatureSelectorByContext new.
	prefix := aPackageName splitIdentifierName first.
	tfsc context: prefix.
	tfidf trainOn: tfsc packagesConceptsByContext.
	^ tfsc
]

{ #category : #api }
TermsMeasurements >> trainOnAllSystem [
	
	tfsc := TermsFeatureSelectorByContext new.
	tfidf trainOn: tfsc splitAllSystemClassesNames.
	^ tfsc
]
