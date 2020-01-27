Class {
	#name : #InstanceVariableFeatureSelector,
	#superclass : #TermsFeatureSelector,
	#category : #'OntoPharo-Name-Filtrer'
}

{ #category : #'string-manipulation' }
InstanceVariableFeatureSelector >> classInstanceVariables: aClass [
	"get all Instance Variables Names from a Class"

	allInstanceVariables := aClass instVarNames asOrderedCollection
		collect: [ :instanceName | instanceName asString ] .
	^ allInstanceVariables 
]

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
		instanceCollection add: (self classInstanceVariables: className asClass)	
		].
	^instanceCollection flatCollect: [ :instanceName| instanceName ]
]

{ #category : #sorting }
InstanceVariableFeatureSelector >> sortedConceptsByLevenshteinDistanceOf: aConcept in: aPackage [

	"Sort a Instance Variable Concept compared to other Instance Variables concepts in a given Package by Levenstein distance returning a key/value collection "
	
	| aPackageIVConceptsCollection levenshteinCollection|
	aPackageIVConceptsCollection := self collectAllInstanceVariablesConcepts: aPackage.
	levenshteinCollection := aPackageIVConceptsCollection reject: [:anotherConcept| (anotherConcept sameAs: aConcept )] thenCollect: 
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
