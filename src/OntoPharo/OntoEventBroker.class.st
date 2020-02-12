"
Am an Announcer, i follow the changes made on the system (Classes added or modified mothods added or removed )
"
Class {
	#name : #OntoEventBroker,
	#superclass : #Object,
	#instVars : [
		'ui'
	],
	#category : #'OntoPharo-Announcement'
}

{ #category : #accessing }
OntoEventBroker >> addUI: aUI [

	ui add: aUI
]

{ #category : #initialization }
OntoEventBroker >> handleClassAdded: anEvent [

	ui do: [:each | each selectPackage: anEvent packageAffected].
	ui do: [:each | each selectClass:  anEvent classAffected ].
]

{ #category : #initialization }
OntoEventBroker >> handleClassModified: anEvent [

	ui do: [:each | each selectPackage: anEvent packageAffected].
	ui do: [:each | each selectClass:  anEvent classAffected ].
]

{ #category : #initialization }
OntoEventBroker >> handleClassRemoved: anEvent [

	ui do: [:each | each selectPackage: anEvent packageAffected].
	ui do: [:each | each selectClass:  anEvent classAffected ].
]

{ #category : #initialization }
OntoEventBroker >> handleMethodAdded: anEvent [
	
	ui do: [:each | each selectClass: anEvent classAffected ].
	ui do: [ :each | each selectMethod: anEvent methodAffected].
]

{ #category : #initialization }
OntoEventBroker >> handleMethodModified: anEvent [
	
	ui do: [:each | each selectClass: anEvent classAffected].
	ui do: [ :each | each selectMethod: anEvent methodAffected].
	
	
]

{ #category : #initialization }
OntoEventBroker >> handleMethodRemoved: anEvent [

	ui do: [:each | each selectClass: anEvent classAffected ].
	ui do: [ :each | each selectMethod: anEvent methodAffected].	

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
