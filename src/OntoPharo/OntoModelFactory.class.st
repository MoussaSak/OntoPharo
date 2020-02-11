"
This is Class for handling the Onto Model, 

you can load the model by executing the following command: 

omf := OntoModelFactory new. omf loadOntoModel: 'path'.

you can create the Onto Model by executing the following commmand: 

omf := OntoModelFactory new. omf createOntoModelIn: 'path'.

you can extract the entities by executing the following command: 

omf := OntoModelFactory new. omf extractEntities .

"
Class {
	#name : #OntoModelFactory,
	#superclass : #Object,
	#instVars : [
		'model',
		'path',
		'tfs',
		'data'
	],
	#category : #'OntoPharo-Model-Factory'
}

{ #category : #ontologies }
OntoModelFactory >> createOntoModelIn: aPath [
	"Creates the Onto Model"
	self initialize.
	self path: aPath.
	path asFileReference
	writeStreamDo: [ :writeStream |
		(NeoCSVWriter on: writeStream)
 			writeHeader: #(id label subTypeOf enumerationType equivalentClass properties comment methods instanceVariables isPartOf);
			nextPutAll: (data collect: #values )]
]

{ #category : #accessing }
OntoModelFactory >> data [
	^ data
]

{ #category : #accessing }
OntoModelFactory >> data: anObject [
	data := anObject
]

{ #category : #ontologies }
OntoModelFactory >> deleteOntoModel [
	"Delete the Onto Model"
	|file|
	file := File named: path.
	file exists 
	ifTrue: [file delete ] 
	
	
]

{ #category : #ontologies }
OntoModelFactory >> extractEntities [
	"Extracts the Entities from the Model"
	 ^model collect:  [ :each |
		OrderedDictionary  newFrom: {  
		#'id' -> (each at:1).
		#'label' -> (each at:2).
		#'subTypeOf' -> (each at:3).
		#'enumerationType' -> (each at:4).
		#'equivalentClass' -> (each at:5).
		#'properties' -> (each at:6).
		#'comment' -> (each at:7).
		#'methods' -> (each at: 8).
		#'instanceVariables' -> (each at: 9).
		#'isPartOf' -> (each at:10).
	}]	.
	
	 
]

{ #category : #initialization }
OntoModelFactory >> initialize [ 

		tfs := TermsFeatureSelector new.
		
		data := tfs systemAllClasses collect: [:each| 
		OrderedDictionary  newFrom: {  
		#'id' -> ('').
		#'label' -> (each name asString).
		#'subTypeOf' -> (each superclass).
		#'enumerationType'-> ('').
		#'equivalentClass'-> ('').
		#'properties' -> ('').
		#'comment'-> ('').
		#'methods' -> (',' join:(tfs classAllMethodsNames: each)).
		#'instanceVariables' -> (',' join:(tfs classInstanceVariables: each)).
		#'isPartOf' -> ('').
		}
		]
	
]

{ #category : #ontologies }
OntoModelFactory >> loadOntoModel: aPath [
	"Load the Onto Model"
	self path: aPath.
	model := (path asFileReference
	readStreamDo: [ :readStream |
		(NeoCSVReader on: readStream)
			readHeader;
			readNextRecordAsArray;
			upToEnd ]).
	
]

{ #category : #accessing }
OntoModelFactory >> model [ 
	^model
]

{ #category : #accessing }
OntoModelFactory >> model: aModel [
	model := aModel 
]

{ #category : #accessing }
OntoModelFactory >> path [
	^ path
]

{ #category : #accessing }
OntoModelFactory >> path: anObject [
	path := anObject
]

{ #category : #ontologies }
OntoModelFactory >> updateOntoModel: aPath [
	
	path := aPath.
	self deleteOntoModel.
	self createOntoModelIn: path
]
