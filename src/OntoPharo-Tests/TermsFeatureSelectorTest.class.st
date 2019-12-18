"
A TermsFeatureSelectorTest is a test class for testing the behavior of TermsFeatureSelector
"
Class {
	#name : #TermsFeatureSelectorTest,
	#superclass : #TestCase,
	#instVars : [
		'tfs'
	],
	#category : 'OntoPharo-Tests'
}

{ #category : #running }
TermsFeatureSelectorTest >> setUp [
	| trainPackage |
	tfs := TermsFeatureSelector new.
	trainPackage := tfs splitAllPackageClassesNames: 'BaselineOfZodiac'.
	tfs trainOn: trainPackage
]

{ #category : #test }
TermsFeatureSelectorTest >> testGetConceptIDFIn [
	| idf |
	idf := tfs getConceptTFIDF: 'Test' in: 'This is a document in Test'.
	self assert: idf closeTo: 0.
]

{ #category : #test }
TermsFeatureSelectorTest >> testSplitAllPackageClassesNames [
	| ordCollection |
	ordCollection :=  #(#(#Baseline #Of #Zodiac)).

	self
		assert: ordCollection
		equals: (tfs splitAllPackageClassesNames: 'BaselineOfZodiac') 
]
