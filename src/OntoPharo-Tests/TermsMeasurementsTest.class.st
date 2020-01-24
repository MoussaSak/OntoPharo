"
A TermsMeasurementsTest is a test class for testing the behavior of TermsMeasurements
"
Class {
	#name : #TermsMeasurementsTest,
	#superclass : #TestCase,
	#instVars : [
		'termsMeasuremnts',
		'phonetix',
		'tfs'
	],
	#category : #'OntoPharo-Tests-Name-Filtrer'
}

{ #category : #running }
TermsMeasurementsTest >> setUp [
	|trainPackage|
	super setUp.
	termsMeasuremnts := TermsMeasurements new.
	trainPackage := tfs splitAllPackageClassesNames: 'BaselineOfZodiac'.
	tfs trainOn: trainPackage
]

{ #category : #test }
TermsMeasurementsTest >> testGetConceptIDFIn [
	| idf |
	idf := tfs getConceptTFIDF: 'Test' in: 'This is a document in Test'.
	self assert: idf closeTo: 0.
]

{ #category : #test }
TermsMeasurementsTest >> testHammingDistanceOfWith [

	self
		assert:
			( termsMeasuremnts hammingDistanceOf: 'xxxxx' with: 'aaaaa')
		equals: 5
]

{ #category : #test }
TermsMeasurementsTest >> testLevenshteinDistanceOfWith [
	self
		assert:
			(termsMeasuremnts levenshteinDistanceOf: 'Moussa' with:'Mousa') 
		equals: 1.
	self
		assert:
			( termsMeasuremnts  levenshteinDistanceOf: 'abcde' with: 'cdeab' )
		equals: 4
]

{ #category : #test }
TermsMeasurementsTest >> testLevenshteinDistanceOfWith2 [

	self
		assert: (termsMeasuremnts levenshteinDistanceOf: 'termsMeasuremnts' with:'termsMeasurements') 
		equals: 1.
		
	self
		assert: (termsMeasuremnts levenshteinDistanceOf: 'measuremnts' with: 'measurements') 
		equals: 1.
	
	
]
