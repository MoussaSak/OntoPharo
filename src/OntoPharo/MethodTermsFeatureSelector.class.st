Class {
	#name : #MethodTermsFeatureSelector,
	#superclass : #TermsFeatureSelector,
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #sorting }
MethodTermsFeatureSelector >> allMethodsInPackage: aPackageName [
	"gets All Methods in a given Package"
	|methodsCollection packageClasses|
	methodsCollection := OrderedCollection new.
	packageClasses := self packageAllClassesNames: aPackageName.
	packageClasses do:[ :each|
		methodsCollection add: (self classAllMethodsNames: each asClass)	
		].
	^methodsCollection flatCollect: [ :aMethod | aMethod]
]

{ #category : #sorting }
MethodTermsFeatureSelector >> collectAllMethodConcepts: aPackageName [

	"Return all Methods Concepts within a given Package"
	
		| collection conceptsCollection |
	collection := Set new.
	conceptsCollection := self splitAllPackageMethodsNames: aPackageName.
	conceptsCollection
		do: [ :i | i do: [ :x | collection add: x asString ] ].
	^ collection
]

{ #category : #initialization }
MethodTermsFeatureSelector >> initialize [ 

	super initialize.
]

{ #category : #sorting }
MethodTermsFeatureSelector >> packageAllMethodsNamesAsBigrams: aPackageName [
		"get all instance variables in a Package"
		|methodsAsBigrams|	
	methodsAsBigrams := (self allMethodsInPackage: aPackageName) collect: [ 
			:instanceName | self nameToBigrams: instanceName].
	
	^ methodsAsBigrams asOrderedCollection flatCollect: [:ngram| ngram ]
]

{ #category : #sorting }
MethodTermsFeatureSelector >> proposeBigrams: aConcept in: aPackage [
	"Sort an Instance variable Concept compared to other classes concepts in a given Package by the number of occurences of bigrams inside the same Package "

	| bigramsCollection bigramsWithOccurence |
	bigramsCollection := self packageAllMethodsNamesAsBigrams: aPackage.
	bigramsWithOccurence := bigramsCollection
		select: [ :bigram | bigram history last = aConcept | (bigram last = aConcept) ]
		thenCollect: [ :bigram | bigram ].
	^ self SortedBigrams: bigramsWithOccurence
]

{ #category : #sorting }
MethodTermsFeatureSelector >> sortedConceptsByLevenshteinDistanceOf: aConcept in: aPackage [
	
	"Sort a given method name concept campared to other methods concepts in the same package."

	| aPackageMethodConceptsCollection levenshteinCollection|
	aPackageMethodConceptsCollection := self collectAllMethodConcepts: aPackage.
	levenshteinCollection := aPackageMethodConceptsCollection reject: [:anotherConcept| (anotherConcept sameAs: aConcept )] thenCollect: 
		 [ :anotherConcept| 
			anotherConcept
				->
					(termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept) 
				].
	
	^ self sort2DCollection: levenshteinCollection.
]

{ #category : #sorting }
MethodTermsFeatureSelector >> splitAllPackageMethodsNames: aPackageName [

	"Split all Methods names in a given Package "
	
	| aPackageAllMethodsNames |
	aPackageAllMethodsNames := (self
		allMethodsInPackage: aPackageName).
	^ aPackageAllMethodsNames
		collect: [ :methodName | self splitName: methodName ]
]
