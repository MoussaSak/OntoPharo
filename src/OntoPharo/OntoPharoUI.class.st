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
		'aPackage'
	],
	#category : #'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoUI class >> defaultSpec [
	^ SpPanedLayout newVertical
		add:
			(SpPanedLayout newHorizontal
				add: #classListPresenter;
				add: #conceptListPresenter;
				yourself);
		add:
			(SpBoxLayout newHorizontal
				add: #suggestionPresenter;
				"add: #button;"
				yourself);
	
			yourself
]

{ #category : #specs }
OntoPharoUI class >> open [

	<script>
	| example |
	example := OntoPharoUI new.
	example
		classes: self environment allClasses;
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
	classListPresenter
		transmitTo: conceptListPresenter
		transform: self extractConcepts
		postTransmission: [ :destination | destination selectIndex: 1 ].
	"button
		action: ["
	conceptListPresenter
		transmitTo: suggestionPresenter
		transform: self proposeSuggestions
		postTransmission: [ :destination | destination selectIndex: 1 ].
	"]"
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
	classListPresenter := self newList.
	conceptListPresenter := self newList.
	suggestionPresenter := self newList .
	button := self newButton label: 'Propose Suggestions'.
	self focusOrder
		add: classListPresenter;
		add: conceptListPresenter;
		add: suggestionPresenter;
		add: button
]

{ #category : #initialization }
OntoPharoUI >> proposeSuggestions [
	^ [ :aConcept | 
	(tfs sortConceptsByLevenshteinDistanceOf: aConcept in: aPackage)
		orderedKeys ]
]
