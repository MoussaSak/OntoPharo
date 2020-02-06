"
An OntoModelFactoryTest is a test class for testing the behavior of OntoModelFactory
"
Class {
	#name : #OntoModelFactoryTest,
	#superclass : #TestCase,
	#instVars : [
		'omf'
	],
	#category : #'OntoPharo-Tests-Model-Factory'
}

{ #category : #running }
OntoModelFactoryTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
		omf := OntoModelFactory new.
]

{ #category : #running }
OntoModelFactoryTest >> tearDown [ 	

	super tearDown 
]

{ #category : #test }
OntoModelFactoryTest >> testCreateOntoModelIn [
	|data file |
	omf initialize.
	omf createOntoModelIn: 'ClassesNames.csv'.
	file := File named:'ClassesNames.csv'.
	self assert: file exists equals: true. 
]

{ #category : #test }
OntoModelFactoryTest >> testDeleteOntoModel [

		|file |
	omf path: 'ClassesNames.csv'.
	omf deleteOntoModel.
	file := File named:'ClassesNames.csv'.
	self deny: file exists equals: true. 
	
]

{ #category : #test }
OntoModelFactoryTest >> testLoadOntoModel [

	|model path|
	path := 'ClassesNames.csv'.
	(File named: path) exists 
	ifTrue: [ model := omf loadOntoModel: path ]
	
	ifFalse: [  
	omf createOntoModelIn: path.
	model := omf loadOntoModel: path ].

	self assert: (model = nil )  equals: false.
]
