"
am a terms feature selector am supposed to extract the handle the instance variables names, and propose suggestions based on the levenshteinDistance and on Bigrams.  
"
Class {
	#name : #InstanceVariableFeatureSelector,
	#superclass : #TermsFeatureSelector,
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #'string-manipulation' }
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

{ #category : #'n-grams' }
InstanceVariableFeatureSelector >> proposeBigrams: aConcept in: aPackage [
	"Sort an Instance variable Concept compared to other classes concepts in a given Package by the number of occurences of bigrams inside the same Package "
	| bigramsCollection bigramsWithOccurence |
	bigramsCollection := self packageAllInatanceVariablesNamesAsBigrams: aPackage.
	bigramsWithOccurence := bigramsCollection
		select: [ :bigram | bigram history last = aConcept | (bigram last = aConcept) ]
		thenCollect: [ :bigram | bigram ].
	^ self sortedBigrams: bigramsWithOccurence
	
]

{ #category : #'string-manipulation' }
InstanceVariableFeatureSelector >> proposeConceptsByContext: aClass [

		"Proposing concepts based on the TF-IDF algorithm:
		- terms with 0 value are removed from the concepts"
	|instanceVariablesConcepts packageConceptsWithTFIDF threshold|	
	threshold := 0.
	instanceVariablesConcepts := self classInstanceVariables: aClass.
	packageConceptsWithTFIDF :=  termsMeasurments instVarsConceptsByContextTFIDF: aClass package name.
	^instanceVariablesConcepts reject: [:aConcept| 
		(packageConceptsWithTFIDF at: aConcept) = threshold] thenCollect:[:aConcept| 
		aConcept ]


]

{ #category : #sorting }
InstanceVariableFeatureSelector >> sortedConceptsByLevenshteinDistanceOf: aConcept in: aPackage [

	"Sort an Instance Variable Concept compared to other Instance Variables concepts in a given Package by Levenstein distance returning a key/value collection "
	
	| aPackageIVConceptsCollection levenshteinCollection|
	aPackageIVConceptsCollection := self collectAllInstanceVariablesConcepts: aPackage.
	levenshteinCollection := aPackageIVConceptsCollection reject: [:anotherConcept| (anotherConcept = aConcept ) | ((termsMeasurments levenshteinDistanceOf: aConcept with: anotherConcept) >= 3)] thenCollect: 
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
