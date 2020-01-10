"
A TermsMeasurementsTest is a test class for testing the behavior of TermsMeasurements
"
Class {
	#name : #TermsMeasurementsTest,
	#superclass : #TestCase,
	#instVars : [
		'termsMeasuremnts',
		'phonetix'
	],
	#category : #'OntoPharo-Tests-Name-Filtrer'
}

{ #category : #running }
TermsMeasurementsTest >> setUp [
	phonetix := PHEngineEnglish  new.
	termsMeasuremnts := TermsMeasurements new
]

{ #category : #running }
TermsMeasurementsTest >> tearDown [ 
	super tearDown
]

{ #category : #test }
TermsMeasurementsTest >> testHammingDistanceOfWith [
	self
		assert:
			((PHWord with: 'abcde' engine: phonetix)
				levenshteinDistanceWith: (PHWord with: 'abcde' engine: phonetix))
		equals: 0.
	self
		assert:
			((PHWord with: 'xxxxx' engine: phonetix)
				hammingDistanceWith: (PHWord with: 'aaaaa' engine: phonetix))
		equals: 5
]

{ #category : #test }
TermsMeasurementsTest >> testLevenshteinDistanceOfWith [
	self
		assert:
			(termsMeasuremnts levenshteinDistanceOf: 'Moussa' With:'Mousa') 
		equals: 1.
	self
		assert:
			((PHWord with: 'abcde' engine: phonetix)
				levenshteinDistanceWith: (PHWord with: 'cdeab' engine: phonetix))
		equals: 4
]
