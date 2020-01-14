Class {
	#name : #OntoPharoUI,
	#superclass : #SpPresenter,
	#instVars : [
		'dynamicPage',
		'conceptListPresenter',
		'classListPresenter',
		'suggestionPresenter',
		'tfs',
		'button',
		'aPackage',
		'packageListPresenter'
	],
	#classInstVars : [
		'refresher'
	],
	#category : #'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoUI class >> defaultSpec [
	^ SpPanedLayout newVertical
		add:
			(SpPanedLayout newHorizontal
				add: #packageListPresenter ;
				add: #classListPresenter;
				
				yourself);
		add:
			(SpBoxLayout newHorizontal
				add: #conceptListPresenter;
				add: #suggestionPresenter;
				"add: #button;"
				yourself);
	
			yourself
]

{ #category : #specs }
OntoPharoUI class >> initialize [
	"self initialize"
	
	refresher := OntoEventBroker new
]

{ #category : #specs }
OntoPharoUI class >> killRefresh [

	refresher unregister
]

{ #category : #specs }
OntoPharoUI class >> new [

	| instance | 
	instance := super new. 
	refresher addUI: instance.
	^ instance
]

{ #category : #specs }
OntoPharoUI class >> open [
	"self open"
	<script>
	| example |
	example := OntoPharoUI new.
	example
	
	"	classes: self environment allClasses;"
	
		packages: RPackageOrganizer default packages;
		
		openWithSpec.
	^ example
]

{ #category : #specs }
OntoPharoUI class >> title [ 
	^'OntoPharo'
]

{ #category : #accessing }
OntoPharoUI >> classes: aList [

	classListPresenter items = aList
		ifTrue: [ ^ self ].
	classListPresenter
		items: aList;
		selectIndex: 1 
]

{ #category : #initialization }
OntoPharoUI >> connectPresenters [
	super connectPresenters.
	packageListPresenter 
	transmitTo: classListPresenter 
	transform: self extractClasses
	postTransmission: [ :destination | destination selectIndex: 1 ].
	
	classListPresenter
		transmitTo: conceptListPresenter
		transform: self extractConcepts
		postTransmission: [ :destination | destination selectIndex: 1 ].
	
	conceptListPresenter
		transmitTo: suggestionPresenter
		transform: self proposeSuggestions
		postTransmission: [ :destination | destination selectIndex: 1 ]
	"button
		action: []"
]

{ #category : #initialization }
OntoPharoUI >> extractClasses [
	^ [ :aPackageName | 	
		self classes: (aPackageName classes asOrderedCollection).
	aPackageName classes asOrderedCollection ]
]

{ #category : #initialization }
OntoPharoUI >> extractConcepts [
	^ [ :aClass | 
	aPackage := aClass class package name.
	
	tfs splitClassName: aClass getName asString ]
]

{ #category : #initialization }
OntoPharoUI >> initializePresenters [

	tfs := TermsFeatureSelector new.
	packageListPresenter := self newList.
	classListPresenter := self newList.
	conceptListPresenter := self newList.
	suggestionPresenter := self newList.
	button := self newButton label: 'Propose Suggestions'.
	self focusOrder
		add: packageListPresenter;
		add: classListPresenter;
		add: conceptListPresenter;
		add: suggestionPresenter;
		add: button
]

{ #category : #accessing }
OntoPharoUI >> packages: aList [

	packageListPresenter items = aList
		ifTrue: [ ^ self ].
	packageListPresenter
		items: aList;
		selectIndex: 1 
]

{ #category : #initialization }
OntoPharoUI >> proposeSuggestions [
	^ [ :aConcept | 
		(tfs sortedConceptsByLevenshteinDistanceOf: aConcept in: aPackage)
			collect: #key ]
]

{ #category : #initialization }
OntoPharoUI >> selectClass: aClass [

	| index |
	index := (classListPresenter items indexOf: aClass ifAbsent: [^ self ]).
	classListPresenter clickAtIndex: index.  
]

{ #category : #initialization }
OntoPharoUI >> selectClassNamed: aName [

	| index |
	index := (classListPresenter items  indexOf: aName ifAbsent: [^ self ]).
	classListPresenter clickAtIndex: index. 
]
