Class {
	#name : #TermsFeatureSelector,
	#superclass : #Object,
	#instVars : [
		'tfidf'
	],
	#category : 'OntoPharo-Name-Filtrer'
}

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
	^super initialize.
	
]

{ #category : #'as yet unclassified' }
TermsFeatureSelector >> sortConceptsByTFIDF: aCollection [
	^ aCollection asSortedCollection 
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> splitAllPackageClassesNames: aPackageName [
	| aPackageAllClassesNames allClassesNamesAsCollection |
	aPackageAllClassesNames := self getPackageAllClassesNames:
		                           aPackageName.
	allClassesNamesAsCollection := aPackageAllClassesNames collect: [ 
		                               :className | 
		                               self splitClassName: className ].
	^ (allClassesNamesAsCollection collect: [ :e | 
		   (e collect: #asSymbol) asArray ]) asArray
]

{ #category : #'string-manipulation' }
TermsFeatureSelector >> splitClassName: aClasseName [

	^aClasseName splitIdentifierName.
]

{ #category : #'as yet unclassified' }
TermsFeatureSelector >> trainOn: aPackageConcepts [
	tfidf trainOn: aPackageConcepts
]
