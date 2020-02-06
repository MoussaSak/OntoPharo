Class {
	#name : #InstanceVariableFeatureSelector,
	#superclass : #TermsFeatureSelector,
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #sorting }
InstanceVariableFeatureSelector >> collectAllInstanceVariablesConcepts: aPackage [
	"Return all Instance Variables concepts  in a given Package."
	| collection conceptsCollection |
	collection := Set new.
	conceptsCollection := self splitAllPackageInstanceNames: aPackage.
	conceptsCollection
		do: [ :i | i do: [ :x | collection add: x asString ] ].
	^ collection
]

{ #category : #initialization }
InstanceVariableFeatureSelector >> initialize [ 

	super initialize.
]

{ #category : #'string-manipulation' }
InstanceVariableFeatureSelector >> packageAllInatanceVariablesNames: aPackageName [
	"get all instance variables in a Package"
	|packageClasses instanceCollection|
	instanceCollection := OrderedCollection new.
	packageClasses := self packageAllClassesNames: aPackageName .
	packageClasses do:[ :className|
		instanceCollection add: (self classInstanceVariables: (self class environment at: className asSymbol) )	
		].
	^instanceCollection flatCollect: [ :instanceName| instanceName ]
]

{ #category : #'string-manipulation' }
InstanceVariableFeatureSelector >> packageAllInatanceVariablesNamesAsBigrams: aPackageName [
	"get all instance variables in a Package"
		|instancesAsBigrams|	
	instancesAsBigrams := (self packageAllInatanceVariablesNames: aPackageName) collect: [ 
			:instanceName | self nameToBigrams: instanceName].
	
	^ instancesAsBigrams asOrderedCollection flatCollect: [:ngram| ngram ]
]

{ #category : #'string-manipulation' }
InstanceVariableFeatureSelector >> proposeBigrams: aConcept in: aPackage [
	"Sort an Instance variable Concept compared to other classes concepts in a given Package by the number of occurences of bigrams inside the same Package "

	| bigramsCollection bigramsWithOccurence |
	bigramsCollection := self packageAllInatanceVariablesNamesAsBigrams: aPackage.
	bigramsWithOccurence := bigramsCollection
		select: [ :bigram | bigram history last = aConcept | (bigram last = aConcept) ]
		thenCollect: [ :bigram | bigram ].
	^ self SortedBigrams: bigramsWithOccurence
]

{ #category : #sorting }
InstanceVariableFeatureSelector >> sortedConceptsByLevenshteinDistanceOf: aConcept in: aPackage [

	"Sort an Instance Variable Concept compared to other Instance Variables concepts in a given Package by Levenstein distance returning a key/value collection "
	
	| aPackageIVConceptsCollection levenshteinCollection|
	aPackageIVConceptsCollection := self collectAllInstanceVariablesConcepts: aPackage.
	levenshteinCollection := aPackageIVConceptsCollection reject: [:anotherConcept| (anotherConcept = aConcept )] thenCollect: 
		 [ :anotherConcept| 
			anotherConcept
				->
					(termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept) 
				].
	
	^ self sort2DCollection: levenshteinCollection.
]

{ #category : #'string-manipulation' }
InstanceVariableFeatureSelector >> splitAllPackageInstanceNames: aPackageName [
	| aPackageAllIVNames |
	aPackageAllIVNames := self
		packageAllInatanceVariablesNames: aPackageName.
	^ aPackageAllIVNames
		collect: [ :className | self splitName: className ]
]
