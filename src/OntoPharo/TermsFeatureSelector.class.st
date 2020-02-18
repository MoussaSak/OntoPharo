"
am a terms feature selector am supposed to extract the handle the classes names, and propose suggestions based on the levenshteinDistance and on Bigrams.  
"
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

{ #category : #'n-grams' }
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
	conceptsCollection := self splitAllPackageClassesNames: aPackage name.
	conceptsCollection
		do: [ :i | i do: [ :x | collection add: x asString ] ].
	^ collection
]

{ #category : #initialization }
TermsFeatureSelector >> initialize [
	termsMeasurments := TermsMeasurements new
]

{ #category : #'n-grams' }
TermsFeatureSelector >> nameToBigrams: aName [

	"Transform a Name to a Collection of bigrams"
	|collectionOfConcepts|
	collectionOfConcepts := self splitName: aName.
	
	^ collectionOfConcepts bigrams asOrderedCollection 
]

{ #category : #'classes and packages' }
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

{ #category : #'n-grams' }
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
TermsFeatureSelector >> sortedConceptsByHammingDistanceOF: aConcept in: aPackage [
	"Sort a Class Concept compared to other classes concepts in a given Package by Hamming distance"

	| aPackageConcepsCollection hammingCollection |
	aPackageConcepsCollection := self collectAllConcepts: aPackage.
	hammingCollection := aPackageConcepsCollection
		reject: [ :anotherConcept | 
			(anotherConcept sameAs: aConcept )|(aConcept size ~= anotherConcept size)
			 ] 
		thenCollect: [ :anotherConcept | 
					anotherConcept
						-> 
							(termsMeasurments hammingDistanceOf: aConcept with: anotherConcept) ].

	^ self sort2DCollection: hammingCollection.
]

{ #category : #sorting }
TermsFeatureSelector >> sortedConceptsByLevenshteinDistanceOf: aConcept in: aPackage [
	"Sort a Class Concept compared to other classes concepts in a given Package by Levenstein distance returning a key/value 	collection "
	| aPackageConceptsCollection levenshteinCollection|
	aPackageConceptsCollection := self collectAllConcepts: aPackage.
	levenshteinCollection := aPackageConceptsCollection reject: [:anotherConcept| (anotherConcept sameAs: aConcept ) | ((termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept) >= 3) ] thenCollect: 
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

{ #category : #'classes and packages' }
TermsFeatureSelector >> systemAllClasses [
	
^ Smalltalk globals allClasses
]

{ #category : #'classes and packages' }
TermsFeatureSelector >> systemAllPackages [

	^RPackageOrganizer default packages.
]
