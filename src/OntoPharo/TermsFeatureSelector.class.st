Class {
	#name : #TermsFeatureSelector,
	#superclass : #Object,
	#instVars : [
		'tfidf',
		'termsMeasurments'
	],
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #sorting }
TermsFeatureSelector >> collectAllConcepts: aPackage [ 
| collection conceptsCollection |
collection := OrderedCollection new.
conceptsCollection :=  (self splitAllPackageClassesNames: aPackage) .
conceptsCollection collect: [:i| i collect: [ :x| collection add: (x asString) ]  ] .
^collection 
]

{ #category : #initialization }
TermsFeatureSelector >> foo [ 
	"self new foo"
	
	^ super == self 
]

{ #category : #'as yet unclassified' }
TermsFeatureSelector >> getConceptTFIDF: aConcept in: aDocument [
	
	^ tfidf scoreOf: aConcept in: aDocument
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> getPackageAllClassesNames: aPackageName [
	 |allClassesNames|
	allClassesNames := (RPackageOrganizer default packageNamed: aPackageName)
		  definedClasses collect: [ :each | each instanceSide name ].
	
	^allClassesNames asOrderedCollection  
]

{ #category : #initialization }
TermsFeatureSelector >> initialize [
	super initialize.
	tfidf := PGTermFrequencyInverseDocumentFrequency new.
	termsMeasurments := TermsMeasurements new.

]

{ #category : #sorting }
TermsFeatureSelector >> sortConceptsByHammingDistanceOF: aConcept in: aPackage [
	| aPackageConcepsCollection hammingCollection dictionary |
	aPackageConcepsCollection := OrderedCollection new.
	hammingCollection := OrderedCollection new.
	aPackageConcepsCollection := self collectAllConcepts: aPackage.
	hammingCollection := aPackageConcepsCollection
		collect: [ :anotherConcept | 
			aConcept size = anotherConcept size
				ifTrue: [ termsMeasurments hammingDistanceOf: aConcept with: anotherConcept ]
				ifFalse: [ 6 ] ].
	dictionary := OrderedDictionary
		newFromKeys: aPackageConcepsCollection
		andValues: hammingCollection.
	^ dictionary sort
]

{ #category : #sorting }
TermsFeatureSelector >> sortConceptsByLevenshteinDistanceOf: aConcept in: aPackage [
	| aPackageConcepsCollection levenshteinCollection dictionary |
	aPackageConcepsCollection := OrderedCollection new.
	levenshteinCollection := OrderedCollection new.
	aPackageConcepsCollection := self collectAllConcepts: aPackage .
	
	levenshteinCollection := aPackageConcepsCollection
		collect:
			[ :anotherConcept | termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept ].
	dictionary := OrderedDictionary
		newFromKeys: aPackageConcepsCollection
		andValues: levenshteinCollection.
	^ dictionary sort
]

{ #category : #sorting }
TermsFeatureSelector >> sortConceptsByTFIDF: aCollection [
	^ aCollection asSortedCollection 
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> splitAllPackageClassesNames: aPackageName [
	| aPackageAllClassesNames |
	aPackageAllClassesNames := self getPackageAllClassesNames: aPackageName.
	^ aPackageAllClassesNames collect: [ :className | (self splitClassName: className) ]
	"^ allClassesNamesAsCollection collect: [ :e | e collect: #asSymbol ]"
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> splitClassName: aClasseName [

	^aClasseName splitIdentifierName.
]

{ #category : #'as yet unclassified' }
TermsFeatureSelector >> suggestConceptNames: aConcept in: aPackage [
	self trainOn: (self splitAllPackageClassesNames: aPackage).
	^ self
		getConceptTFIDF: aConcept
		in: (('A Test from the first example' splitOn: ' ') asArray) 
]

{ #category : #'as yet unclassified' }
TermsFeatureSelector >> trainOn: aPackageConcepts [
	tfidf trainOn: aPackageConcepts
]
