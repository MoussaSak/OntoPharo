Class {
	#name : #OntoPharoUserUI,
	#superclass : #OntoPharoUI,
	#instVars : [
		'aClassmethods',
		'aClassInstanceVariables',
		'methodNameSuggestionPresenter',
		'instaceVariableNameSuggestion'
	],
	#category : #'OntoPharo-UI'
}

{ #category : #specs }
OntoPharoUserUI class >> defaultSpec [
	
	
	^ SpBoxLayout newVertical
	
		add:
			(SpBoxLayout newHorizontal 
				add: #suggestionPresenter;			
				yourself);
		add:
			(SpBoxLayout newHorizontal 
				add: #questionLabel ;
				add: #button;
				yourself) withConstraints: [ :constraints | constraints height: 30 ];
		yourself
		 
]

{ #category : #specs }
OntoPharoUserUI class >> killRefresh [

	refresher unregister
]

{ #category : #specs }
OntoPharoUserUI class >> new [
	instance := super new. 
	refresher := OntoEventBroker new.
	refresher addUI: instance.
	^ instance
]

{ #category : #specs }
OntoPharoUserUI class >> open [

	"self open"
	<script>
	
	| presenter windowPresenter |
	presenter := self new. 
	presenter packages: RPackageOrganizer default packages.
	windowPresenter := presenter openWithSpec.
	windowPresenter whenClosedDo: [ 
		self killRefresh. 
		self refresher uiList remove: instance].
	"windowPresenter whenClosedDo: presenter getWhenClosedBlock."
	"windowPresenter window extent: 800@600."
	^ windowPresenter
]

{ #category : #specs }
OntoPharoUserUI class >> refresher [
	^ refresher
]

{ #category : #specs }
OntoPharoUserUI class >> title [ 
	^'OntoPharo User'
]

{ #category : #initialization }
OntoPharoUserUI >> connectPresenters [
	super connectPresenters.
	self extractClassNameConcepts.
	conceptListPresenter
		transmitTo: suggestionPresenter
		transform: self proposeSuggestions
		postTransmission: [ :destination | destination selectIndex: 1 ].
	button
		action: [ 
						|newName|
						newName := self buttonHundler.
						self refactorClassName: aClassName to: newName.
			]
]

{ #category : #initialization }
OntoPharoUserUI >> extractClassNameConcepts [

	^[ :aClass | 
		aPackage := aClass package.
		aClassName := aClass name asString.
		aClassmethods := tfs methods: aClass.
		aClassInstanceVariables := tfs instanceVariables: aClass.
		tfs splitName: aClass getName asString ]
]

{ #category : #initialization }
OntoPharoUserUI >> initializePresenter [

	super initializePresenter.
	methodNameSuggestionPresenter := self newList headerTitle: 'Method Name Suggestions'.
	instaceVariableNameSuggestion := self newList headerTitle: 'Instance Variable Name Suggestions'.
]
