Class {
	#name : #OntoPharoUI,
	#superclass : #SpPresenter,
	#instVars : [
		'notebook',
		'checkbox',
		'dynamicPage',
		'conceptListPresenter',
		'classListPresenter',
		'suggestionPresenter',
		'tfs'
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
		add: #suggestionPresenter ;
		yourself
]

{ #category : #specs }
OntoPharoUI class >> open [
	<script>
	"self new openWithSpec"
	|example|
	example := OntoPharoUI new.
	example 
	classes: self environment allClasses ;
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
	conceptListPresenter
		transmitTo: suggestionPresenter
		transform: self proposeSuggestions
		postTransmission: [ :destination | destination selectIndex: 1 ]
]

{ #category : #initialization }
OntoPharoUI >> extractConcepts [
	^ [ :class | (tfs splitClassName: class getName asString) ]
]

{ #category : #initialization }
OntoPharoUI >> initializePresenters [
	tfs := TermsFeatureSelector new.
	classListPresenter := self newList.
	conceptListPresenter := self newList.
	suggestionPresenter := self newList.
	
	self focusOrder
		add: classListPresenter;
		add: conceptListPresenter;
		add: suggestionPresenter
]

{ #category : #initialization }
OntoPharoUI >> proposeSuggestions [
	^ [ :x | #(1 2 3) ]
]
