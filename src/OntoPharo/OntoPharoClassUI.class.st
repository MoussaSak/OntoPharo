"
OntoPharo for Class name suggestions execute 

	'OntoPharoClassUI open' to run it. 
"
Class {
	#name : #OntoPharoClassUI,
	#superclass : #OntoPharoUI,
	#category : #'OntoPharo-Spec-UI'
}

{ #category : #specs }
OntoPharoClassUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #classListPresenter;
				add: #conceptListPresenter;
				add: #suggestionPresenter;
				add: #bgramClassSuggestionPresenter;			
				yourself);
		add:
			(SpBoxLayout newHorizontal 
				add: #checkBoxMethod;
				add: #checkBoxClass;
				add: #checkBoxInstanceVar;
				add: #checkBoxContext;
				add: #checkBoxMain;
				yourself) withConstraints: [ :constraints | constraints height: 30];		
		add:
			(SpBoxLayout newHorizontal 
				add: #questionLabel ;
				add: #button;
				yourself) withConstraints: [ :constraints | constraints height: 30 ];
		yourself
		 
]

{ #category : #specs }
OntoPharoClassUI class >> open [

	"self open"
	<script>
	
	| presenter windowPresenter |
	presenter := self new. 
	"presenter packages: RPackageOrganizer default packages."
	windowPresenter := presenter openWithSpec.
	windowPresenter whenClosedDo: [ 
		self killRefresh. 
		self refresher uiList remove: instance].
	"windowPresenter whenClosedDo: presenter getWhenClosedBlock."
	windowPresenter window extent: 1000@600.
	^ windowPresenter
]

{ #category : #specs }
OntoPharoClassUI class >> title [ 
	^'OntoPharo Class UI'
]

{ #category : #initialization }
OntoPharoClassUI >> connectPresenters [
	super connectPresenters.
	classListPresenter
		transmitTo: conceptListPresenter
		transform: self extractConcepts
		postTransmission: [ :destination | destination selectIndex: 1 ].
	conceptListPresenter
		transmitTo: suggestionPresenter
		transform: self proposeSuggestions
		postTransmission: [ :destination | destination selectIndex: 1 ] .
	conceptListPresenter 
		transmitTo: bgramClassSuggestionPresenter 
		transform: self proposeBigramsSuggestions 
		postTransmission: [ :destination | destination selectIndex: 1 ].
	button
		action: [ self buttonHandler ]
]

{ #category : #api }
OntoPharoClassUI >> extractClasses [
	"Extract Classes from the selected Package"
	^ [ :aPackageName | 
		aPackageName 
		ifNotNil: [ 
		self classes: aPackage classes asOrderedCollection.
		aPackage classes asOrderedCollection ]
		ifNil: [ #() ] ]
]

{ #category : #api }
OntoPharoClassUI >> extractConcepts [
	"Extract Classes Names Concepts"
	^ [ :selectedClass | 
	selectedClass 
	ifNotNil: [ 
		tfs splitName: aClass name asString ]
	ifNil:[ #() ] ]

]

{ #category : #announcing }
OntoPharoClassUI >> selectClass: selectedClass [
	"Selects a Class in the UI."
	
	aPackage := selectedClass package.
	aClass := selectedClass.
	self packages: RPackageOrganizer default packages.
	self selectPackage: selectedClass package.
	classListPresenter selectItem: selectedClass
]
