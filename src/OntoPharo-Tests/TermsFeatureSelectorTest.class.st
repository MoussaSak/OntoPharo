"
A TermsFeatureSelectorTest is a test class for testing the behavior of TermsFeatureSelector
"
Class {
	#name : #TermsFeatureSelectorTest,
	#superclass : #TestCase,
	#instVars : [
		'tfs'
	],
	#category : #'OntoPharo-Tests-Name-Filtrer'
}

{ #category : #running }
TermsFeatureSelectorTest >> setUp [
	
	tfs := TermsFeatureSelector new.
	
]

{ #category : #running }
TermsFeatureSelectorTest >> tearDown [ 
	super tearDown
]

{ #category : #test }
TermsFeatureSelectorTest >> testClassSideMethods [
	
	self assert: (tfs classSideMethods: TermsFeatureSelector ) isEmpty  equals: true .
	self assert: (tfs classSideMethods: OntoPharoUI) equals:  {OntoPharoUI class>>#title. OntoPharoUI class>>#open. OntoPharoUI class>>#new. OntoPharoUI class>>#killRefresh. OntoPharoUI class>>#defaultSpec. OntoPharoUI class>>#refresher}
]

{ #category : #test }
TermsFeatureSelectorTest >> testSplitAllPackageClassesNames [
	| ordCollection |
	ordCollection :=  #(#(#Baseline #Of #Zodiac)).

	self
		assert: ordCollection
		equals: (tfs splitAllPackageClassesNames: 'BaselineOfZodiac') 
]
