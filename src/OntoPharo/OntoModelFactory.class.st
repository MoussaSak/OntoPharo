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

{ #category : #'as yet unclassified' }
OntoModelFactory >> createOntoModelIn: aPath [
	"Creates the Onto Model"
	self initialize.
	self path: aPath.
	path asFileReference
	writeStreamDo: [ :writeStream |
		(NeoCSVWriter on: writeStream)
 			writeHeader: #(ClassName Methods InstanceVariables);
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

{ #category : #'as yet unclassified' }
OntoModelFactory >> deleteOntoModel [
	"Delete the Onto Model"
	|file|
	file := File named: path.
	file exists 
	ifTrue: [file delete ] 
	
	
]

{ #category : #'as yet unclassified' }
OntoModelFactory >> extractEntities [
	"Extracts the Entities from the Model"
	 ^model collect:  [ :each |
		OrderedDictionary  newFrom: {  
		#'ClassName' -> (each at:1).
		#'Methods' -> (((each at: 2 ) notNil )
							ifTrue:	[( (each at: 2))]
							ifFalse: [ #() ]).
		#'InstanceVariables' -> (((each at: 3) notNil )
	ifTrue:	[(each at: 3)]
	ifFalse: [#()]).}]	.
	
	 
]

{ #category : #'as yet unclassified' }
OntoModelFactory >> initialize [ 
	
		tfs :=TermsFeatureSelector new.
		
		data := tfs systemAllClasses collect: [:each| 
		OrderedDictionary  newFrom: {  
		#'ClassName' -> (each name asString).
		#'Methods' -> (',' join:(tfs classAllMethodsNames: each)).
		#'InstanceVariables' -> (',' join:(tfs classInstanceVariables: each)).}
		]
	
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
OntoModelFactory >> model [ 
	^model
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
OntoModelFactory >> updateOntoModel: newData [

	self deleteOntoModel.
	self data: newData .
	self createOntoModelIn: path
]
