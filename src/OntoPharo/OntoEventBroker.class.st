Class {
	#name : #OntoEventBroker,
	#superclass : #Object,
	#instVars : [
		'ui'
	],
	#category : #OntoPharo
}

{ #category : #accessing }
OntoEventBroker >> addUI: aUI [

	ui add: aUI
]

{ #category : #initialization }
OntoEventBroker >> handleClassAdded: anEvent [
]

{ #category : #initialization }
OntoEventBroker >> handleClassModified: anEvent [
]

{ #category : #initialization }
OntoEventBroker >> handleClassRemoved: anEvent [

	
]

{ #category : #initialization }
OntoEventBroker >> handleMethodAdded: anEVent [
]

{ #category : #initialization }
OntoEventBroker >> handleMethodModified: anEvent [

	ui do: [:each | each selectClass: anEvent classAffected ]
]

{ #category : #initialization }
OntoEventBroker >> handleMethodRemoved: anEvent [

 
	
]

{ #category : #initialization }
OntoEventBroker >> initialize [ 
	super initialize.
	self initializeAnnouncements.
	ui := OrderedCollection new.
]

{ #category : #initialization }
OntoEventBroker >> initializeAnnouncements [

	SystemAnnouncer uniqueInstance weak 
		when: ClassAdded send: #handleClassAdded: to: self;
		when: ClassModifiedClassDefinition send: #handleClassModified: to: self;
		when: ClassRemoved send: #handleClassRemoved: to: self;
		when: MethodAdded send: #handleMethodAdded: to: self;
		when: MethodModified send: #handleMethodModified: to: self;
		when: MethodRemoved send: #handleMethodRemoved: to: self.
]

{ #category : #accessing }
OntoEventBroker >> uiList [
	^ ui
]

{ #category : #private }
OntoEventBroker >> uiList: aList [
	ui := aList
]

{ #category : #initialization }
OntoEventBroker >> unregister [
	
	SystemAnnouncer uniqueInstance unsubscribe: self
	
]
