Class {
	#name : #TermsFeatureSelector,
	#superclass : #Object,
	#instVars : [
		'termsMeasurments',
		'allMethodsNames',
		'allInstanceVariables',
		'allClassesNames'
	],
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #'as yet unclassified' }
TermsFeatureSelector >> SortedBigrams: bigramsWithOccurence [
	| bgramsWithValues |
	bgramsWithValues := bigramsWithOccurence asBag valuesAndCounts
		asOrderedDictionary.
	bgramsWithValues sortAssociations: [ :a :b | a value > b value ].
	^ bgramsWithValues keys
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> classAllMethodsNames: aClass [
	"get all Methods Names from a Class"

	allMethodsNames := aClass methods asOrderedCollection collect: [ :methodName|
	methodName name withoutPrefix: (aClass name asString),'>>#' ].
	^ allMethodsNames
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> classInstanceVariables: aClass [
	"get all Instance Variables Names from a Class"

	allInstanceVariables := aClass instVarNames asOrderedCollection
		collect: [ :instanceName | instanceName asString ] .
	^ allInstanceVariables 
]

{ #category : #sorting }
TermsFeatureSelector >> collectAllConcepts: aPackage [
	"Return all the concepts from Class names in aPackage."
	| collection conceptsCollection |
	collection := Set new.
	conceptsCollection := self splitAllPackageClassesNames: aPackage.
	conceptsCollection
		do: [ :i | i do: [ :x | collection add: x asString ] ].
	^ collection
]

{ #category : #initialization }
TermsFeatureSelector >> initialize [
	termsMeasurments := TermsMeasurements new
]

{ #category : #'as yet unclassified' }
TermsFeatureSelector >> nameToBigrams: aName [

	"Transform a Name to a Collection of bigrams"
	|collectionOfConcepts|
	collectionOfConcepts := self splitName: aName.
	
	^ collectionOfConcepts bigrams asOrderedCollection 
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> packageAllClassesNames: aPackageName [
	"get all classes Names from a Package Name"
	
	allClassesNames := (RPackageOrganizer default packageNamed: aPackageName) definedClassNames.
	^ allClassesNames asOrderedCollection
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> packageAllClassesNamesAsBigrams: aPackageName [
	"get all classes Names from a Package Name as Bigrams"
		|classesAsBigrams|	
	classesAsBigrams := (self packageAllClassesNames: aPackageName) collect: [ 
			:aClassName | self nameToBigrams: aClassName
		 ].
	
	^ classesAsBigrams asOrderedCollection flatCollect: [:ngram| ngram  ]
]

{ #category : #'as yet unclassified' }
TermsFeatureSelector >> proposeBigrams: aConcept in: aPackage [
	"Sort a Class Concept compared to other classes concepts in a given Package by the number of occurences of bigrams inside the same Package "

	| bigramsCollection bigramsWithOccurence |
	bigramsCollection := self packageAllClassesNamesAsBigrams: aPackage.
	bigramsWithOccurence := bigramsCollection
		select: [ :bigram | bigram history last = aConcept | (bigram last = aConcept) ]
		thenCollect: [ :bigram | bigram ].
	^ self SortedBigrams: bigramsWithOccurence
]

{ #category : #sorting }
TermsFeatureSelector >> sort2DCollection: a2DCollection [
	"Sort a Key/Value Collection"
	|sorted|
	sorted := SortedCollection sortBlock: [ :a :b | a value < b value ].
	sorted addAll: a2DCollection.
	^ sorted
]

{ #category : #sorting }
TermsFeatureSelector >> sortConceptsByHammingDistanceOF: aConcept in: aPackage [
	"Sort a Class Concept compared to other classes concepts in a given Package by Hamming distance"

	| aPackageConcepsCollection hammingCollection dictionary |
	aPackageConcepsCollection := self collectAllConcepts: aPackage.
	hammingCollection := aPackageConcepsCollection
		collect: [ :anotherConcept | 
			aConcept size = anotherConcept size
				ifTrue: [ termsMeasurments hammingDistanceOf: aConcept with: anotherConcept ]
				ifFalse: [ #() ] ].
	dictionary := OrderedDictionary
		newFromKeys: aPackageConcepsCollection
		andValues: hammingCollection.
	^ dictionary sort
]

{ #category : #sorting }
TermsFeatureSelector >> sortConceptsByLevenshteinDistanceOf: aConcept in: aPackage [
	"Sort a Class Concept compared to other classes concepts in a given Package by Levenstein distance returning a key/value 	dictionary "
		
	| aPackageConcepsCollection levenshteinCollection dictionary |
	aPackageConcepsCollection := self collectAllConcepts: aPackage.
	levenshteinCollection := aPackageConcepsCollection
		collect:
			[ :anotherConcept | termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept ].
	dictionary := OrderedDictionary
		newFromKeys: aPackageConcepsCollection
		andValues: levenshteinCollection.
	^ dictionary sort
]

{ #category : #sorting }
TermsFeatureSelector >> sortedConceptsByLevenshteinDistanceOf: aConcept in: aPackage [
	"Sort a Class Concept compared to other classes concepts in a given Package by Levenstein distance returning a key/value 	collection "
	| aPackageConceptsCollection levenshteinCollection|
	aPackageConceptsCollection := self collectAllConcepts: aPackage.
	levenshteinCollection := aPackageConceptsCollection reject: [:anotherConcept| (anotherConcept sameAs: aConcept )] thenCollect: 
		 [ :anotherConcept| 
			anotherConcept
				->
					(termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept) 
				].
	
	^ self sort2DCollection: levenshteinCollection.
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> splitAllPackageClassesNames: aPackageName [
	| aPackageAllClassesNames |
	aPackageAllClassesNames := self
		packageAllClassesNames: aPackageName.
	^ aPackageAllClassesNames
		collect: [ :className | self splitName: className ]
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> splitAllSystemClassesNames [

	| systemAllClassesNames |
	systemAllClassesNames := self systemAllClasses collect: [:aClass | aClass name].
	^ systemAllClassesNames
		collect: [ :className | self splitName: className ]
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> splitName: aClassName [
	^aClassName splitIdentifierName
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> systemAllClasses [
	
^ Smalltalk globals allClasses
]
