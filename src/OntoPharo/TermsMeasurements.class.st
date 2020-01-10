Class {
	#name : #TermsMeasurements,
	#superclass : #Object,
	#instVars : [
		'levenshteinDistance',
		'hummingDistance',
		'phonetix'
	],
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #distance }
TermsMeasurements >> hammingDistanceOf: aWord with: anotherWord [
	| distance |
	distance := 0.
	1 to: (aWord contents size max: anotherWord contents size) do: [ :pos | 
		(aWord contents at: pos) ~= (anotherWord contents at: pos)
			ifTrue: [ distance := distance + 1 ] ].
	^ distance
]

{ #category : #'as yet unclassified' }
TermsMeasurements >> levenshteinDistanceOf: aWord with: anotherWord [
	"return the Levenshtein distance between two words"

	| stab cost |
	"if a string is empty, answer the length of the another string"
	aWord isEmpty
		ifTrue: [ ^ anotherWord size ].
	anotherWord  isEmpty
		ifTrue: [ ^ aWord size ].
	stab := Array2D
		rows: anotherWord size + 1
		columns: aWord  size + 1.
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
