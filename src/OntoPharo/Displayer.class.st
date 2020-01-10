Class {
	#name : #Displayer,
	#superclass : #Object,
	#instVars : [
		'ui'
	],
	#category : #OntoPharo
}

{ #category : #initialization }
Displayer >> handleClassAdded: anEvent [
]

{ #category : #initialization }
Displayer >> handleClassModified: anEvent [
]

{ #category : #initialization }
Displayer >> handleClassRemoved: anEvent [

	
]

{ #category : #initialization }
Displayer >> handleMethodAdded: anEVent [
]

{ #category : #initialization }
Displayer >> handleMethodModified: anEvent [

	ui ifNotNil: [ 
		ui selectClass: anEvent classAffected ]
]

{ #category : #initialization }
Displayer >> handleMethodRemoved: anEvent [

	anEvent inspect.
 
	
]

{ #category : #initialization }
Displayer >> initialize [ 
	super initialize.
	self initializeAnnouncements 
]

{ #category : #initialization }
Displayer >> initializeAnnouncements [

	SystemAnnouncer uniqueInstance weak 
		when: ClassAdded send: #handleClassAdded: to: self;
		when: ClassModifiedClassDefinition send: #handleClassModified: to: self;
		when: ClassRemoved send: #handleClassRemoved: to: self;
		when: MethodAdded send: #handleMethodAdded: to: self;
		when: MethodModified send: #handleMethodModified: to: self;
		when: MethodRemoved send: #handleMethodRemoved: to: self.
]

{ #category : #accessing }
Displayer >> ui [
	^ ui
]

{ #category : #accessing }
Displayer >> ui: anObject [
	ui := anObject
]

{ #category : #initialization }
Displayer >> unregister [
	
	SystemAnnouncer uniqueInstance unsubscribe: self
	
]
