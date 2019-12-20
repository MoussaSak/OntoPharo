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
	tfidf := PGTermFrequencyInverseDocumentFrequency new.
	termsMeasurments := TermsMeasurements new.
	^ super initialize
]

{ #category : #sorting }
TermsFeatureSelector >> sortConceptsByHammingDistanceOF: aConcept  in:  aPackage [ 
	
| aPackageConcepsCollection levenshteinCollection dictionary |
	aPackageConcepsCollection := OrderedCollection new.
	levenshteinCollection := OrderedCollection new.
	aPackageConcepsCollection := self collectAllConcepts: aPackage .
	
	levenshteinCollection := aPackageConcepsCollection
		collect:
			[ :anotherConcept | termsMeasurments hammingDistanceOf: aConcept  with: anotherConcept  ].
	dictionary := OrderedDictionary
		newFromKeys: aPackageConcepsCollection
		andValues: levenshteinCollection.
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
			[ :anotherConcept | termsMeasurments levenshteinDistanceOf: aConcept With: anotherConcept ].
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
